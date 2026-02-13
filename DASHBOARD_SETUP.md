# Slay the Spire Bot - Stats Dashboard Complete Setup

## Overview

Analytics dashboard for tracking Slay the Spire AI bot performance across 5000+ runs. Private GitHub repo, public Vercel site with custom domain.

**Live site:** https://spire-eta.vercel.app (also spire.tivnan.net)  
**GitHub:** https://github.com/snucko/spire (private)  
**Domain:** spire.tivnan.net (via Cloudflare DNS)

## Architecture

```
bottled_ai (bot code, private)
  ├── logs/
  │   ├── run_history.log (current runs)
  │   ├── run_history.log.gz (compressed backup)
  │   └── runs/*.log → *.log.gz (individual compressed)
  ├── stats_generator.py (parser)
  └── sync_stats.sh (cron script)
              ↓
         /tmp/spire (GitHub repo)
              ↓
         GitHub (private repo)
              ↓
         Vercel (auto-deploys)
              ↓
         spire-eta.vercel.app + spire.tivnan.net
```

## Key Files

### In bot repo (`bottled_ai/`)

| File | Purpose |
|------|---------|
| `stats_generator.py` | Parses run_history.log → stats.json |
| `sync_stats.sh` | Compresses logs, pushes to GitHub, deletes local copies |
| `docs/index.html` | Web dashboard (no backend needed) |
| `docs/stats.json` | Generated stats (auto-created by parser) |

### In spire repo (`/tmp/spire`)

| File | Purpose |
|------|---------|
| `stats_generator.py` | Same parser (handles .gz files) |
| `docs/index.html` | Dashboard |
| `docs/stats.json` | Current stats |
| `logs/run_history.log.gz` | Compressed archive from bot |
| `.github/workflows/generate-stats.yml` | Auto-regenerate on push |
| `sync_stats.sh` | Same sync script |

## How It Works

### 1. Bot Runs & Logs
- Bot writes runs to `logs/run_history.log`
- Each line: `Seed:XXXXX, Floor:XX, Score:XXX, Strat:XXX, DiedTo:..., Bosses:..., Elites:..., Relics:...`

### 2. Parsing (stats_generator.py)
```python
- Reads logs/run_history.log or logs/run_history.log.gz
- Extracts: seed, floor, score, strategy, died_to, won, bosses, elites, relics, date
- Calculates: win rates, avg scores, high/low scores by strategy
- Outputs: docs/stats.json (5000+ runs = ~1.7MB)
```

### 3. Sync to GitHub (sync_stats.sh)
```bash
1. Compress run_history.log → run_history.log.gz
2. Compress all logs/runs/*.log → *.log.gz (95% reduction)
3. Push run_history.log.gz to GitHub
4. Delete local uncompressed copies
5. Keeps compressed .gz files locally for archival
```

### 4. Vercel Deployment
- Watches `/tmp/spire` repo
- On push: runs `python3 stats_generator.py`
- Deploys `docs/` folder as static site
- Auto-publishes to spire-eta.vercel.app

### 5. Dashboard (index.html)
- Loads stats.json via fetch()
- Displays:
  - Strategy cards (win rate %, wins, avg score)
  - Runs table with: Date, Seed, Strategy, Result, Floor, Score, Bosses
  - Filters: by strategy, seed search, score range
  - Last 500 runs shown (most recent first)

## Setup Checklist

- [x] Created private GitHub repo: `snucko/spire`
- [x] Connected to Vercel
- [x] Added custom domain: `spire.tivnan.net` (Cloudflare DNS)
- [x] Stats generator parses logs → JSON
- [x] Dashboard displays stats with filters
- [x] Sync script compresses & archives locally
- [x] Cron job runs every 6 hours
- [x] Date column added to runs table
- [x] Individual run files compressed locally

## Usage

### Manual Sync (test or immediate)
```bash
cd "/Users/unknown1/Library/Application Support/Steam/steamapps/common/SlayTheSpire/SlayTheSpire.app/Contents/Resources/bottled_ai"
./sync_stats.sh
```

**Output:**
- Compresses 5000+ run files → ~95% smaller
- Pushes run_history.log.gz to GitHub
- Vercel auto-rebuilds dashboard
- Deletes local uncompressed copies
- Keeps .gz files for archival

