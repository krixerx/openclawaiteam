#!/usr/bin/env node
// Redis messaging for OpenClaw agents
// Usage:
//   msg-send <to> <subject> <body>     — send a message to another agent
//   msg-check                           — check inbox for new messages
//   msg-history [count]                 — view recent message history

import { createConnection } from 'net';

const REDIS_HOST = process.env.REDIS_HOST || 'redis';
const REDIS_PORT = parseInt(process.env.REDIS_PORT || '6379');
const AGENT = (process.env.OPENCLAW_AGENT_NAME || 'unknown').toLowerCase();

// --- RESP Protocol ---

function encode(args) {
  let s = `*${args.length}\r\n`;
  for (const a of args) {
    const b = Buffer.from(String(a));
    s += `$${b.length}\r\n${a}\r\n`;
  }
  return s;
}

function parseOne(data, offset) {
  if (offset >= data.length) throw new Error('incomplete');
  const type = data[offset];
  const lineEnd = data.indexOf('\r\n', offset);
  if (lineEnd === -1) throw new Error('incomplete');
  const line = data.substring(offset + 1, lineEnd);

  switch (type) {
    case '+': return { value: line, next: lineEnd + 2 };
    case '-': return { value: new Error(line), next: lineEnd + 2 };
    case ':': return { value: parseInt(line), next: lineEnd + 2 };
    case '$': {
      const len = parseInt(line);
      if (len === -1) return { value: null, next: lineEnd + 2 };
      const start = lineEnd + 2;
      if (start + len + 2 > data.length) throw new Error('incomplete');
      return { value: data.substring(start, start + len), next: start + len + 2 };
    }
    case '*': {
      const count = parseInt(line);
      if (count === -1) return { value: null, next: lineEnd + 2 };
      const arr = [];
      let pos = lineEnd + 2;
      for (let i = 0; i < count; i++) {
        const r = parseOne(data, pos);
        arr.push(r.value);
        pos = r.next;
      }
      return { value: arr, next: pos };
    }
    default:
      throw new Error(`unknown RESP type: ${type}`);
  }
}

function parseAll(data) {
  const results = [];
  let offset = 0;
  while (offset < data.length) {
    const r = parseOne(data, offset);
    results.push(r.value);
    offset = r.next;
  }
  return results;
}

function redis(commands) {
  return new Promise((resolve, reject) => {
    const conn = createConnection(REDIS_PORT, REDIS_HOST);
    const payload = commands.map(c => encode(c)).join('');
    let buf = '';
    const expected = commands.length;

    conn.on('connect', () => conn.write(payload));
    conn.on('data', d => {
      buf += d.toString();
      try {
        const results = parseAll(buf);
        if (results.length >= expected) {
          conn.end();
          resolve(results);
        }
      } catch {
        // Partial data — wait for more
      }
    });
    conn.on('error', reject);
    setTimeout(() => { conn.destroy(); reject(new Error('Redis timeout')); }, 5000);
  });
}

// --- Commands ---

async function send(to, subject, body) {
  const msg = {
    from: AGENT,
    to: to.toLowerCase(),
    timestamp: new Date().toISOString(),
    subject,
    body
  };
  const json = JSON.stringify(msg);
  const target = `inbox:${to.toLowerCase()}`;

  await redis([
    ['LPUSH', target, json],
    ['LPUSH', 'msg:history', json],
    ['LTRIM', 'msg:history', '0', '99']
  ]);

  console.log(`Message sent to ${to}: "${subject}"`);
}

async function check() {
  const inbox = `inbox:${AGENT}`;
  const results = await redis([
    ['LRANGE', inbox, '0', '-1'],
    ['DEL', inbox]
  ]);

  const messages = results[0] || [];
  if (messages.length === 0) {
    console.log('No new messages.');
    return;
  }

  console.log(`${messages.length} new message(s):\n`);
  // LPUSH stores newest first — reverse for chronological order
  messages.reverse();
  for (const raw of messages) {
    try {
      const msg = JSON.parse(raw);
      console.log(`--- From: ${msg.from} | Subject: ${msg.subject} | Time: ${msg.timestamp} ---`);
      console.log(msg.body);
      console.log('');
    } catch {
      console.log(`[unparseable]: ${raw}`);
    }
  }
}

async function history(count = 20) {
  const results = await redis([
    ['LRANGE', 'msg:history', '0', String(count - 1)]
  ]);

  const messages = results[0] || [];
  if (messages.length === 0) {
    console.log('No message history.');
    return;
  }

  console.log(`Last ${messages.length} messages:\n`);
  messages.reverse();
  for (const raw of messages) {
    try {
      const msg = JSON.parse(raw);
      console.log(`[${msg.timestamp}] ${msg.from} -> ${msg.to}: ${msg.subject}`);
      console.log(`  ${msg.body.substring(0, 120)}${msg.body.length > 120 ? '...' : ''}`);
    } catch {
      console.log(`[unparseable]: ${raw}`);
    }
  }
}

// --- Main ---

const [,, cmd, ...args] = process.argv;

try {
  switch (cmd) {
    case 'send':
      if (args.length < 3) {
        console.error('Usage: msg-send <to> <subject> <body>');
        process.exit(1);
      }
      await send(args[0], args[1], args.slice(2).join(' '));
      break;
    case 'check':
      await check();
      break;
    case 'history':
      await history(parseInt(args[0]) || 20);
      break;
    default:
      console.error('Commands: msg-send <to> <subject> <body> | msg-check | msg-history [count]');
      process.exit(1);
  }
} catch (e) {
  console.error(`Error: ${e.message}`);
  process.exit(1);
}
