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
if [ -f "$BOT_LOGS/run_history.log" ]; then
    gzip -c "$BOT_LOGS/run_history.log" > "$SPIRE_REPO/logs/run_history.log.gz"
fi

# Compress individual run files locally (don't push - too large for GitHub)
if [ -d "$BOT_LOGS/runs" ] && [ "$(ls -A $BOT_LOGS/runs)" ]; then
    echo "📦 Compressing individual run files locally..."
    find "$BOT_LOGS/runs" -name "*.log" -type f | while read logfile; do
        if [ ! -f "${logfile}.gz" ]; then
            gzip "$logfile"
        fi
    done
    echo "   Compressed $(ls -1 $BOT_LOGS/runs/*.gz 2>/dev/null | wc -l) run files"
fi

# Push to GitHub
echo "📤 Pushing to GitHub..."
cd "$SPIRE_REPO"
git config user.email "$(git config --global user.email)"
git config user.name "$(git config --global user.name)"
git add logs/
git commit -m "chore: sync bot logs $(date +%Y-%m-%d)" || echo "No changes"
git push

# Delete local uncompressed copies to free space
echo "🗑️  Cleaning up uncompressed files..."
rm -f "$BOT_LOGS/run_history.log"
find "$BOT_LOGS/runs" -name "*.log" -type f -delete 2>/dev/null || true

echo "✅ Done! Logs synced to GitHub and compressed locally"
echo "   GitHub: $SPIRE_REPO/logs/run_history.log.gz"
echo "   Local: Compressed .gz files in logs/runs/ (~95% size reduction)"
