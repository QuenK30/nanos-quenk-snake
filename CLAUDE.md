# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **NanosWorld game-mode package** — a 3D Snake game. It is written in Lua and runs inside the [nanos world](https://nanos.world) game engine. The package name is `nanos-quenk-snake`, version `1.0.8`, authored by QuenK.

There is no build step, test runner, or linter. Development consists of editing Lua files and reloading the package within a running nanos world server (`Package.Reload()` in the server console, or restarting the server).

The asset pack dependency is named `snake` and must be present on the server (`assets_requirements = ["snake"]` in [Package.toml](Package.toml)).

## Architecture

The package follows nanos world's standard three-context split:

| Context | Entry point | Responsibility |
|---|---|---|
| `Shared/` | [Shared/Index.lua](Shared/Index.lua) | Loaded on both server and client. Defines direction constants (`PLAYER_DIR_LEFT/RIGHT`), requires `SnakePlayer.lua` (extends `Player`) and `SnakeClass.lua` (inherits `StaticMesh`). |
| `Server/` | [Server/Index.lua](Server/Index.lua) | Game logic: spawns snakes on player join, handles food timers, collision with food/other snakes, scoring, kill/respawn. |
| `Client/` | [Client/Index.lua](Client/Index.lua) | HUD canvas (score + leaderboard), camera tracking. |

### Key types

- **`SnakeClass`** ([Server/SnakePlayer.lua](Server/SnakePlayer.lua)) — inherits `StaticMesh`. Represents the snake head. Owns a `body_parts` table of `StaticMesh` tail segments. Drives movement on every `Server.Tick`: moves forward along its right-vector, turns left/right via `_direction`, and interpolates body parts toward the preceding segment with `NanosMath.VInterpTo` / `NanosMath.RInterpTo`.

- **`Player` extension** ([Shared/SnakePlayer.lua](Shared/SnakePlayer.lua)) — adds `Player:GetControl()`, which reads the `"controlsnake"` value set on the player to retrieve their `SnakeClass` head.

- **Food** ([Server/Food.lua](Server/Food.lua)) — `StaticMesh` using `snake::SM_Mushroom`, spawned at random XY within `MAP_SIZE` bounds. A `Trigger` box attached to the snake head detects `BeginOverlap` to consume food or kill the player.

### Client→Server event flow

```
Client key press (Q/D)
  → Events.CallRemote("Snake:KeyPress", PLAYER_DIR_LEFT/RIGHT)
    → Server: sets eSnake._direction
Client key release
  → Events.CallRemote("Snake:KeyRelease", dir)
    → Server: clears eSnake._direction if it matches
```

### Configuration

[Shared/Config.lua](Shared/Config.lua) defines a single global:
```lua
MAP_SIZE = 5000  -- half-extents used for random food spawn bounds
```
`Food.lua` requires this file explicitly; adjust `MAP_SIZE` to match your map asset dimensions.

## nanos world API notes

- `Package.Require(file)` loads a file relative to the current context directory.
- `StaticMesh.Inherit("ClassName")` creates a custom class that extends `StaticMesh`.
- `Entity:SetValue(key, value, broadcast)` — when `broadcast = true`, the value is replicated to all clients.
- `Timer.SetTimeout(fn, ms)` / `Timer.ClearTimeout(handle)` for one-shot timers.
- `Events.CallRemote` / `Events.SubscribeRemote` cross the client↔server boundary.
- `NanosMath.VInterpTo` / `NanosMath.RInterpTo` for smooth interpolation.
