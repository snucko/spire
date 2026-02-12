#!/usr/bin/env python3
"""Parse run_history.log and generate stats JSON for dashboard."""

import json
import re
import gzip
from pathlib import Path
from collections import defaultdict
from datetime import datetime

def parse_run_line(line: str) -> dict | None:
    """Parse a single run line from log file."""
    if not line.startswith("Seed:"):
        return None
    
    run = {}
    
    # Seed
    match = re.search(r'Seed:(\w+)', line)
    if match:
        run['seed'] = match.group(1)
    
    # Floor
    match = re.search(r'Floor:(\d+)', line)
    if match:
        run['floor'] = int(match.group(1))
    
    # Score
    match = re.search(r'Score:(\d+)', line)
    if match:
        run['score'] = int(match.group(1))
    
    # Strategy
    match = re.search(r'Strat: (\w+)', line)
    if match:
        run['strategy'] = match.group(1)
    
    # DiedTo
    match = re.search(r'DiedTo: ([^,]*?)(?:, Bosses:|$)', line)
    if match:
        died_to = match.group(1).strip()
        run['died_to'] = died_to if died_to and died_to != "N/A" else None
    else:
        run['died_to'] = None
    
    # Win status
    run['won'] = run['died_to'] is None and run.get('floor') == 51
    
    # Bosses
    match = re.search(r'Bosses: ([^E]*?)(?:Elites:|$)', line)
    if match:
        bosses_str = match.group(1).strip()
        run['bosses'] = [b.strip() for b in bosses_str.split(',') if b.strip()]
    
    # Elites
    match = re.search(r'Elites: ([^R]*?)(?:Relics:|$)', line)
    if match:
        elites_str = match.group(1).strip()
        run['elites'] = [e.strip() for e in elites_str.split(',') if e.strip()]
    
    # Relics
    match = re.search(r'Relics: (.*?)(?:, Extraordinary|$)', line)
    if match:
        relics_str = match.group(1).strip()
        run['relics'] = [r.strip() for r in relics_str.split(',') if r.strip()]
    
    return run if run.get('seed') else None

def load_log_file() -> list[str]:
    """Load log file, handling both compressed and uncompressed."""
    log_path = Path('logs/run_history.log')
    log_gz_path = Path('logs/run_history.log.gz')
    
    lines = []
    
    # Try gzip first
    if log_gz_path.exists():
        with gzip.open(log_gz_path, 'rt') as f:
            lines.extend(f.readlines())
    
    # Also read uncompressed if exists
    if log_path.exists():
        with open(log_path, 'r') as f:
            lines.extend(f.readlines())
    
    return lines

def generate_stats(runs: list[dict]) -> dict:
    """Generate aggregate statistics."""
    if not runs:
        return {}
    
    stats = {
        'total_runs': len(runs),
        'generated_at': datetime.now().isoformat(),
        'by_strategy': defaultdict(lambda: {
            'runs': 0,
            'wins': 0,
            'avg_floor': 0,
            'avg_score': 0,
            'win_rate': 0,
            'high_score': 0,
            'low_score': float('inf')
        })
    }
    
    for run in runs:
        strategy = run.get('strategy', 'Unknown')
        s = stats['by_strategy'][strategy]
        s['runs'] += 1
        if run['won']:
            s['wins'] += 1
        s['avg_floor'] += run.get('floor', 0)
        s['avg_score'] += run.get('score', 0)
        s['high_score'] = max(s['high_score'], run.get('score', 0))
        s['low_score'] = min(s['low_score'], run.get('score', 0))
    
    # Calculate percentages and averages
    for strategy, s in stats['by_strategy'].items():
        s['win_rate'] = round((s['wins'] / s['runs'] * 100) if s['runs'] > 0 else 0, 1)
        s['avg_floor'] = round(s['avg_floor'] / s['runs'], 1) if s['runs'] > 0 else 0
        s['avg_score'] = round(s['avg_score'] / s['runs'], 1) if s['runs'] > 0 else 0
        s['low_score'] = s['low_score'] if s['low_score'] != float('inf') else 0
    
    stats['by_strategy'] = dict(stats['by_strategy'])
    return stats

def main():
    output_path = Path('docs/stats.json')
    
    # Load log lines
    lines = load_log_file()
    if not lines:
        print("Error: No log files found")
        return
    
    # Parse all runs
    runs = []
    for line in lines:
        run = parse_run_line(line)
        if run:
            runs.append(run)
    
    print(f"Parsed {len(runs)} runs")
    
    # Generate stats
    stats = generate_stats(runs)
    
    # Save runs and stats
    output_path.parent.mkdir(exist_ok=True)
    
    with open(output_path, 'w') as f:
        json.dump({
            'runs': runs,
            'stats': stats
        }, f)
    
    print(f"Saved to {output_path}")
    print(f"\nStats by strategy:")
    for strategy, s in stats['by_strategy'].items():
        print(f"  {strategy}: {s['runs']} runs, {s['win_rate']}% WR, avg {s['avg_score']} pts")

if __name__ == '__main__':
    main()
