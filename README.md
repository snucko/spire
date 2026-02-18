# Slay the Spire Bot - Stats Dashboard

Real-time analytics dashboard for your Slay the Spire AI bot runs.

**Live stats:** https://spire.<your-domain>.pages.dev

## Quick Start

```bash
# Generate stats from logs
python3 stats_generator.py

# View locally
open docs/index.html
```

## Files

- `stats_generator.py` - Parses `logs/run_history.log` → `docs/stats.json`
- `docs/index.html` - Web dashboard (no server needed)
- `docs/stats.json` - Auto-generated stats (1.7MB for 5000+ runs)
- `.github/workflows/generate-stats.yml` - Auto-update on new logs

## Setup

See [SETUP.md](SETUP.md) for full Cloudflare Pages deployment guide.

## Features

✅ 5000+ runs tracked  
✅ Win rates by strategy  
✅ Search by seed  
✅ Filter by score  
✅ Auto-updates every 6 hours
rebuilt at Wed Feb 18 10:04:00 EST 2026
