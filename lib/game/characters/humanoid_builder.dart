import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;

/// Hair / head-gear styles supported by the humanoid builder.
enum HumanoidHairStyle { none, short, long, hooded, bearded }

/// Palette + styling knobs for a procedural humanoid character.
class HumanoidPalette {
  final int torsoHex;
  final int pantsHex;
  final int sleeveHex;
  final int skinHex;
  final int hairHex;
  final int accentHex;
  final HumanoidHairStyle hairStyle;
  final int? capHex;
  final bool isFemale;
  final int? sareeHex;

  const HumanoidPalette({
    this.torsoHex = 0x2b3242,
    this.pantsHex = 0x1c2129,
    this.sleeveHex = 0x2b3242,
    this.skinHex = 0xc5aa91,
    this.hairHex = 0x17130f,
    this.accentHex = 0x8a2820,
    this.hairStyle = HumanoidHairStyle.short,
    this.capHex,
    this.isFemale = false,
    this.sareeHex,
  });
}

/// References to the animated parts of a humanoid rig, matching the
/// legacy field contract used by Player / NPC / EnemyAI / PoliceOfficerAI
/// so existing procedural animation code keeps working untouched.
class HumanoidRig {
  final three.Mesh bodyMesh;
  final three.Mesh headMesh;
  final three.Mesh leftArm;
  final three.Mesh leftLeg;
  final three.Mesh rightArm;
  final three.Mesh rightLeg;

  const HumanoidRig({
    required this.bodyMesh,
    required this.headMesh,
    required this.leftArm,
    required this.rightArm,
    required this.leftLeg,
    required this.rightLeg,
  });
}

three.MeshStandardMaterial _mat(int hex,
    {double roughness = 0.8,
    double metalness = 0.0,
    int? emissiveHex}) {
  final m = three.MeshStandardMaterial();
  m.color = three.Color.fromHex32(hex);
  m.roughness = roughness;
  m.metalness = metalness;
  if (emissiveHex != null) {
    m.emissive = three.Color.fromHex32(emissiveHex);
  }
  return m;
}

three.Mesh _m(three.BufferGeometry geo, three.Material mat) =>
    three.Mesh(geo, mat);

