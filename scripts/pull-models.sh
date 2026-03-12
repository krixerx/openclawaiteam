#!/bin/bash
# Verify Groq API access and available models.
# Run after setting GROQ_API_KEY in your .env file.

set -euo pipefail

if [ -z "${GROQ_API_KEY:-}" ]; then
  if [ -f .env ]; then
    export $(grep -E '^GROQ_API_KEY=' .env | xargs)
  fi
fi

if [ -z "${GROQ_API_KEY:-}" ]; then
  echo "ERROR: GROQ_API_KEY is not set. Add it to your .env file."
  echo "Get your API key at: https://console.groq.com"
  exit 1
fi

echo "Verifying Groq API access..."

echo ""
echo "Checking available models..."
curl -s https://api.groq.com/openai/v1/models \
  -H "Authorization: Bearer $GROQ_API_KEY" | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
if 'error' in data:
    print(f\"ERROR: {data['error']['message']}\")
    sys.exit(1)
models = [m['id'] for m in data['data']]
targets = ['qwen3-32b', 'qwen-2.5-coder-32b']
print('Available target models:')
for t in targets:
    status = 'AVAILABLE' if t in models else 'NOT FOUND'
    print(f'  {t}: {status}')
print(f'\nTotal models on Groq: {len(models)}')
"

echo ""
echo "Running quick inference test with qwen-2.5-coder-32b..."
curl -s https://api.groq.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-2.5-coder-32b",
    "messages": [{"role": "user", "content": "Say hello in one sentence."}],
    "max_tokens": 50
  }' | python3 -c "
import json, sys
data = json.load(sys.stdin)
if 'error' in data:
    print(f\"ERROR: {data['error']['message']}\")
    sys.exit(1)
print(f\"Response: {data['choices'][0]['message']['content']}\")
print('Groq API is working!')
"
