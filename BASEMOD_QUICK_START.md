# BaseMod Integration - Quick Start

## Status
✅ Installation complete. BaseMod integration is active.

## To Enable Custom MaxHP and Relics

Edit `rs/machine/game.py` line 103-104:

```python
max_hp_to_add = 50                                    # Change this
relics_to_add = ["Akabeko", "Armored Chest"]         # Change this
```

## Example Configurations

**Aggressive Setup:**
```python
max_hp_to_add = 100
relics_to_add = ["Shuriken", "Inflamed", "Snecko Eye", "Gambling Chip"]
```

**Defensive Setup:**
```python
max_hp_to_add = 50
relics_to_add = ["Bronze Scales", "Potion Belt", "Tough Bandages"]
```

**No Buffs:**
```python
max_hp_to_add = 0
relics_to_add = []
```

## Find Relic IDs

During a game run, open BaseMod console and type:
```
relic list
```

## Logs

Results automatically logged to:
- `logs/run_history.log` - Contains MaxHPGained and RelicsAdded

## Files Modified

- `rs/machine/game.py` - Adds buffs at run start
- `rs/machine/default_game_over.py` - Tracks buff values
- `rs/helper/logger.py` - Logs buff values at run end

See BASEMOD_SETUP.md for detailed configuration options.
