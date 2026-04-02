#!/usr/bin/env node
/**
 * PreToolUse/PostToolUse Hook - Capture tool use observations
 */

const fs = require('fs');
const path = require('path');
const {
  HOMUNCULUS_DIR, ensureDir, readFile, writeFile,
  scrub, getProjectId, getProjectName, readStdin
} = require('./lib/utils');

const MAX_FILE_SIZE_MB = 10;

async function main() {
  const raw = await readStdin();
  if (!raw.trim()) return;

  let data;
  try { data = JSON.parse(raw); } catch { return; }

  // Skip subagent sessions
  if (data.agent_id) return;

  const projectId = getProjectId();
  const projectName = getProjectName();
  const projectDir = path.join(HOMUNCULUS_DIR, 'projects', projectId);
  ensureDir(projectDir);

  // Update project registry
  const registryPath = path.join(HOMUNCULUS_DIR, 'projects.json');
  let registry = {};
  try { registry = JSON.parse(readFile(registryPath) || '{}'); } catch {}
  if (!registry[projectId]) {
    registry[projectId] = { name: projectName, root: process.cwd(), firstSeen: new Date().toISOString() };
    writeFile(registryPath, JSON.stringify(registry, null, 2));
  }

  const obsFile = path.join(projectDir, 'observations.jsonl');

  // Archive if too large
  if (fs.existsSync(obsFile)) {
    try {
      if (fs.statSync(obsFile).size / (1024 * 1024) >= MAX_FILE_SIZE_MB) {
        const archiveDir = path.join(projectDir, 'observations.archive');
        ensureDir(archiveDir);
        fs.renameSync(obsFile, path.join(archiveDir, `observations-${Date.now()}.jsonl`));
      }
    } catch {}
  }

  const toolName = data.tool_name || data.tool || 'unknown';
  const toolInput = data.tool_input || data.input || {};
  const hasOutput = data.tool_response !== undefined || data.tool_output !== undefined || data.output !== undefined;

  const observation = {
    timestamp: new Date().toISOString(),
    event: hasOutput ? 'tool_complete' : 'tool_start',
    tool: toolName,
    session: data.session_id || 'unknown',
    project_id: projectId,
    project_name: projectName
  };

  if (!hasOutput) {
    const inputStr = typeof toolInput === 'object' ? JSON.stringify(toolInput) : String(toolInput);
    observation.input = scrub(inputStr);
  } else {
    const raw = data.tool_response || data.tool_output || data.output || '';
    const outputStr = typeof raw === 'object' ? JSON.stringify(raw) : String(raw);
    observation.output = scrub(outputStr);
  }

  fs.appendFileSync(obsFile, JSON.stringify(observation) + '\n', 'utf8');
}

main().catch(err => { console.error('[observe]', err.message); }).finally(() => process.exit(0));
