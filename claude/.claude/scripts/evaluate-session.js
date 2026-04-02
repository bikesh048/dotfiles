#!/usr/bin/env node
/**
 * Stop Hook - Evaluate session for extractable patterns (instincts)
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const {
  HOMUNCULUS_DIR, ensureDir, readFile, writeFile,
  getProjectId, getTranscriptPath, parseTranscript
} = require('./lib/utils');

const MIN_SESSION_LENGTH = 8;

function getTopN(arr, n) {
  const counts = {};
  for (const item of arr) counts[item] = (counts[item] || 0) + 1;
  return Object.entries(counts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, n)
    .map(([name, count]) => ({ name, count }));
}

async function main() {
  const { transcriptPath } = await getTranscriptPath();
  if (!transcriptPath || !fs.existsSync(transcriptPath)) return;

  const parsed = parseTranscript(transcriptPath);
  if (!parsed || parsed.totalMessages < MIN_SESSION_LENGTH) {
    console.error(`[evaluate] Short session (${parsed?.totalMessages || 0} msgs), skipping`);
    return;
  }

  const projectId = getProjectId();
  const projectDir = path.join(HOMUNCULUS_DIR, 'projects', projectId);
  ensureDir(projectDir);

  // Save evaluation summary
  const evalFile = path.join(projectDir, 'session-evaluations.jsonl');
  fs.appendFileSync(evalFile, JSON.stringify({
    timestamp: new Date().toISOString(),
    messageCount: parsed.totalMessages,
    correctionCount: parsed.corrections.length,
    corrections: parsed.corrections.slice(0, 5),
    topTools: getTopN(parsed.toolSequence, 10),
    toolSequenceLength: parsed.toolSequence.length
  }) + '\n', 'utf8');

  // Extract instincts from corrections
  if (parsed.corrections.length > 0) {
    const instinctsDir = path.join(projectDir, 'instincts', 'personal');
    ensureDir(instinctsDir);

    for (const correction of parsed.corrections.slice(0, 3)) {
      const id = crypto.createHash('sha256').update(correction).digest('hex').slice(0, 8);
      const instinctFile = path.join(instinctsDir, `correction-${id}.yaml`);

      if (fs.existsSync(instinctFile)) {
        // Bump confidence on repeat observation
        let content = readFile(instinctFile);
        const match = content.match(/confidence:\s*([\d.]+)/);
        if (match) {
          const newConf = Math.min(0.9, parseFloat(match[1]) + 0.1);
          content = content.replace(/confidence:\s*[\d.]+/, `confidence: ${newConf}`);
          content = content.replace(/last_seen:.*/, `last_seen: "${new Date().toISOString()}"`);
          writeFile(instinctFile, content);
        }
        continue;
      }

      writeFile(instinctFile, `---
id: correction-${id}
trigger: "user correction"
confidence: 0.4
domain: "workflow"
scope: project
project_id: "${projectId}"
created: "${new Date().toISOString()}"
last_seen: "${new Date().toISOString()}"
---

# User Correction

## Action
${correction}

## Evidence
- Extracted from session on ${new Date().toISOString().split('T')[0]}
`);
      console.error(`[evaluate] New instinct: correction-${id}`);
    }
  }

  console.error(`[evaluate] ${parsed.totalMessages} msgs, ${parsed.corrections.length} corrections, ${parsed.toolSequence.length} tools`);
}

main().catch(err => { console.error('[evaluate]', err.message); }).finally(() => process.exit(0));
