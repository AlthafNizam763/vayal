# VAYAL — 2.5D Isometric Migration Plan & Progress Log

**Branch:** `migration/2.5d-isometric`  
**Current Status:** Phase 2 in progress  

---

## Completed Milestones

### Phase 1: Audit and Environment Protection
- Checked Git status, established new isolated branch `migration/2.5d-isometric`.
- Ran baseline automated test suite: 113 / 113 tests passed.
- Catalogued all narrative, mission, inventory, dialogue, audio, and save system dependencies.
- Verified that all story systems (30 missions, 5 acts, dialogue trees) operate purely on logical coordinates $(x, z)$ and IDs, meaning they can be migrated with 100% data preservation.
- Created `docs/migration/VAYAL_2_5D_AUDIT.md`.

---

## Active Roadmap

- [x] **Phase 1: Inspection & Audit**
- [ ] **Phase 2: 2.5D Isometric Engine Architecture**
  - Create `IsometricCoords`: Screen $\leftrightarrow$ World bidirectional conversion.
  - Create `IsometricCamera`: Smooth easing, zoom, boundary clamping.
  - Create `IsometricRenderEntity` & Depth Sorter.
  - Create `IsometricBlockPainter`: Minecraft-inspired Kerala block-art terrain, roads, houses, foliage.
- [ ] **Phase 3: Block-Art Character & Controller Adapter**
  - Aadi Menon Minecraft-inspired isometric block figure (4 directions: SE, SW, NE, NW).
  - Walk, idle, run, and interact animation ticks.
  - Retain existing virtual joystick and keyboard (WASD / Arrows).
- [ ] **Phase 4: Veyrapuram Isometric Village Area**
  - Village crossroad, paddy fields, palm trees, stone fences.
  - Aadi's family house with front porch veranda and interactive front door.
  - Meera NPC placed at veranda.
- [ ] **Phase 5: First Playable Mission — Homecoming Vertical Slice**
  - Objective 1: Reach crossroad.
  - Objective 2: Approach family house.
  - Objective 3: Speak with Meera (dialogue tree with moral choices).
  - Objective 4: Enter house door, trigger checkpoint save.
- [ ] **Phase 6: Quality Assurance & Automated Tests**
  - Unit tests for isometric coordinate conversion and depth sorting.
  - Unit tests for player movement, collision against `WorldBounds`.
  - Integration tests for Homecoming mission completion and persistence.
