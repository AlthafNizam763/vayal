import 'sidescroller_coords.dart';
import 'sidescroller_camera.dart';
import 'sidescroller_player.dart';
import 'sidescroller_prop.dart';

/// 2D Side-Scrolling World Scene for Veyrapuram.
class SideScrollerWorldScene {
  final SideScrollingCoords coords = const SideScrollingCoords();
  late final SideScrollingCamera camera;
  late final SideScrollerPlayer player;

  final List<SideScrollerProp> props = [];

  // World bounds in horizontal meters
  final double minX = -10.0;
  final double maxX = 50.0;

  SideScrollerWorldScene() {
    camera = SideScrollingCamera(
      initialX: 0.0,
      minWorldX: minX,
      maxWorldX: maxX,
    );
    // Aadi begins at the village entrance (X = 0)
    player = SideScrollerPlayer(worldX: 0.0, worldY: 0.0);
    camera.snapTo(player.worldX);

    _buildVeyrapuramVillage();
  }

  void _buildVeyrapuramVillage() {
    // 1. Village boundary & entrance signpost (X = 0)
    props.add(const SideScrollerProp(
      id: 'sign_entrance',
      name: 'Veyrapuram Welcome Sign',
      type: SceneryType.villageSignpost,
      worldX: 0.0,
    ));

    // 2. Ancient Banyan Tree at crossroad (X = 8.0)
    props.add(const SideScrollerProp(
      id: 'tree_banyan',
      name: 'Banyan Tree at Crossroad',
      type: SceneryType.banyanTree,
      worldX: 8.0,
      width: 4.0,
    ));

    // 3. Balan's Tea Stall (X = 14.0)
    props.add(const SideScrollerProp(
      id: 'stall_balan',
      name: "Balan's Tea Stall",
      type: SceneryType.teaStall,
      worldX: 14.0,
      width: 3.5,
      isInteractive: true,
      interactionPrompt: 'Order Tea from Balan [E]',
    ));

    // 4. Palm trees & stone shrine (X = 20.0 to 24.0)
    props.add(const SideScrollerProp(
      id: 'tree_palm_1',
      name: 'Coconut Palm',
      type: SceneryType.palmTree,
      worldX: 20.0,
    ));
    props.add(const SideScrollerProp(
      id: 'shrine_kavu',
      name: 'Sacred Stone Shrine',
      type: SceneryType.stoneShrine,
      worldX: 23.0,
    ));

    // 5. Wooden fence along paddy field boundary (X = 27.0)
    props.add(const SideScrollerProp(
      id: 'fence_paddy',
      name: 'Wooden Fence',
      type: SceneryType.woodenFence,
      worldX: 28.0,
    ));

    // 6. Aadi's Family House (X = 36.0)
    props.add(const SideScrollerProp(
      id: 'aadi_house',
      name: "Aadi's Family House",
      type: SceneryType.keralaHouse,
      worldX: 36.0,
      width: 6.0,
      isInteractive: true,
      interactionPrompt: 'Enter Family House [E]',
    ));

    // 7. Meera (Mother) standing on the front veranda of the house (X = 33.5)
    props.add(const SideScrollerProp(
      id: 'meera_npc',
      name: 'Meera (Mother)',
      type: SceneryType.meeraNpc,
      worldX: 33.5,
      width: 1.5,
      isInteractive: true,
      interactionPrompt: 'Talk to Meera [E]',
    ));

    // 8. Distant Palm Trees (X = 44.0)
    props.add(const SideScrollerProp(
      id: 'tree_palm_2',
      name: 'Coconut Palm',
      type: SceneryType.palmTree,
      worldX: 44.0,
    ));
  }

  void update(double dt) {
    player.update(dt);
    camera.setTarget(player.worldX, worldY: player.worldY);
    camera.update(dt);
  }
}
