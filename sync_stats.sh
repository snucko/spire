#!/bin/bash
# Compress logs and push to spire repo to free up local space

set -e

SPIRE_REPO="/tmp/spire"  # Change to your spire repo path
BOT_LOGS="./logs"

echo "🔄 Syncing logs to spire repo..."

# Create spire directory if needed
mkdir -p "$SPIRE_REPO"

# Compress run_history.log
echo "📦 Compressing logs..."
gzip -c "$BOT_LOGS/run_history.log" > "$SPIRE_REPO/logs/run_history.log.gz"

# Keep uncompressed for local use (optional - remove if want to save space)
# cp "$BOT_LOGS/run_history.log" "$SPIRE_REPO/logs/run_history.log"

# Push to GitHub
echo "📤 Pushing to GitHub..."
cd "$SPIRE_REPO"
git config user.email "$(git config --global user.email)"
git config user.name "$(git config --global user.name)"
git add logs/
git commit -m "chore: sync bot logs $(date +%Y-%m-%d)" || echo "No changes"
git push

echo "✅ Done! Logs synced to spire repo"
echo "   Compressed: $SPIRE_REPO/logs/run_history.log.gz"
