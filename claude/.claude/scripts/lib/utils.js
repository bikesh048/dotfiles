/**
 * Shared utilities for Claude Code hooks
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

// Paths
const CLAUDE_DIR = path.join(process.env.HOME, '.claude');
const SESSIONS_DIR = path.join(CLAUDE_DIR, 'sessions');
const HOMUNCULUS_DIR = path.join(CLAUDE_DIR, 'homunculus');
const LEARNED_DIR = path.join(CLAUDE_DIR, 'learned');

// Regex to scrub secrets from persisted data
const SECRET_RE = /(?:api[_-]?key|token|secret|password|authorization|credentials?|auth)(["'\s:=]+)(?:[A-Za-z]+\s+)?([A-Za-z0-9_\-/.+=]{8,})/gi;

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function readFile(filePath) {
  try { return fs.readFileSync(filePath, 'utf8'); } catch { return null; }
}

function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content, 'utf8');
}

function scrub(val, maxLen = 3000) {
  if (!val) return null;
  return String(val).slice(0, maxLen).replace(SECRET_RE, (m, sep) => `[REDACTED]${sep}[REDACTED]`);
}

// Date/time
function getDateString() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

function getTimeString() {
  const d = new Date();
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}:${String(d.getSeconds()).padStart(2, '0')}`;
}

// Project detection
function getProjectId() {
  try {
    const remote = execSync('git remote get-url origin 2>/dev/null', { encoding: 'utf8', timeout: 3000 }).trim();
    if (remote) return crypto.createHash('sha256').update(remote).digest('hex').slice(0, 12);
  } catch {}
  try {
    const root = execSync('git rev-parse --show-toplevel 2>/dev/null', { encoding: 'utf8', timeout: 3000 }).trim();
    if (root) return crypto.createHash('sha256').update(root).digest('hex').slice(0, 12);
  } catch {}
  return 'global';
}

function getProjectName() {
  try {
    const root = execSync('git rev-parse --show-toplevel 2>/dev/null', { encoding: 'utf8', timeout: 3000 }).trim();
    return path.basename(root);
  } catch {}
  return path.basename(process.cwd());
}

function getBranch() {
  try {
    return execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8', timeout: 3000 }).trim();
  } catch { return 'unknown'; }
}

function getProjectDir() {
  const id = getProjectId();
  const dir = path.join(HOMUNCULUS_DIR, 'projects', id);
  ensureDir(dir);
  return { id, dir };
}

// Session ID from env or random
function getSessionId() {
  const envId = process.env.CLAUDE_SESSION_ID;
  if (envId) return envId.slice(0, 8);
  return Math.random().toString(36).slice(2, 10);
}

// Transcript parsing
function parseTranscript(transcriptPath) {
  const content = readFile(transcriptPath);
  if (!content) return null;

  const lines = content.split('\n').filter(Boolean);
  const userMessages = [];
  const toolsUsed = new Set();
  const filesModified = new Set();
  const corrections = [];
  const toolSequence = [];
  let lastTool = null;

  for (const line of lines) {
    try {
      const entry = JSON.parse(line);

      // User messages
      if (entry.type === 'user' || entry.role === 'user' || entry.message?.role === 'user') {
        const raw = entry.message?.content ?? entry.content;
        const text = typeof raw === 'string'
          ? raw
          : Array.isArray(raw)
            ? raw.map(c => (c && c.text) || '').join(' ')
            : '';
        if (text.trim()) {
          userMessages.push(text.trim());
          // Detect corrections
          const lower = text.toLowerCase();
          if (/\b(no[,.]?\s|don'?t|instead|not that|wrong|actually|stop)\b/.test(lower) && text.length < 500) {
            corrections.push(text.trim().slice(0, 300));
          }
        }
      }

      // Tool uses - direct entries
      if (entry.type === 'tool_use' || entry.tool_name) {
        const name = entry.tool_name || entry.name || '';
        if (name) toolsUsed.add(name);
        const fp = entry.tool_input?.file_path || entry.input?.file_path || '';
        if (fp && (name === 'Edit' || name === 'Write')) filesModified.add(fp);
        if (name && name !== lastTool) { toolSequence.push(name); lastTool = name; }
      }

      // Tool uses - from assistant content blocks
      if (entry.type === 'assistant' && Array.isArray(entry.message?.content)) {
        for (const block of entry.message.content) {
          if (block.type === 'tool_use') {
            const name = block.name || '';
            if (name) toolsUsed.add(name);
            const fp = block.input?.file_path || '';
            if (fp && (name === 'Edit' || name === 'Write')) filesModified.add(fp);
            if (name && name !== lastTool) { toolSequence.push(name); lastTool = name; }
          }
        }
      }
    } catch {}
  }

  return {
    userMessages,
    toolsUsed: Array.from(toolsUsed),
    filesModified: Array.from(filesModified),
    corrections,
    toolSequence,
    totalMessages: userMessages.length
  };
}

// Read stdin with size limit
function readStdin(maxBytes = 1024 * 1024) {
  return new Promise(resolve => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', chunk => {
      if (data.length < maxBytes) data += chunk.substring(0, maxBytes - data.length);
    });
    process.stdin.on('end', () => resolve(data));
  });
}

// Parse transcript_path from stdin JSON
async function getTranscriptPath() {
  const raw = await readStdin();
  try {
    const input = JSON.parse(raw);
    return { transcriptPath: input.transcript_path, raw, parsed: input };
  } catch {
    return { transcriptPath: process.env.CLAUDE_TRANSCRIPT_PATH, raw, parsed: null };
  }
}

module.exports = {
  CLAUDE_DIR, SESSIONS_DIR, HOMUNCULUS_DIR, LEARNED_DIR,
  ensureDir, readFile, writeFile, scrub,
  getDateString, getTimeString, getSessionId,
  getProjectId, getProjectName, getBranch, getProjectDir,
  parseTranscript, readStdin, getTranscriptPath
};
