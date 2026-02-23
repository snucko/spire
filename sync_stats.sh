#!/bin/bash
# Compress logs and push to spire repo to free up local space

set -e

SPIRE_REPO="/tmp/spire"  # Change to your spire repo path
BOT_LOGS="./logs"

echo "🔄 Syncing logs to spire repo..."

# Create spire directory if needed
mkdir -p "$SPIRE_REPO"

# Regenerate seed_dates.json with new run dates
echo "📝 Updating seed date mappings..."
python3 << 'PYTHON_EOF'
import json
import re
from pathlib import Path

seed_to_date = {}
seed_dates_path = Path('seed_dates.json')

# Load existing
if seed_dates_path.exists():
    with open(seed_dates_path, 'r') as f:
        seed_to_date = json.load(f)

# Extract from run files (find new ones)
runs_dir = Path('logs/runs')
if runs_dir.exists():
    for log_file in runs_dir.glob('*.log*'):
        match = re.match(r'(\d{4})-(\d{2})-(\d{2})', log_file.name)
        if match:
            date_str = f"{match.group(1)}-{match.group(2)}-{match.group(3)}"
            seed_match = re.search(r'--(\w+)\.log', log_file.name)
            if seed_match:
                seed = seed_match.group(1)
                if seed not in seed_to_date:
                    seed_to_date[seed] = date_str

with open(seed_dates_path, 'w') as f:
    json.dump(seed_to_date, f)

print(f"Updated seed_dates.json: {len(seed_to_date)} seeds total")
PYTHON_EOF

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

# Copy seed_dates.json and stats to spire repo
echo "📋 Copying seed_dates.json and stats..."
mkdir -p "$SPIRE_REPO"
cp seed_dates.json "$SPIRE_REPO/" 2>/dev/null || true
cp docs/stats.json "$SPIRE_REPO/docs/" 2>/dev/null || true

# Push to GitHub
echo "📤 Pushing to GitHub..."
cd "$SPIRE_REPO"
git config user.email "$(git config --global user.email)"
git config user.name "$(git config --global user.name)"
git add logs/ seed_dates.json docs/stats.json
git commit -m "chore: sync bot logs and stats $(date +%Y-%m-%d)" || echo "No changes"
git push

# Delete local uncompressed copies to free space
echo "🗑️  Cleaning up uncompressed files..."
rm -f "$BOT_LOGS/run_history.log"
find "$BOT_LOGS/runs" -name "*.log" -type f -delete 2>/dev/null || true

echo "✅ Done! Logs synced to GitHub and compressed locally"
echo "   GitHub: $SPIRE_REPO/logs/run_history.log.gz"
echo "   Local: Compressed .gz files in logs/runs/ (~95% size reduction)"
