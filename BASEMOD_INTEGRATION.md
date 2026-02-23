# BaseMod Integration Guide

## Overview
BaseMod provides dev console commands that can be sent through the game client. To integrate BaseMod for auto-adding maxhp and relics, you'll use the console commands: `maxhp add <amount>` and `relic add <relic_name>`.

## Available BaseMod Commands

### MaxHP Commands
```
maxhp add <amount>      # Increase max HP
maxhp lose <amount>     # Decrease max HP
```

### Relic Commands
```
relic add <relic_name>  # Add a relic
relic list              # List all available relics
relic remove <relic_name>
```

## Integration Steps

### 1. Modify `Game.start()` in `/rs/machine/game.py`

Add initialization for tracking maxhp and relics:

```python
def start(self, seed: str = ""):
    self.the_bots_memory_book.set_new_game_state()
    self.run_elites = []
    self.last_elite = ""
    self.run_bosses = []
    self.last_boss = ""
    self.run_max_hp_gained = 0  # NEW
    self.run_relics_added = []   # NEW
    
    start_message = f"start {self.strategy.character.value}"
    if seed:
        start_message += " 0 " + seed
    self.__send_setup_command(start_message)
    
    # Auto-add initial maxhp and relics using BaseMod console
    self.__add_initial_buffs()  # NEW
    
    state_seed = get_seed_string(self.last_state.game_state()['seed'])
    init_run_logging(state_seed)
    self.__send_command("choose 0")

def __add_initial_buffs(self):  # NEW METHOD
    """Use BaseMod console to add maxhp and relics"""
    max_hp_to_add = 50  # Configure as needed
    relics_to_add = ["Akabeko", "Armored Chest"]  # Configure relic names
    
    # Add maxhp
    if max_hp_to_add > 0:
        self.__send_command(f"maxhp add {max_hp_to_add}")
        self.run_max_hp_gained = max_hp_to_add
    
    # Add relics
    for relic in relics_to_add:
        self.__send_command(f"relic add {relic}")
        self.run_relics_added.append(relic)
```

### 2. Update `Game.run()` to pass new tracking data

Modify the game over handler call:

```python
if self.game_over_handler.can_handle(self.last_state):
    commands = self.game_over_handler.handle(
        self.last_state, 
        self.run_elites, 
        self.run_bosses, 
        self.strategy.name,
        self.run_max_hp_gained,    # NEW
        self.run_relics_added      # NEW
    )
    for command in commands:
        self.__send_command(command)
    break
```

### 3. Update `DefaultGameOverHandler` in `/rs/machine/default_game_over.py`

Modify the handle method signature and logging:

```python
def handle(self, state: GameState, elites: list, bosses: list, strategy: str, max_hp_gained: int = 0, relics_added: list = None) -> list[str]:
    if relics_added is None:
        relics_added = []
    
    log_run_results(state, elites, bosses, strategy, max_hp_gained, relics_added)
    return ["return"]
```

### 4. Update logger in `/rs/helper/logger.py`

Enhance `log_run_results()` to include maxhp and custom relics:

```python
def log_run_results(state: GameState, elites: list, bosses: list, strategy: str, max_hp_gained: int = 0, relics_added: list = None):
    if relics_added is None:
        relics_added = []
    
    score = state.get_player_score()
    floor = state.get_player_floor()
    relics = state.get_relics()
    
    log_to_run(f"Score: {score}")
    log_to_run(f"Floor: {floor}")
    log_to_run(f"Max HP Gained: {max_hp_gained}")
    log_to_run(f"Relics Added: {', '.join(relics_added)}")
    
    # Log all relics (existing code)
    if relics:
        log_to_run(f"Relics in play:")
        for relic_id, count in relics.items():
            log_to_run(f"  {relic_id}: {count}")
    
    log_to_run(f"Elites defeated: {', '.join(elites)}")
    log_to_run(f"Boss defeated: {bosses[-1] if bosses else 'None'}")
```

## Configuration

To configure which relics and how much maxhp to add per run:

1. Edit the `__add_initial_buffs()` method in `game.py`
2. Change `max_hp_to_add` value
3. Update the `relics_to_add` list with actual relic names

### Finding Relic Names
Run `relic list` in the BaseMod console to see all available relic names that can be used with `relic add`.

## Example Usage

```python
# In game.py __add_initial_buffs():
max_hp_to_add = 100
relics_to_add = ["Gambling Chip", "Potion Belt", "Tough Bandages"]
```

## Notes

- BaseMod console commands are sent through the same Client.send_message() interface
- Commands execute immediately after the game starts, before the first turn
- Make sure to use correct relic IDs (can be found in BaseMod console with `relic list`)
- The modified data is tracked throughout the run and logged at the end
