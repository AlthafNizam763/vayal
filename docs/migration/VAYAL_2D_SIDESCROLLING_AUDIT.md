# VAYAL — 2D Side-Scrolling Migration Audit Report

**Date:** 2026-10-13  
**Game Title:** VAYAL — A Veyrapuram Story  
**Developer Credit:** Provided by Suppid Games  
**Target Platform:** Android (First), Windows Desktop  
**Target Orientation:** Landscape  
**Migration Branch:** `migration/2d-sidescrolling`  

---

## 1. Executive Summary & Baseline Results

A comprehensive audit was performed before initiating the 2D side-scrolling transformation:
- **Git Branch Status:** Isolated dedicated branch `migration/2d-sidescrolling` created from `main`. Clean working tree.
- **Flutter Framework:** Flutter 3.41.7 • Dart 3.11.5.
- **Automated Test Baseline:** Ran all test suites across the repository. **Result: 119 / 119 tests passing (100% pass rate).**
- **Existing Asset Pipeline:** High-res branding and logos preserved in `assets/branding/`.

---

## 2. Current Architecture & 2D Side-Scrolling Mapping

| Subsystem | Existing Architecture | Status | 2D Side-Scrolling Target Architecture |
|---|---|---|---|
| **Entry Point** | `lib/main.dart` -> `lib/app/vayal_game_root.dart` | Working | Preserve completely. Manages studio intro, main menu, credits, save slot picker, and boots into the active gameplay widget. |
| **Rendering** | Canvas / ThreeJS | Working | Pure 2D Canvas Side-Scrolling Renderer with multi-layered parallax backgrounds (distant mountains, paddy fields, village street trees, foreground mist). |
| **Coordinate System** | $(x, z)$ ground plane with $(y)$ elevation | Working | Pure 2D Cartesian $(worldX, worldY)$ where $X$ is horizontal progression across Veyrapuram and $Y$ is vertical ground elevation/jump height. |
| **Camera** | Orbital / Isometric | Working | Pure 2D Horizontal Tracking Camera with configurable deadzone, smooth easing, and level boundary clamping. |
| **Player Controller** | 8-way directional velocity | Working | 2D Horizontal Side-Scroller Movement (Left/Right walk & sprint, directional flip, grounding detection, interaction prompts). |
| **Story & Missions** | 30 missions across 5 Acts in `MissionData` & `MissionManager` | Fully Implemented | **100% Preserved**. Operates on logical locations, object IDs, NPC triggers, and status flags. Location checks evaluate $X$ position along the street. |
| **Dialogue System** | `DialogueManager`, `DialogueData`, `DialogueView` | Fully Implemented | **100% Preserved**. All trees, moral choices, relationship affinities, and callbacks work out-of-the-box. |
| **Inventory & Economy** | `Inventory`, `ItemData`, `GameState` | Fully Implemented | **100% Preserved**. Items, weapons, rupees ₹, reputation. |
| **Save/Load System** | `SaveManager`, `SaveData` | Fully Implemented | **100% Preserved**. Multi-slot JSON persistence, checkpoints, playtime tracking. |
| **UI & Controls** | Landscape HUD, VirtualControls, Menus | Fully Implemented | **100% Preserved**. Adapted for Left/Right direction buttons and context-sensitive Interact [E] button. |

---

## 3. Visual Style: Pixel-Art / Block-Art Inspired by Provided Reference

Based on the visual reference:
- **Vibrant Blue Skies & Pixelated Cloud Masses:** Layered clouds scrolling slowly in the far background.
- **Majestic Mountain Silhouettes:** Soft blue mist-shrouded mountain range in the deep distance.
- **Rich Lush Kerala Flora:** Dense banyan/palm trees with hanging vines, flowering bushes, wild grass tufts, and stone shrines.
- **Traditional Kerala Village Architecture:** Terracotta-roofed tea stall, Aadi's family house with front porch veranda and wooden entrance door.
- **Aadi Menon Pixel Character:** Distinctive red-brown hair/outfit, travel pack, companion elements, clear directional facing, and step animations.

---

## 4. Phased Implementation Plan

- [x] **Phase 0: Audit & Rollback Preparation** (Dedicated branch `migration/2d-sidescrolling`, test baseline 119/119 verified).
- [ ] **Phase 1: 2D Side-Scrolling Engine Core** (Coordinate system, horizontal tracking camera with parallax background layers, entity model).
- [ ] **Phase 2: Aadi Menon 2D Pixel Character & Movement** (Left/Right walk, sprint, idle breathing, directional flipping, grounding physics).
- [ ] **Phase 3: Veyrapuram Side-Scrolling Village Environment** (Multi-layer parallax: sky/clouds, mountains, paddy fields, village street, Aadi's family home, tea stall, trees, fence).
- [ ] **Phase 4: Homecoming Mission Vertical Slice Integration** (Objective 1: Walk to village crossroad -> Objective 2: Approach family home -> Objective 3: Talk to Meera on veranda with full dialogue choices -> Objective 4: Enter door, checkpoint save).
- [ ] **Phase 5: Automated Testing & Validation** (Unit tests for 2D coordinate transforms, camera clamping, movement physics, Homecoming completion lifecycle).