### Automatic Sync (Cron)
```bash
# Runs every 6 hours at top of hour
0 */6 * * * cd "/Users/unknown1/Library/Application Support/Steam/steamapps/common/SlayTheSpire/SlayTheSpire.app/Contents/Resources/bottled_ai" && ./sync_stats.sh >> ~/spire-sync.log 2>&1
```

**View logs:**
```bash
tail -f ~/spire-sync.log
```

## Space Management

### Before Sync
- `logs/run_history.log`: 1.6MB
- `logs/runs/`: 42GB (5286 files)
- **Total: ~42GB**

### After Sync
- `logs/run_history.log.gz`: 220KB
- `logs/runs/*.log.gz`: 884MB (5286 compressed)
- **Total: ~900MB (97% reduction)**

### GitHub Size
- Only `run_history.log.gz` pushed (220KB)
- Individual runs stay local (not pushed - too large)

## DNS Setup (Cloudflare)

**Domain:** tivnan.net  
**Subdomain:** spire  

1. Vercel gives CNAME: `cname.vercel.com`
2. In Cloudflare DNS add:
   - Type: CNAME
   - Name: spire
   - Target: cname.vercel.com
   - Proxy: Proxied (orange cloud)
3. Wait 5-10min for propagation
4. `spire.tivnan.net` → Vercel site

## Monitoring

### Check Dashboard
```bash
# Live at
open https://spire-eta.vercel.app
open https://spire.tivnan.net
```

### Check Sync Log
```bash
tail -50 ~/spire-sync.log
```

### Check GitHub
```bash
# Verify last commit
cd /tmp/spire && git log --oneline | head -5

# Verify file size
ls -lh /tmp/spire/logs/run_history.log.gz
```

### Check Disk Space
```bash
du -sh "/Users/unknown1/Library/Application Support/Steam/steamapps/common/SlayTheSpire/SlayTheSpire.app/Contents/Resources/bottled_ai/logs"
```

## Troubleshooting

### Dashboard not updating?
1. Check cron ran: `tail ~/spire-sync.log`
2. Manual push: `./sync_stats.sh`
3. Verify GitHub: `cd /tmp/spire && git log --oneline`
4. Vercel rebuilds automatically - check deployment status

### Disk space still high?
- Run script: `./sync_stats.sh`
- Check: `ls -lh logs/ | grep -v ".gz"`
- Delete any uncompressed: `find logs -name "*.log" ! -name "*.gz" -delete`

### Stats not parsing?
```bash
# Test parser
python3 stats_generator.py

# Check output
head -20 docs/stats.json
```

### Can't push to GitHub?
```bash
# Verify git config
git config user.email  # Should be stivnan@gmail.com
git config user.name   # Should be Shawn

# Manually push
cd /tmp/spire && git push
```

## Key Stats (as of 2026-02-13)

- **Total runs:** 5,228
- **Top strategies:**
  - PEACEFUL_PUMMELING_HEART: 934 runs, 26.9% WR
  - SHIV_THE_HEART: 1085 runs, 18.5% WR
  - REQUESTED_STRIKE_HEART: 1820 runs, 5.8% WR
- **High scores:** 800+ (SHIVS_AND_GIGGLES)
- **Avg score:** 300-560 pts depending on strat
- **Data size:** 5,228 runs in 1.7MB JSON

## Future Improvements

- [ ] Add more stats: avg gold, items collected, win rate by boss
- [ ] Historical trends (win rate over time)
- [ ] Heatmap: strategy performance by run number
- [ ] Export: CSV/JSON for external analysis
- [ ] Compare: strategy performance metrics
- [ ] Filter by multiple strategies

## Related Files

- Bot main code: `main.py`
- Bot strategies: `rs/ai/*/`
- Bot logger: `rs/helper/logger.py` (writes to logs/)
- Dashboard source: `docs/index.html`
- Parser source: `stats_generator.py`
- Sync script: `sync_stats.sh`
- Cron config: `crontab -l`

## Contact / Notes

- Dashboard: https://spire-eta.vercel.app
- GitHub: https://github.com/snucko/spire
- Domain: spire.tivnan.net
- Auto-sync: Every 6 hours via cron
- Last updated: 2026-02-13
