# Slay the Spire Bot Stats Dashboard

## Setup (Private Repo + Public Pages)

1. **Clone your private repo:**
   ```bash
   # snucko/spire (PRIVATE)
   git clone https://github.com/snucko/spire.git
   cd spire
   ```

2. **Copy files from this repo:**
   ```bash
   cp <path-to-original>/stats_generator.py .
   cp <path-to-original>/docs/index.html docs/
   cp <path-to-original>/.github/workflows/generate-stats.yml .github/workflows/
   cp -r <path-to-original>/logs/ ./logs/
   ```

3. **Generate initial stats:**
   ```bash
   python3 stats_generator.py
   # Creates docs/stats.json
   ```

4. **Push to private repo:**
   ```bash
   git add .
   git commit -m "feat: add stats dashboard"
   git push
   ```

5. **Deploy via Cloudflare Pages (FREE for private repos):**
   - Go to Cloudflare Dashboard → Pages
   - Click "Create a project" → "Connect to Git"
   - Select `snucko/spire` (private repo works!)
   - Build command: `python3 stats_generator.py`
   - Build output directory: `docs`
   - Deploy!
   - Public URL: `https://spire.<your-cloudflare-domain>.pages.dev`

**Note:** GitHub Pages requires GitHub Pro for private repos. Cloudflare Pages is FREE and works with private repos.

## Features

✅ **5226+ runs tracked**
- Win rates by strategy: PEACEFUL_PUMMELING 36%, SHIVS_AND_GIGGLES 33%, PWNDER_MY_ORBS 38%
- Average scores, high/low scores
- Filter by: strategy, seed, score range

✅ **Auto-updates every 6 hours**

✅ **Searchable stats table**
- Last 500 runs displayed
- Sort-friendly format
- Boss/elite tracking

## Files

- `stats_generator.py` - Parses `logs/run_history.log` → `stats.json`
- `docs/index.html` - Dashboard (no backend needed)
- `docs/stats.json` - Generated data (~1.7MB for 5226 runs)
- `.github/workflows/generate-stats.yml` - Auto-update workflow

## Keeping Stats in Sync

**Option 1: Push logs from your bot machine**
```bash
# From your bot directory after runs complete
git add logs/run_history.log
git commit -m "chore: update run history"
git push
# GitHub Actions automatically regenerates stats.json
```

**Option 2: Manual push to private repo**
```bash
# Copy latest logs to your private repo and push
# Stats regenerate automatically via GitHub Actions
```

**Option 3: Sync via cron job**
```bash
# Set up a cron on your bot machine to push logs periodically
*/6 * * * * cd /path/to/bottled_ai && git pull && cp ../logs/run_history.log . && git add logs/ && git commit -m "auto: update stats" && git push
```

## Security

✅ **Repo is PRIVATE** - No one sees your code or logs  
✅ **Pages are PUBLIC** - Everyone sees aggregated stats  
✅ **GitHub Actions handles updates** - No manual work needed  
✅ **Cloudflare caches** - Further protects repo URL
