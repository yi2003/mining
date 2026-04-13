# Ladder - Depth Levels Design

## Overview
A ladder object placed manually in the level that allows the player to transition between vertical mine floors. Each floor is offset vertically, creating the illusion of descending deeper into the mine.

## Files

### New Files
- `scenes/ladder.tscn` - Ladder scene
- `assets/scripts/ladder.gd` - Ladder script

### Modified Files
- `assets/scripts/player.gd` - Add climbing state
- `assets/scripts/level.gd` - Floor management

---

## Ladder Scene (`scenes/ladder.tscn`)

**Structure:**
- `CharacterBody2D` (ladder root)
  - `Sprite2D` - displays `res://assets/images/tileset/ladder.png`
  - `StaticBody2D` (collision layer 2, same as rocks - not collidable with player movement)
  - `Area2D` - overlap detection to trigger climb mode (collision layer 2, mask 3)

**Behavior:**
- Collision is purely for Area2D overlap detection
- Player walks over ladder top to trigger climb prompt (or auto-climb)
- StaticBody does NOT block player movement

**Ladder Properties:**
- `floor_number` (export var): which floor this ladder connects to (0 = surface)

---

## Player Changes (`player.gd`)

**New State:**
- `is_climbing` (bool) - when true, player is on ladder and can move between floors

**Climbing Logic:**
```
When player overlaps ladder Area2D:
  - Enter climbing mode (is_climbing = true)
  - Disable normal movement velocity

When is_climbing and player presses Up:
  - Request floor change DOWN (deeper)
  - Wait for transition to complete

When is_climbing and player presses Down:
  - Request floor change UP (shallower)
  - Wait for transition to complete

When is_climbing and player presses Left/Right:
  - Exit climbing mode
  - Resume normal movement
```

**Floor Transition:**
- Player position remains fixed on screen during transition
- Brief fade-to-black (150ms out, 150ms in) via Level
- On arriving at new floor, player is placed at corresponding ladder exit point

---

## Level Changes (`level.gd`)

**New Properties:**
- `current_floor` (int): starts at 0 (surface), increases as player goes deeper
- `floor_height` (int): viewport height in pixels (180 for this project)
- `world_offset_y` (int): accumulated vertical offset applied to world objects

**New Functions:**
```
change_floor(direction: int):
  - direction = -1 (up/shallower) or +1 (down/deeper)
  - Trigger fade-out
  - Update current_floor
  - Apply world_offset_y
  - Trigger fade-in
```

**World Offset:**
- All world objects (rocks, ores, ladders) are children of world container node
- Container is offset by world_offset_y
- Player stays at fixed screen position (world moves around them)

**Floor Boundaries:**
- Minimum floor = 0 (surface)
- Maximum floor = maybe 3-5 (configurable)

---

## Ladder Script (`assets/scripts/ladder.gd`)

```gdscript
extends CharacterBody2D

@export var floor_number: int = 0
# floor_number: which floor this ladder sits on (0 = surface)

signal player_entered_ladder(ladder)
signal player_exited_ladder()

func _on_Area2D_body_entered(body):
    if body.name == "Player":
        emit_signal("player_entered_ladder", self)

func _on_Area2D_body_exited(body):
    if body.name == "Player":
        emit_signal("player_exited_ladder")
```

---

## Visual Details

**Ladder Sprite:**
- Source: `res://assets/images/tileset/ladder.png`
- Scaled to fit grid (likely 16x32 or 32x48 in world space)

**Floor Transition:**
- Fade to black: 150ms ease-out
- Hold: 50ms
- Fade in: 150ms ease-in
- Total: 350ms

**Camera:**
- Follows player normally
- Player appears at same screen Y when emerging from ladder on new floor

---

## Implementation Order

1. Create `ladder.tscn` scene with sprite, static body, area
2. Create `ladder.gd` script with signals
3. Add floor system to `level.gd` (world offset, floor tracking)
4. Modify `player.gd` to add climbing state and floor change requests
5. Connect ladder signals to level for floor transitions
6. Test with 2 ladders on different floors