/// Assembles a detailed humanoid character into [parent] and returns the
/// animated part references.
///
/// Anatomy (roughly 1.8 m tall): tapered chest lathe with subtle chest bulge,
/// pelvis, trapezius, neck, sculpted head with full face (eyes, pupils, brows,
/// nose, two-part lips, cheeks, chin, ears), upgraded hairstyles, capsule
/// limbs with shoulder/hip pivots, cuffed sleeves, thumbs, rounded shoes,
/// belt & collar, police cap.
///
/// Anchored to the caller's animation coordinate system via [torsoY] /
/// [headY] / [shoulderY] / [hipY] so walk-cycle code keeps its tuning.
HumanoidRig buildHumanoid(
  three.Object3D parent,
  HumanoidPalette p, {
  // Animation anchor heights (object-space, meters)
  double torsoY = 1.15,
  double headY = 1.78,
  double shoulderY = 1.42,
  double hipY = 0.78,
  // Proportions
  double shoulderHalfWidth = 0.30,
  double hipHalfWidth = 0.165,
  double bulk = 1.0,
  double torsoTaperTop = 0.205,
  double torsoTaperBottom = 0.15,
}) {
  final torsoMat = _mat(p.torsoHex, roughness: 0.78);
  final sleeveMat = _mat(p.sleeveHex, roughness: 0.8);
  final pantsMat = _mat(p.pantsHex, roughness: 0.86);
  final skinMat = _mat(p.skinHex, roughness: 0.45, metalness: 0.02,
      emissiveHex: 0x0e0805);
  final hairMat = _mat(p.hairHex, roughness: 0.72, emissiveHex: 0x0b0906);
  final accentMat = _mat(p.accentHex, roughness: 0.6);
  final beltMat = _mat(0x18130f, roughness: 0.45, metalness: 0.15);
  final eyeWhiteMat = _mat(0xf1ede6, roughness: 0.22, emissiveHex: 0x2e2b26);
  final pupilMat = _mat(0x14100c, roughness: 0.15);
  final lipMat = _mat(0x7c4a3a, roughness: 0.55);
  final goldMat = _mat(0xd4af37, roughness: 0.3, metalness: 0.7);
  final shoeMat = _mat(0x221a14, roughness: 0.4);

  // ---- Torso: tapered chest cylinder + chest bulge ----------------------
  final torso = _m(
    three.CylinderGeometry(torsoTaperTop * bulk, torsoTaperBottom * bulk, 0.64, 18),
    torsoMat,
  );
  torso.scale = three.Vector3(1.32, 1, 0.78);
  torso.position.setValues(0, torsoY, 0);
  parent.add(torso);

  // chest bulge reads closer volume when lit from the side
  final chest = _m(
    three.SphereGeometry(0.15 * bulk, 12, 10),
    torsoMat,
  );
  chest.scale = three.Vector3(1.28, 0.72, 0.64);
  chest.position.setValues(0, torsoY + 0.08, 0.055);
  parent.add(chest);

  // ---- Pelvis ------------------------------------------------------------
  final pelvis = _m(
    three.CylinderGeometry(0.155 * bulk, 0.165 * bulk, 0.26, 18),
    pantsMat,
  );
  pelvis.scale = three.Vector3(1.25, 1, 0.82);
  pelvis.position.setValues(0, torsoY - 0.42, 0);
  parent.add(pelvis);

  // ---- Belt & buckle ------------------------------------------------------
  final belt = _m(
    three.CylinderGeometry(0.175 * bulk, 0.185 * bulk, 0.07, 18),
    beltMat,
  );
  belt.scale = three.Vector3(1.28, 1, 0.8);
  belt.position.setValues(0, torsoY - 0.33, 0);
  parent.add(belt);

  final buckle = _m(three.BoxGeometry(0.07, 0.055, 0.03), goldMat);
  buckle.position.setValues(0, torsoY - 0.33, 0.17);
  parent.add(buckle);

  // ---- Trapezius: shoulder-line muscle bar ---------------------------------
  final traps = _m(
    three.CapsuleGeometry(radius: 0.075 * bulk, length: shoulderHalfWidth * 2 - 0.14, capSegments: 4, radialSegments: 10),
    torsoMat,
  );
  traps.rotation.z = math.pi / 2;
  traps.position.setValues(0, torsoY + 0.315, -0.01);
  parent.add(traps);

  // ---- Collar accents framing the neck --------------------------------------
  final collarL = _m(three.BoxGeometry(0.13, 0.045, 0.05), accentMat);
  collarL.position.setValues(-0.085, torsoY + 0.29, 0.145);
  collarL.rotation.z = 0.55;
  parent.add(collarL);
  final collarR = collarL.clone() as three.Mesh;
  collarR.position.x = 0.085;
  collarR.rotation.z = -0.55;
  parent.add(collarR);

  // ---- Neck -----------------------------------------------------------------
  final neck = _m(three.CylinderGeometry(0.055, 0.068, 0.15, 10), skinMat);
  neck.position.setValues(0, headY - 0.15, 0);
  parent.add(neck);

  // ---- Head: sculpted skull/jaw/cheeks + full face ---------------------------
  final head = _m(three.SphereGeometry(0.16, 18, 14), skinMat);
  head.scale = three.Vector3(0.95, 1.08, 0.95);
  head.position.setValues(0, headY, 0);
  parent.add(head);

  // Jaw / lower-face volume so the head reads as a head, not a ball
  final jaw = _m(three.SphereGeometry(0.105, 12, 9), skinMat);
  jaw.scale = three.Vector3(0.92, 0.82, 0.9);
  jaw.position.setValues(0, headY - 0.085, 0.045);
  parent.add(jaw);

  final cheekGeo = three.SphereGeometry(0.05, 8, 7);
  final cheekL = _m(cheekGeo, skinMat);
  cheekL.scale = three.Vector3(0.9, 0.75, 0.55);
  cheekL.position.setValues(-0.078, headY - 0.02, 0.105);
  parent.add(cheekL);
  final cheekR = cheekL.clone() as three.Mesh;
  cheekR.position.x = 0.078;
  parent.add(cheekR);

  const double eyeY = 0.015;
  const double eyeX = 0.058;
  const double eyeZ = 0.132;

  final eyeWhites = <three.Mesh>[
    _m(three.SphereGeometry(0.034, 10, 8), eyeWhiteMat),
    _m(three.SphereGeometry(0.034, 10, 8), eyeWhiteMat),
  ];
  eyeWhites[0].position.setValues(-eyeX, eyeY, eyeZ);
  eyeWhites[1].position.setValues(eyeX, eyeY, eyeZ);
  head.add(eyeWhites[0]);
  head.add(eyeWhites[1]);

  final pupils = <three.Mesh>[
    _m(three.SphereGeometry(0.015, 8, 6), pupilMat),
    _m(three.SphereGeometry(0.015, 8, 6), pupilMat),
  ];
  pupils[0].position.setValues(-eyeX, eyeY + 0.002, eyeZ + 0.024);
  pupils[1].position.setValues(eyeX, eyeY + 0.002, eyeZ + 0.024);
  head.add(pupils[0]);
  head.add(pupils[1]);

  // Brow ridge (two angled bars above the eyes)
  final browL = _m(three.BoxGeometry(0.066, 0.017, 0.024), hairMat);
  browL.position.setValues(-eyeX, eyeY + 0.056, eyeZ + 0.010);
  browL.rotation.z = -0.10;
  head.add(browL);
  final browR = browL.clone() as three.Mesh;
  browR.position.x = eyeX;
  browR.rotation.z = 0.10;
  head.add(browR);

  // Nose (rounded forward bead + bridge)
  final noseBead = _m(three.SphereGeometry(0.024, 8, 7), skinMat);
  noseBead.scale = three.Vector3(0.9, 0.85, 1.0);
  noseBead.position.setValues(0, -0.008, eyeZ + 0.040);
  head.add(noseBead);
  final noseBridge = _m(three.ConeGeometry(0.020, 0.055, 10), skinMat);
  noseBridge.position.setValues(0, 0.012, eyeZ + 0.024);
  noseBridge.rotation.x = math.pi / 2 + 0.30;
  head.add(noseBridge);

  // Mouth: upper lip + fuller lower lip
  final upperLip = _m(three.BoxGeometry(0.056, 0.010, 0.020), lipMat);
  upperLip.position.setValues(0, -0.072, eyeZ + 0.012);
  head.add(upperLip);
  final lowerLip = _m(three.BoxGeometry(0.046, 0.014, 0.020), lipMat);
  lowerLip.position.setValues(0, -0.084, eyeZ + 0.012);
  head.add(lowerLip);

  // Chin pad for a stronger jawline silhouette
  final chin = _m(three.SphereGeometry(0.034, 8, 7), skinMat);
  chin.scale = three.Vector3(1.0, 0.7, 0.8);
  chin.position.setValues(0, -0.115, eyeZ - 0.010);
  head.add(chin);

  // Ears: flattened, slightly back
  final earShape = three.SphereGeometry(0.03, 8, 7);
  final earL = _m(earShape, skinMat);
  earL.scale = three.Vector3(0.62, 1.05, 0.5);
  earL.position.setValues(-0.148, 0.005, 0.002);
  earL.rotation.z = -0.12;
  head.add(earL);
  final earR = earL.clone() as three.Mesh;
  earR.position.x = 0.148;
  earR.rotation.z = 0.12;
  head.add(earR);

  // ---- Hairstyle --------------------------------------------------------------
  switch (p.hairStyle) {
    case HumanoidHairStyle.none:
      break;
    case HumanoidHairStyle.short:
      final hair = _m(
        three.SphereGeometry(0.168, 14, 10, 0, math.pi * 2, 0, math.pi * 0.58),
        hairMat,
      );
      hair.scale = three.Vector3(0.98, 1.05, 0.98);
      hair.position.setValues(0, headY + 0.006, -0.004);
      hair.rotation.x = 0.24; // pushes coverage toward the back, exposes face
      parent.add(hair);
      // Sideburns
      final sideburnGeo = three.BoxGeometry(0.02, 0.05, 0.015);
      final sbL = _m(sideburnGeo, hairMat);
      sbL.position.setValues(-0.135, headY - 0.02, 0.075);
      parent.add(sbL);
      final sbR = sbL.clone() as three.Mesh;
      sbR.position.x = 0.135;
      parent.add(sbR);
      break;
    case HumanoidHairStyle.long:
      final hair = _m(
        three.SphereGeometry(0.168, 14, 10, 0, math.pi * 2, 0, math.pi * 0.6),
        hairMat,
      );
      hair.scale = three.Vector3(0.98, 1.05, 0.98);
      hair.position.setValues(0, headY + 0.026, -0.004);
      hair.rotation.x = 0.3;
      parent.add(hair);

      // Back fall + side strands framing the shoulders
      final backFall = _m(three.BoxGeometry(0.26, 0.34, 0.08), hairMat);
      backFall.position.setValues(0, headY - 0.16, -0.11);
      backFall.rotation.x = -0.08;
      parent.add(backFall);
      // rounded capsule strands look softer than slabs
      final strandGeo = three.CapsuleGeometry(radius: 0.028, length: 0.30, capSegments: 3, radialSegments: 8);
      final strandL = _m(strandGeo, hairMat);
      strandL.position.setValues(-0.138, headY - 0.09, -0.02);
      strandL.rotation.z = 0.06;
      parent.add(strandL);
      final strandR = strandL.clone() as three.Mesh;
      strandR.position.x = 0.138;
      strandR.rotation.z = -0.06;
      parent.add(strandR);
      // bun for women
      if (p.isFemale) {
        final bun = _m(three.SphereGeometry(0.062, 10, 8), hairMat);
        bun.position.setValues(0, headY + 0.09, -0.12);
        parent.add(bun);
      }
      break;
    case HumanoidHairStyle.hooded:
      final hood = _m(
        three.SphereGeometry(0.185, 14, 10, 0, math.pi * 2, 0, math.pi * 0.68),
        torsoMat,
      );
      hood.position.setValues(0, headY + 0.01, 0.005);
      parent.add(hood);
      final cowl = _m(
        three.CylinderGeometry(0.19, 0.24, 0.22, 14, 1, true),
        torsoMat,
      );
      cowl.position.setValues(0, headY - 0.1, 0);
      parent.add(cowl);
      break;
    case HumanoidHairStyle.bearded:
      final hair = _m(
        three.SphereGeometry(0.168, 14, 10, 0, math.pi * 2, 0, math.pi * 0.58),
        hairMat,
      );
      hair.scale = three.Vector3(0.98, 1.05, 0.98);
      hair.position.setValues(0, headY + 0.006, -0.004);
      hair.rotation.x = 0.24;
      parent.add(hair);

      // Beard: chin/jaw slab + mustache, softer edge via slim lower lip gap
      final beard = _m(three.BoxGeometry(0.19, 0.12, 0.06), hairMat);
      beard.position.setValues(0, headY - 0.115, 0.105);
      head.add(beard);
      final beardJaw = _m(three.BoxGeometry(0.23, 0.08, 0.05), hairMat);
      beardJaw.position.setValues(0, headY - 0.065, 0.075);
      beardJaw.rotation.x = -0.25; // hugs the jawline
      head.add(beardJaw);
      final mustache = _m(three.BoxGeometry(0.075, 0.018, 0.025), hairMat);
      mustache.position.setValues(0, -0.062, eyeZ + 0.014);
      head.add(mustache);
      break;
  }

  // ---- Peaked police cap (optional) ------------------------------------------
  if (p.capHex != null) {
    final capMat = _mat(p.capHex!, roughness: 0.5);
    final crown = _m(three.CylinderGeometry(0.15, 0.16, 0.1, 14), capMat);
    crown.position.setValues(0, headY + 0.155, 0.01);
    parent.add(crown);
    final brim = _m(three.BoxGeometry(0.24, 0.02, 0.17), beltMat);
    brim.position.setValues(0, headY + 0.108, 0.15);
    parent.add(brim);
    final badge = _m(three.BoxGeometry(0.055, 0.045, 0.02), goldMat);
    badge.position.setValues(0, headY + 0.155, 0.135);
    parent.add(badge);
  }

  // ---- Shoulder spheres ---------------------------------------------------------
  final shoulderGeo = three.SphereGeometry(0.11 * bulk, 12, 9);
  final shoulderL = _m(shoulderGeo, sleeveMat);
  shoulderL.position.setValues(-shoulderHalfWidth, shoulderY, 0);
  parent.add(shoulderL);
  final shoulderR = _m(shoulderGeo, sleeveMat);
  shoulderR.position.setValues(shoulderHalfWidth, shoulderY, 0);
  parent.add(shoulderR);

  // ---- Arms: capsule limbs pivoting at the shoulders -----------------------------
  const double armLen = 0.5;
  final double armR = 0.072 * bulk;
  final double armSpan = armLen + armR * 2;

  final armGeo = three.CapsuleGeometry(radius: armR, length: armLen, capSegments: 6, radialSegments: 12);
  armGeo.translate(0, -armSpan / 2, 0); // pivot at the shoulder

  final leftArm = _m(armGeo, sleeveMat);
  leftArm.position.setValues(-shoulderHalfWidth, shoulderY, 0);
  parent.add(leftArm);

  final rightArm = _m(armGeo, sleeveMat);
  rightArm.position.setValues(shoulderHalfWidth, shoulderY, 0);
  parent.add(rightArm);

  // Sleeve cuffs near the hand for edge-of-sleeve definition
  final cuffGeo = three.CylinderGeometry(armR * 1.08, armR * 1.02, 0.085, 12);
  final cuffL = _m(cuffGeo, sleeveMat);
  cuffL.position.setValues(0, -armSpan + 0.075, 0.005);
  leftArm.add(cuffL);
  final cuffR = cuffL.clone() as three.Mesh;
  rightArm.add(cuffR);

  // Hands with thumbs
  final handGeo = three.SphereGeometry(0.058, 10, 8);
  final thumbGeo = three.CapsuleGeometry(radius: 0.016, length: 0.05, capSegments: 3, radialSegments: 8);
  final handL = _m(handGeo, skinMat);
  handL.position.setValues(0, -armSpan + 0.03, 0.01);
  leftArm.add(handL);
  final thumbL = _m(thumbGeo, skinMat);
  thumbL.position.setValues(0.032, -armSpan + 0.05, 0.035);
  thumbL.rotation.z = 0.55;
  leftArm.add(thumbL);
  final handR = _m(handGeo, skinMat);
  handR.position.setValues(0, -armSpan + 0.03, 0.01);
  rightArm.add(handR);
  final thumbR = _m(thumbGeo, skinMat);
  thumbR.position.setValues(-0.032, -armSpan + 0.05, 0.035);
  thumbR.rotation.z = -0.55;
  rightArm.add(thumbR);

  // ---- Legs: capsule limbs pivoting at the hips -----------------------------------
  const double legLen = 0.56;
  final double legR = 0.095 * bulk;
  final double legSpan = legLen + legR * 2;

  final legGeo = three.CapsuleGeometry(radius: legR, length: legLen, capSegments: 6, radialSegments: 12);
  legGeo.translate(0, -legSpan / 2, 0); // pivot at the hip

  final leftLeg = _m(legGeo, pantsMat);
  leftLeg.position.setValues(-hipHalfWidth, hipY, 0);
  parent.add(leftLeg);

  final rightLeg = _m(legGeo, pantsMat);
  rightLeg.position.setValues(hipHalfWidth, hipY, 0);
  parent.add(rightLeg);

  // Rounded shoes (box + toe cap + heel)
  final shoeGeo = three.BoxGeometry(0.15, 0.095, 0.27);
  final toeGeo = three.SphereGeometry(0.078, 10, 8);
  for (final side in [false, true]) {
    final leg = side ? leftLeg : rightLeg;

    final shoe = _m(shoeGeo, shoeMat);
    shoe.position.setValues(0, -legSpan + 0.06, 0.045);
    leg.add(shoe);

    final toe = _m(toeGeo, shoeMat);
    toe.scale = three.Vector3(0.95, 0.55, 0.75);
    toe.position.setValues(0, -legSpan + 0.045, 0.145);
    leg.add(toe);

    final heel = _m(three.BoxGeometry(0.13, 0.10, 0.07), shoeMat);
    heel.position.setValues(0, -legSpan + 0.06, -0.085);
    leg.add(heel);
  }

  // ---- Female drape: saree skirt shell + pallu band --------------------------------
  if (p.isFemale) {
    final palluColor = p.sareeHex ?? p.torsoHex;
    final skirt = _m(
      three.CylinderGeometry(0.2, 0.3, 0.64, 20),
      _mat(palluColor, roughness: 0.85),
    );
    skirt.position.setValues(0, hipY - 0.06, 0);
    parent.add(skirt);

    final palluBand = _m(three.CylinderGeometry(0.225, 0.205, 0.1, 20), accentMat);
    palluBand.scale = three.Vector3(1.32, 1, 0.8);
    palluBand.position.setValues(0, torsoY - 0.08, 0);
    parent.add(palluBand);
  }

  return HumanoidRig(
    bodyMesh: torso,
    headMesh: head,
    leftArm: leftArm,
    rightArm: rightArm,
    leftLeg: leftLeg,
    rightLeg: rightLeg,
  );
}
