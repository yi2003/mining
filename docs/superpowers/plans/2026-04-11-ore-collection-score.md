# Ore Collection & Persistent Score Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add ore collection with collision detection so player picking up ores increases score, displayed top-left, persisting across levels.

**Architecture:** GameState autoload holds the score. Each ore has its own script with `collected` signal. Level orchestrates collection and displays the score label.

**Tech Stack:** Godot 4.6, GDScript

---

## File Structure

- Create: `assets/scripts/game_state.gd` — Autoload singleton
- Create: `assets/scripts/ore_gold.gd` — Script for gold ore (3 pts)
- Create: `assets/scripts/ore_iron.gd` — Script for iron ore (2 pts)
- Create: `assets/scripts/ore_tin.gd` — Script for tin ore (1 pt)
- Create: `assets/scripts/ore_coal.gd` — Script for coal ore (1 pt)
- Create: `assets/scripts/ore_solar.gd` — Script for solar ore (1 pt)
- Modify: `scenes/coal.tscn` — Attach ore_coal.gd script
- Modify: `scenes/gold.tscn` — Attach ore_gold.gd script
- Modify: `scenes/iron.tscn` — Attach ore_iron.gd script
- Modify: `scenes/solar.tscn` — Attach ore_solar.gd script
- Modify: `scenes/tin.tscn` — Attach ore_tin.gd script
- Modify: `scenes/level.tscn` — Add Label for score display
- Modify: `assets/scripts/level.gd` — Connect ore collection, update label

---

## Task 1: Create GameState Autoload

**Files:**
- Create: `assets/scripts/game_state.gd`

- [ ] **Step 1: Write game_state.gd**

```gdscript
extends Node

var score: int = 0

func add_score(points: int) -> void:
    score += points

func reset_score() -> void:
    score = 0
```

- [ ] **Step 2: Commit**

```bash
git add assets/scripts/game_state.gd
git commit -m "feat: add GameState autoload for persistent score

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Create Ore Scripts

**Files:**
- Create: `assets/scripts/ore_gold.gd` (3 pts)
- Create: `assets/scripts/ore_iron.gd` (2 pts)
- Create: `assets/scripts/ore_tin.gd` (1 pt)
- Create: `assets/scripts/ore_coal.gd` (1 pt)
- Create: `assets/scripts/ore_solar.gd` (1 pt)

Each script is nearly identical — only `POINT_VALUE` differs:

**ore_gold.gd:**
```gdscript
extends Area2D

signal collected(points: int)

const POINT_VALUE: int = 3

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        collected.emit(POINT_VALUE)
        queue_free()
```

**ore_iron.gd:**
```gdscript
extends Area2D

signal collected(points: int)

const POINT_VALUE: int = 2

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        collected.emit(POINT_VALUE)
        queue_free()
```

**ore_tin.gd:**
```gdscript
extends Area2D

signal collected(points: int)

const POINT_VALUE: int = 1

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        collected.emit(POINT_VALUE)
        queue_free()
```

**ore_coal.gd:**
```gdscript
extends Area2D

signal collected(points: int)

const POINT_VALUE: int = 1

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        collected.emit(POINT_VALUE)
        queue_free()
```

**ore_solar.gd:**
```gdscript
extends Area2D

signal collected(points: int)

const POINT_VALUE: int = 1

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        collected.emit(POINT_VALUE)
        queue_free()
```

- [ ] **Step 1: Write all 5 ore scripts**

- [ ] **Step 2: Commit**

```bash
git add assets/scripts/ore_gold.gd assets/scripts/ore_iron.gd assets/scripts/ore_tin.gd assets/scripts/ore_coal.gd assets/scripts/ore_solar.gd
git commit -m "feat: add ore scripts with collected signal and point values

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Attach Scripts to Ore Scenes

**Files:**
- Modify: `scenes/coal.tscn` — add `[ext_resource type="Script"]` referencing ore_coal.gd
- Modify: `scenes/gold.tscn` — add `[ext_resource type="Script"]` referencing ore_gold.gd
- Modify: `scenes/iron.tscn` — add `[ext_resource type="Script"]` referencing ore_iron.gd
- Modify: `scenes/solar.tscn` — add `[ext_resource type="Script"]` referencing ore_solar.gd
- Modify: `scenes/tin.tscn` — add `[ext_resource type="Script"]` referencing ore_tin.gd

For each `.tscn` file, add this after the existing `[ext_resource]` block and add `script = ExtResource("X_ore")` to the `root` node:

**gold.tscn** — add as `[ext_resource type="Script"` entry 2, then set `script = ExtResource("2_gold")` on root node:
```
[ext_resource type="Script" uid="uid://???" path="res://assets/scripts/ore_gold.gd" id="2_gold"]
```
Then on the root node line change from:
```
[node name="root" type="Area2D" ...]
```
to:
```
[node name="root" type="Area2D" ...]
script = ExtResource("2_gold")
```

Same pattern for all 5 ore scenes, with different UIDs and resource paths.

- [ ] **Step 1: Modify each ore .tscn to attach its script**

- [ ] **Step 2: Commit**

```bash
git add scenes/coal.tscn scenes/gold.tscn scenes/iron.tscn scenes/solar.tscn scenes/tin.tscn
git commit -m "feat: attach ore scripts to ore scene files

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Add Score Label to Level and Connect Ore Collection

**Files:**
- Modify: `scenes/level.tscn` — add Label as first child for score display
- Modify: `assets/scripts/level.gd` — connect ore signals, update label

### level.tscn changes:

Add a `Label` node as the first child of `Level`. Current structure:
```
[gd_scene format=3 uid="uid://dvimrwetk18e0"]
[ext_resource ...]
[node name="Level" type="Node2D" ...]
  Map, YSort, Player
```

Change to:
```
[gd_scene format=3 uid="uid://dvimrwetk18e0"]
[ext_resource ...]
[node name="Level" type="Node2D" ...]
[node name="ScoreLabel" type="Label" parent="." unique_id=...]
offset_left = 4.0
offset_top = 4.0
offset_right = 80.0
offset_bottom = 20.0
text = "Score: 0"
  Map, YSort, Player
```

### level.gd changes:

Add `@onready var score_label = $ScoreLabel`. Add a `_update_score_label()` method and call it. Connect to ore `collected` signals in `spawn_random_ore()`.

New `level.gd` additions:
```gdscript
@onready var score_label = $ScoreLabel

func _update_score_label():
    score_label.text = "Score: " + str(GameState.score)

func _on_Ore_collected(points: int):
    GameState.add_score(points)
    _update_score_label()
```

And in `spawn_random_ore()`, connect after `add_child(ore)`:
```gdscript
ore.collected.connect(_on_Ore_collected)
```

- [ ] **Step 1: Add ScoreLabel to level.tscn**

- [ ] **Step 2: Update level.gd to connect ore signals and update label**

- [ ] **Step 3: Commit**

```bash
git add scenes/level.tscn assets/scripts/level.gd
git commit -m "feat: add score label and ore collection handling in level

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Verification

1. Open the project in Godot editor
2. Run the level — player spawns at (41, 56)
3. Use axe attack (Space) on rocks to destroy them — ores should spawn with drop animation
4. Walk over spawned ores — each ore should disappear and score should increase by its point value
5. Score label should update in top-left corner
6. Verify point values: gold=3, iron=2, tin/coal/solar=1
