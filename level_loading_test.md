# Level Loading System Test

## Implementation Summary

This implementation adds a 3-map progressive loading system to your game where maps load as the player goes deeper via ladders.

## Changes Made

### 1. `assets/scripts/level.gd`
- Added `_on_ladder_entered()` logic to automatically transition to the next floor when a player enters a ladder
- Added guard to prevent floor transitions when already transitioning (`is_transitioning` check)
- Floor counter increments from 0→1→2 as player goes deeper

### 2. `assets/scripts/player.gd`
- Added `is_transitioning` flag to track when level transitions are happening
- Modified `enter_climbing()` to set `is_transitioning = true` to prevent movement during transitions
- Modified `_exit_climbing()` to reset `is_transitioning = false`
- Added logic in `_physics_process()` to freeze movement during transitions

### 3. `assets/scripts/level.gd` (continued)
- Modified `change_floor()` to reset `player.is_transitioning = false` after transition completes
- Added transition guard in `_physics_process()` to prevent ladder input during transitions

## How It Works

1. **Initial State**: Player starts on floor 0 (map.tscn)
2. **Ladder Interaction**: When player enters a ladder on any floor:
   - Player enters climbing mode (freezes movement)
   - If not already at max_floor (3), triggers `change_floor(1)`
3. **Floor Transition**:
   - Fade out screen
   - Load next map (map_2.tscn → map_3.tscn)
   - Clear rocks and ladders from previous floor
   - Reset player start position
   - Fade in screen
4. **Final State**: Player reaches floor 2 (map_3.tscn), max_floor reached

## Key Features

- **Progressive Loading**: Maps load sequentially as player descends
- **Transition Safety**: Prevents input during transitions to avoid glitches
- **Automatic Ladder Placement**: Existing ladder system still works
- **Rock/Ladder Reset**: Each new floor gets fresh rocks and ladders
- **Player Start Positions**: Each map has designated PlayerStart positions

## Usage

The system works automatically - when a player touches a ladder:
- Floor 0 (map.tscn) → Floor 1 (map_2.tscn) → Floor 2 (map_3.tscn)
- Player cannot go below floor 0 or above floor 2 (max_floor = 3)