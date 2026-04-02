#!/usr/bin/env node
/**
 * SessionStart Hook - Load previous session context
 */

const fs = require('fs');
const { SESSIONS_DIR, ensureDir } = require('./lib/utils');

function main() {
  ensureDir(SESSIONS_DIR);

  const files = fs.readdirSync(SESSIONS_DIR)
    .filter(f => f.endsWith('-session.md'))
    .map(f => {
      const p = require('path').join(SESSIONS_DIR, f);
      return { name: f, path: p, mtime: fs.statSync(p).mtime };
    })
    .sort((a, b) => b.mtime - a.mtime);

  const cutoff = Date.now() - 7 * 24 * 60 * 60 * 1000;
  const recent = files.filter(f => f.mtime.getTime() > cutoff);

  if (recent.length === 0) return;

  const content = fs.readFileSync(recent[0].path, 'utf8');
  if (content && !content.includes('[Session context goes here]')) {
    process.stdout.write(`Previous session summary (${recent[0].name}):\n${content}\n`);
  }

  if (recent.length > 1) {
    console.error(`[SessionStart] ${recent.length} recent session(s) in ${SESSIONS_DIR}`);
  }
}

try { main(); } catch (err) { console.error('[SessionStart]', err.message); }
process.exit(0);
