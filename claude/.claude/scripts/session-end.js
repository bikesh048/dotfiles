#!/usr/bin/env node
/**
 * Stop Hook - Persist session summary for cross-session continuity
 */

const fs = require('fs');
const path = require('path');
const {
  SESSIONS_DIR, ensureDir, writeFile,
  getDateString, getTimeString, getSessionId,
  getProjectName, getBranch, getTranscriptPath, parseTranscript
} = require('./lib/utils');

const SUMMARY_START = '<!-- SUMMARY:START -->';
const SUMMARY_END = '<!-- SUMMARY:END -->';

function escapeRe(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }

function buildHeader(today, time, project, branch) {
  return `# Session: ${today}
**Date:** ${today}
**Started:** ${time}
**Last Updated:** ${time}
**Project:** ${project}
**Branch:** ${branch}
**Directory:** ${process.cwd()}`;
}

function buildSummaryBlock(parsed) {
  let s = `${SUMMARY_START}\n## Session Summary\n\n### Tasks\n`;
  for (const msg of parsed.userMessages.slice(-10)) {
    s += `- ${msg.slice(0, 200).replace(/\n/g, ' ').replace(/`/g, '\\`')}\n`;
  }
  s += '\n';
  if (parsed.filesModified.length > 0) {
    s += '### Files Modified\n';
    for (const f of parsed.filesModified.slice(0, 30)) s += `- ${f}\n`;
    s += '\n';
  }
  if (parsed.toolsUsed.length > 0) {
    s += `### Tools Used\n${parsed.toolsUsed.slice(0, 20).join(', ')}\n\n`;
  }
  s += `### Stats\n- Total user messages: ${parsed.totalMessages}\n\n${SUMMARY_END}`;
  return s;
}

async function main() {
  const { transcriptPath } = await getTranscriptPath();
  ensureDir(SESSIONS_DIR);

  const today = getDateString();
  const time = getTimeString();
  const sessionId = getSessionId();
  const sessionFile = path.join(SESSIONS_DIR, `${today}-${sessionId}-session.md`);

  const parsed = transcriptPath && fs.existsSync(transcriptPath)
    ? parseTranscript(transcriptPath)
    : null;

  if (fs.existsSync(sessionFile)) {
    let content = fs.readFileSync(sessionFile, 'utf8');
    content = content.replace(/\*\*Last Updated:\*\*\s*[\d:]+/, `**Last Updated:** ${time}`);

    if (parsed) {
      const block = buildSummaryBlock(parsed);
      if (content.includes(SUMMARY_START) && content.includes(SUMMARY_END)) {
        content = content.replace(
          new RegExp(`${escapeRe(SUMMARY_START)}[\\s\\S]*?${escapeRe(SUMMARY_END)}`), block
        );
      } else {
        content = content.replace(/### Notes for Next Session/, `${block}\n\n### Notes for Next Session`);
      }
    }

    writeFile(sessionFile, content);
    console.error(`[SessionEnd] Updated: ${sessionFile}`);
  } else {
    const summary = parsed
      ? buildSummaryBlock(parsed)
      : '## Current State\n\n[Session context goes here]\n\n### Completed\n- [ ]\n\n### In Progress\n- [ ]';

    const template = `${buildHeader(today, time, getProjectName(), getBranch())}

---

${summary}

### Notes for Next Session
-

### Context to Load
\`\`\`
[relevant files]
\`\`\`
`;
    writeFile(sessionFile, template);
    console.error(`[SessionEnd] Created: ${sessionFile}`);
  }

  process.exit(0);
}

main().catch(err => { console.error('[SessionEnd]', err.message); process.exit(0); });
