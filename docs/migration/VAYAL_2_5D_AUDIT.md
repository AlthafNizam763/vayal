# VAYAL — 2.5D Isometric Migration Audit Report

**Date:** 2026-10-13  
**Game Title:** VAYAL — A Veyrapuram Story  
**Developer Credit:** Provided by Suppid Games  
**Target Platform:** Android (First), Windows Desktop  
**Target Orientation:** Landscape  
**Migration Branch:** `migration/2.5d-isometric`  

---

## 1. Executive Summary & Baseline Results

A thorough audit of the entire codebase was conducted prior to making any architectural changes:
- **Flutter Framework:** Flutter 3.41.7 • Dart 3.11.5 • DevTools 2.54.2
- **Test Suite Baseline:** Ran all 113 unit & widget tests in `test/widget_test.dart`. **Result: 113 / 113 passed (100% pass rate).**
- **Static Analysis:** `lib/` passes with 0 errors. Unused imports/casts in unused experimental files documented.
- **Git State:** Clean branch created `migration/2.5d-isometric` preserving all existing commits on `main`.

---

## 2. Existing Architecture Analysis

| Layer | Current Implementation | Status | Migration Strategy |
|---|---|---|---|
| **Entry Point** | `lib/main.dart` -> `lib/app/app.dart` -> `lib/app/vayal_game_root.dart` | Working | Preserve completely. Controls studio boot screen, save slot picker, credits, and launches the active game viewport. |
| **Rendering** | `three_js: ^0.3.0` (OpenGL/DirectX 3D Canvas via Flutter texture) | Working | Introduce a dedicated 2.5D Isometric Game Engine and Renderer using standard Flutter `CustomPainter` / Canvas with isometric matrix projection, layer buffering, depth-sorted tile rendering, and block-art drawing. |
| **Coordinate System** | 3D Cartesian coordinates $(x, y, z)$ with $(x, z)$ representing horizontal ground plane | Working | Ground plane $(x, z)$ directly maps to Isometric 2.5D coordinates $(isoX, isoY)$. $(y)$ represents height elevation. |
| **Player Controller** | `lib/game/player/player_controller.dart`, `player.dart` | Working | Decouple from ThreeJS mesh hierarchy. Retain ground velocity, collision against `WorldBounds`, stamina, sprint, and state machines. |
| **Camera** | `lib/game/player/player_camera.dart` (3D orbital perspective) | Working | Implement `IsometricCamera` with 2:1 classic dimetric / isometric projection angle, configurable viewport scaling, smooth target interpolation, and boundary clamping. |
| **Story & Missions** | `lib/data/missions/mission_data.dart`, `lib/game/missions/mission_manager.dart` | Fully Implemented (30 missions across 5 Acts) | **Preserve 100%**. Mission system operates purely on logical $(x, z)$ coordinates, interactable IDs, and NPC IDs. |
| **Dialogue System** | `lib/data/dialogue/dialogue_data.dart`, `lib/game/dialogue/dialogue_manager.dart`, `lib/ui/dialogue/` | Fully Implemented | **Preserve 100%**. Fully data-driven with dialogue trees, choices, moral flags, trust metrics, and audio cues. |
| **Save/Load System** | `lib/game/save/save_manager.dart`, `save_data.dart` | Fully Implemented | **Preserve 100%**. Supports multi-slot JSON persistence, playtime tracking, inventory serialization, and story checkpoints. |
| **Inventory & Economy** | `lib/game/inventory/inventory.dart`, `lib/data/inventory/item_data.dart` | Fully Implemented | **Preserve 100%**. Manages items, equipment, weapons, collectibles, cash (Rupees), and reputation. |
| **World Collision** | `lib/game/world/world_object.dart`, `world_bounds.dart`, `world_manager.dart` | Fully Implemented | **Preserve 100%**. `WorldBounds` calculates axis-aligned bounding boxes $(minX, maxX, minZ, maxZ)$ and circle overlaps on the ground plane. |
| **UI Overlays** | Dialogue UI, Phone, Dossier/Investigation Board, Pause Menu, Settings, Save Picker, Ending Screen, Credits | Fully Implemented | **Preserve 100%**. Screen-space Flutter widgets remain decoupled from the canvas. |

