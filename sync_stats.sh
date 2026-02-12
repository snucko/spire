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

# Push to GitHub
echo "📤 Pushing to GitHub..."
cd "$SPIRE_REPO"
git config user.email "$(git config --global user.email)"
git config user.name "$(git config --global user.name)"
git add logs/
git commit -m "chore: sync bot logs $(date +%Y-%m-%d)" || echo "No changes"
git push

# Delete local uncompressed copy to free space
echo "🗑️  Deleting local uncompressed logs..."
rm -f "$BOT_LOGS/run_history.log"

echo "✅ Done! Logs compressed and synced to GitHub"
echo "   GitHub: $SPIRE_REPO/logs/run_history.log.gz"
echo "   Local: Deleted to free space"
