# BaseMod Setup Instructions

## Prerequisites
1. BaseMod must be installed in Slay the Spire's mods directory
2. The BaseMod console must be running (accessible in-game with Ctrl+Shift+M or equivalent)

## Configuration

Edit `rs/machine/game.py` in the `__add_initial_buffs()` method (lines ~100-111):

```python
def __add_initial_buffs(self):
    """Use BaseMod console commands to add maxhp and relics at run start."""
    max_hp_to_add = 50                                    # Change this number
    relics_to_add = ["Akabeko", "Armored Chest"]         # Change these relic IDs
    
    if max_hp_to_add > 0:
        self.__send_silent_command(f"maxhp add {max_hp_to_add}")
        self.run_max_hp_gained = max_hp_to_add
    
    for relic in relics_to_add:
        self.__send_silent_command(f"relic add {relic}")
        self.run_relics_added.append(relic)
```

## Finding Relic Names
To see all available relic IDs, type in the BaseMod console during a run:
```
relic list
```

Common relic IDs:
- `Akabeko` - Increases gold by 8%
- `Armored Chest` - Adds 1 strength when obtained
- `Bottle of Limoncello` - Starts combat with 1 strength
- `Bronze Scales` - Reduces damage taken by 25% every other turn
- `Burning Blood` - Heal 6 HP when defeating an enemy
- `Potion Belt` - Increases max potion slots by 2
- `Gambling Chip` - Chest rewards give additional items
- `Tough Bandages` - Heal 6 HP when entering a new room
- `Reckless Charge` - Reduce strength cost of cards by 1
- `Shuriken` - Gain 1 strength whenever you play an Attack
- `Snecko Eye` - Draw 2 extra cards
- `Tingsha` - Deal 4 damage to a random enemy at end of turn
- `Transformation` - Gain 1 strength whenever you upgrade a card

## How It Works

1. When `game.start()` is called, it initializes the game
2. After the game state is established, `__add_initial_buffs()` automatically runs
3. BaseMod console commands are sent silently (no logging output)
4. MaxHP increase and relics are added before the first turn
5. The values are tracked and logged at run end in `run_history.log`

## Logging

Run results now include:
- `MaxHPGained`: The total HP added via BaseMod
- `RelicsAdded`: List of relic IDs that were added

Example log entry:
```
Seed:..., Floor:32, Score:9999, Strat: PEACEFUL_PUMMELING, MaxHPGained:50, RelicsAdded:Akabeko,Armored Chest, DiedTo: ...
```

## Troubleshooting

### Commands not executing
- Ensure BaseMod is properly installed and active
- Check that relic names are spelled correctly (case-sensitive)
- Verify that maxhp value is a valid integer

### Relic add fails
- Some relics may be restricted from being added via console (e.g., starter relics)
- Use `relic list` to verify the exact ID
- Try a different relic if one fails

### Performance
- Using `__send_silent_command()` keeps output clean but doesn't log the responses
- If you need debugging, change to `__send_command()` temporarily
