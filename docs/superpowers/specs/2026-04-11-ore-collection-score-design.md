# Ore Collection & Persistent Score Design

## Overview

When ores spawn after rock destruction, the player can walk over them to collect. Each ore grants points based on type. The score persists across levels via an autoload singleton.

## Point Values

| Ore    | Points |
|--------|--------|
| Gold   | 3      |
| Iron   | 2      |
| Tin    | 1      |
| Coal   | 1      |
| Solar  | 1      |

## Architecture

### New Files

- `assets/scripts/game_state.gd` — Autoload singleton

### Modified Files

- `scenes/coal.tscn` — add `collected` signal
- `scenes/gold.tscn` — add `collected` signal
- `scenes/iron.tscn` — add `collected` signal
- `scenes/solar.tscn` — add `collected` signal
- `scenes/tin.tscn` — add `collected` signal
- `scenes/level.tscn` — add score UI Label
- `assets/scripts/level.gd` — handle ore collection

### Flow

1. Ore spawns (via rock destruction) with fade-in animation
2. Player body enters ore collision → ore emits `collected(point_value)` signal
3. Level handler calls `GameState.add_score(value)`, then `ore.queue_free()`
4. UI label at top-left updates to show current score

## Components

### GameState (Autoload: `res://assets/scripts/game_state.gd`)

```
score: int (default 0)
add_score(points: int)
reset_score()
```

Persists for the entire game session. GameState singleton is always available via `GameState` from any script.

### Ore Scenes (Area2D)

Each ore (coal, gold, iron, solar, tin):
- Has `collected(point_value: int)` signal
- Emits signal when player's body enters its collision shape
- Point value passed along with the signal

### Level (`scenes/level.tscn` + `assets/scripts/level.gd`)

- Adds a `Label` node at top-left (e.g., `MarginContainer/ ScoreLabel`)
- Label shows `"Score: {GameState.score}"`
- Connects to all ore `collected` signals in the level
- On collection: calls `GameState.add_score(points)`, queues ore free

## UI Label

- Position: top-left corner, small offset (e.g., position `Vector2(4, 4)`)
- Format: `"Score: 0"` updated after each collection
- Uses default font (no custom font required for MVP)

## Signal Connection

Since ores are spawned dynamically at runtime (`ore_scenes[ore_name].instantiate()`), the Level script must connect to each newly-spawned ore's `collected` signal immediately after instantiation.