---

## 3. Working Features (Preserved Assets)

1. **Full 5-Act Story Structure:**
   - Act I: HOME (Missions 1–6)
   - Act II: GHOSTS (Missions 7–12)
   - Act III: BLOOD (Missions 13–18)
   - Act IV: THE TRUTH (Missions 19–24)
   - Act V: VAYAL (Missions 25–30)
2. **Complete Dialogue Trees:** Meera, Diya, Balan, Raghav, Rahu, Devraj.
3. **Investigation & Evidence Board System:** Clues, pins, connection deductions.
4. **Phone System & Contacts:** Smartphone messaging, unread notifications, bank alerts.
5. **Full Inventory & Economy:** Medkits, lockpicks, weapons, tools, currency in ₹ INR.
6. **Save Management:** 3 manual slots + autosave checkpointing with JSON schemas.

---

## 4. Systems Requiring Adapters or Replacement

1. **Renderer:**
   - **Current:** `three.ThreeJS` 3D scene builder.
   - **Target:** `IsometricCanvasRenderer` (2.5D Isometric Engine). Renders terrain blocks, buildings, trees, street lamps, vehicles, and characters with depth sorting ($Z$-index based on $x + z$ ground coordinate + layer priority).
2. **Character & NPC Visuals:**
   - **Current:** Procedural ThreeJS box-mesh hierarchies.
   - **Target:** Minecraft-inspired block-art pixel renderers / sprite frames for 4 isometric directions (South-East, South-West, North-East, North-West).
3. **Camera:**
   - **Current:** 3D PerspectiveCamera following player in orbital spherical coords.
   - **Target:** 2.5D Isometric Camera transforming $(x, z)$ logical coordinates into screen pixels $(screenX, screenY)$.

---

## 5. Mathematical Specification for Isometric Projection

To guarantee standard 2:1 pixel isometric projection (dimetric projection commonly referred to in games as 2.5D isometric):

$$\text{screenX} = (\text{worldX} - \text{worldZ}) \cdot \frac{\text{tileWidth}}{2} - \text{cameraX} + \frac{\text{viewportWidth}}{2}$$

$$\text{screenY} = (\text{worldX} + \text{worldZ}) \cdot \frac{\text{tileHeight}}{2} - \text{worldY} \cdot \text{heightScale} - \text{cameraY} + \frac{\text{viewportHeight}}{2}$$

Where:
- $\text{tileWidth} = 64.0$ px
- $\text{tileHeight} = 32.0$ px (exact 2:1 ratio)
- $\text{heightScale} = 32.0$ px per unit elevation
- Depth Sorting Key: $\text{sortKey} = (\text{worldX} + \text{worldZ}) \cdot 1000 + \text{layerPriority}$

---

## 6. Phased Implementation Plan

- [x] **Phase 1: Audit and Baseline Validation** (Complete)
- [ ] **Phase 2: 2.5D Isometric Engine Core** (Coordinate transforms, camera, depth sorting, block/tile graphics engine)
- [ ] **Phase 3: Player Controller & Collision Adapter** (Isometric movement, 4-way block art character, collision check against `WorldManager`)
- [ ] **Phase 4: Veyrapuram Village Prototype** (Aadi's family house, road, paddy fields, tea stall, interactive veranda door)
- [ ] **Phase 5: First Playable Mission — Homecoming** (Start mission, "Go Home" objective, meet Meera, dialogue choice tree, checkpoint save)
- [ ] **Phase 6: Verification & Test Suite Expansion** (Automated tests for isometric math, collision, Homecoming mission lifecycle)
