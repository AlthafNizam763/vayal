import 'package:three_js/three_js.dart' as three;
import 'cinematic_track.dart';

/// Predefined scripted cutscenes for VAYAL open world narrative events.
class CinematicDatabase {
  /// 1. Intro Arrival: Sweeping high-altitude panorama descending onto Aadi's arrival point.
  static final CinematicSequence introArrival = CinematicSequence(
    id: 'intro_arrival',
    title: 'Arrival in Veyrapuram',
    duration: 6.0,
    canSkip: true,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(0.0, 18.0, -35.0),
        targetPosition: three.Vector3(0.0, 2.0, 0.0),
        fov: 58.0,
        subtitleSpeaker: 'NARRATOR',
        subtitleText: '“Can a man escape the person he used to be?”',
      ),
      CinematicKeyframe(
        time: 2.5,
        cameraPosition: three.Vector3(5.0, 8.0, -18.0),
        targetPosition: three.Vector3(0.0, 1.5, -4.0),
        fov: 52.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '“Twelve years away... Veyrapuram hasn\'t changed. But I have.”',
      ),
      CinematicKeyframe(
        time: 4.8,
        cameraPosition: three.Vector3(0.0, 2.6, 5.0),
        targetPosition: three.Vector3(0.0, 1.6, 0.0),
        fov: 50.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '“First thing: head home. See Meera and Diya.”',
      ),
      CinematicKeyframe(
        time: 6.0,
        cameraPosition: three.Vector3(0.0, 2.8, 5.2),
        targetPosition: three.Vector3(0.0, 1.6, 0.0),
        fov: 50.0,
      ),
    ],
  );

  /// 2. Porch Reveal: Establishing shot moving into the Menon ancestral homestead.
  static final CinematicSequence porchReveal = CinematicSequence(
    id: 'porch_reveal',
    title: 'The Ancestral Home',
    duration: 4.5,
    canSkip: true,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(-14.0, 6.0, -28.0),
        targetPosition: three.Vector3(-7.0, 1.8, -12.0),
        fov: 55.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '“The old house still stands. The red clay roof my father built.”',
      ),
      CinematicKeyframe(
        time: 2.2,
        cameraPosition: three.Vector3(-10.0, 3.0, -16.0),
        targetPosition: three.Vector3(-7.5, 1.5, -12.0),
        fov: 48.0,
        subtitleSpeaker: 'MEERA (INSIDE)',
        subtitleText: '“Is someone at the door...?”',
      ),
      CinematicKeyframe(
        time: 4.5,
        cameraPosition: three.Vector3(-7.5, 2.2, -14.0),
        targetPosition: three.Vector3(-7.5, 1.6, -11.5),
        fov: 46.0,
      ),
    ],
  );

  /// 3. Photograph Reveal: Close investigation of the criminal photograph left outside.
  static final CinematicSequence photographReveal = CinematicSequence(
    id: 'photograph_reveal',
    title: 'Shadows of the Past',
    duration: 5.0,
    canSkip: true,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(-6.0, 1.8, -11.0),
        targetPosition: three.Vector3(-7.2, 0.6, -11.8),
        fov: 44.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '“An envelope on the porch steps... stamped with an old dock seal.”',
      ),
      CinematicKeyframe(
        time: 2.5,
        cameraPosition: three.Vector3(-7.0, 1.2, -11.5),
        targetPosition: three.Vector3(-7.2, 0.5, -11.8),
        fov: 40.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '“A photograph of me, Rahu, and Devraj. With a message on the back: \'You left us once. Don\'t do it again.\'”',
      ),
      CinematicKeyframe(
        time: 5.0,
        cameraPosition: three.Vector3(-7.5, 1.4, -11.2),
        targetPosition: three.Vector3(-7.2, 0.7, -11.8),
        fov: 42.0,
      ),
    ],
  );

  /// 4. Berth 4 Establishing: Industrial panorama overlooking Port Veyrapuram.
  static final CinematicSequence berth4Establishing = CinematicSequence(
    id: 'berth4_establishing',
    title: 'Port Veyrapuram: Berth 4',
    duration: 5.5,
    canSkip: true,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(25.0, 22.0, -185.0),
        targetPosition: three.Vector3(0.0, 4.0, -215.0),
        fov: 60.0,
        subtitleSpeaker: 'NARRATOR',
        subtitleText: '“Berth 4. Where legitimate cargo manifests turn to contraband under the cover of monsoon mist.”',
      ),
      CinematicKeyframe(
        time: 2.8,
        cameraPosition: three.Vector3(10.0, 12.0, -200.0),
        targetPosition: three.Vector3(-5.0, 2.0, -215.0),
        fov: 52.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '“This was where my father was murdered. Time to find the truth.”',
      ),
      CinematicKeyframe(
        time: 5.5,
        cameraPosition: three.Vector3(0.0, 4.5, -205.0),
        targetPosition: three.Vector3(0.0, 1.8, -215.0),
        fov: 48.0,
      ),
    ],
  );

  /// 5. Rahu Confrontation Intro: High tension roadside shot on Coastal Highway.
  static final CinematicSequence rahuConfrontationIntro = CinematicSequence(
    id: 'rahu_confrontation_intro',
    title: 'Highway Confrontation',
    duration: 4.5,
    canSkip: true,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(8.0, 3.2, -145.0),
        targetPosition: three.Vector3(0.0, 1.8, -136.0),
        fov: 50.0,
        subtitleSpeaker: 'RAHU',
        subtitleText: '“You drive fast, Menon. But no one drives faster than their past.”',
      ),
      CinematicKeyframe(
        time: 2.2,
        cameraPosition: three.Vector3(-4.0, 2.2, -138.0),
        targetPosition: three.Vector3(0.0, 1.8, -136.0),
        fov: 45.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '“I\'m not here for your syndicate, Rahu. I\'m here to end this.”',
      ),
      CinematicKeyframe(
        time: 4.5,
        cameraPosition: three.Vector3(1.5, 2.4, -140.0),
        targetPosition: three.Vector3(0.0, 1.8, -136.0),
        fov: 45.0,
      ),
    ],
  );

  /// 6. Father's Truth Reveal — low-angle shot on a rain-slicked dock.
  static final CinematicSequence fatherTruthReveal = CinematicSequence(
    id: 'father_truth_reveal',
    title: 'The Accident That Wasn\'t',
    duration: 6.0,
    canSkip: true,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(2.0, 1.2, -208.0),
        targetPosition: three.Vector3(0.0, 0.5, -215.0),
        fov: 42.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '"The shipping logs don\'t lie. My father was killed because he found them."',
      ),
      CinematicKeyframe(
        time: 3.0,
        cameraPosition: three.Vector3(-3.0, 2.0, -212.0),
        targetPosition: three.Vector3(0.0, 1.0, -215.0),
        fov: 48.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '"Devraj ordered it. Rahu carried it out. Twelve years of lies."',
      ),
      CinematicKeyframe(
        time: 6.0,
        cameraPosition: three.Vector3(0.0, 3.0, -210.0),
        targetPosition: three.Vector3(0.0, 1.2, -215.0),
        fov: 50.0,
      ),
    ],
  );

  /// 7. Truth Video Reveal — extreme close-up on a found phone screen.
  static final CinematicSequence truthVideoReveal = CinematicSequence(
    id: 'truth_video_reveal',
    title: 'The Video',
    duration: 5.5,
    canSkip: true,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(0.5, 1.0, -120.0),
        targetPosition: three.Vector3(0.0, 0.9, -122.0),
        fov: 35.0,
        subtitleSpeaker: 'NARRATOR',
        subtitleText: '"A grainy phone recording from twelve years ago — Berth 4, monsoon night."',
      ),
      CinematicKeyframe(
        time: 2.5,
        cameraPosition: three.Vector3(-0.5, 1.2, -121.0),
        targetPosition: three.Vector3(0.0, 1.0, -122.0),
        fov: 38.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '"That figure in the background... I know who that is."',
      ),
      CinematicKeyframe(
        time: 5.5,
        cameraPosition: three.Vector3(0.0, 1.5, -120.5),
        targetPosition: three.Vector3(0.0, 1.0, -122.0),
        fov: 40.0,
      ),
    ],
  );

  /// 8. Devraj Final Confrontation — grand crane shot descending into Berth 4 during storm.
  static final CinematicSequence devrajFinalConfrontation = CinematicSequence(
    id: 'devraj_final_confrontation',
    title: 'End of the Line',
    duration: 7.0,
    canSkip: false,
    keyframes: [
      CinematicKeyframe(
        time: 0.0,
        cameraPosition: three.Vector3(0.0, 35.0, -195.0),
        targetPosition: three.Vector3(0.0, 0.0, -215.0),
        fov: 65.0,
        subtitleSpeaker: 'NARRATOR',
        subtitleText: '"Port Veyrapuram, Berth 4. The last accounting."',
      ),
      CinematicKeyframe(
        time: 3.5,
        cameraPosition: three.Vector3(8.0, 10.0, -205.0),
        targetPosition: three.Vector3(0.0, 2.0, -215.0),
        fov: 52.0,
        subtitleSpeaker: 'DEVRAJ',
        subtitleText: '"You should have stayed away, Menon. Just like your father should have."',
      ),
      CinematicKeyframe(
        time: 6.5,
        cameraPosition: three.Vector3(0.0, 2.5, -208.0),
        targetPosition: three.Vector3(0.0, 1.8, -215.0),
        fov: 48.0,
        subtitleSpeaker: 'AADI',
        subtitleText: '"This ends tonight."',
      ),
      CinematicKeyframe(
        time: 7.0,
        cameraPosition: three.Vector3(0.0, 2.5, -208.0),
        targetPosition: three.Vector3(0.0, 1.8, -215.0),
        fov: 48.0,
      ),
    ],
  );

  // ─── Act Transition Cards (title card cinematics) ──────────────────────────

  static CinematicSequence _buildActTransition({
    required String id,
    required String actTitle,
    required String tagline,
    required three.Vector3 camPos,
    required three.Vector3 lookAt,
  }) {
    return CinematicSequence(
      id: id,
      title: actTitle,
      duration: 4.0,
      canSkip: true,
      keyframes: [
        CinematicKeyframe(
          time: 0.0,
          cameraPosition: camPos,
          targetPosition: lookAt,
          fov: 55.0,
          subtitleSpeaker: actTitle.toUpperCase(),
          subtitleText: tagline,
        ),
        CinematicKeyframe(
          time: 4.0,
          cameraPosition: camPos,
          targetPosition: lookAt,
          fov: 55.0,
        ),
      ],
    );
  }

  static final CinematicSequence act2Transition = _buildActTransition(
    id: 'act2_transition',
    actTitle: 'ACT II — GHOSTS',
    tagline: '"The shadows don\'t forget your face."',
    camPos: three.Vector3(-60.0, 6.0, 2.0),
    lookAt: three.Vector3(-65.0, 1.5, 0.0),
  );

  static final CinematicSequence act3Transition = _buildActTransition(
    id: 'act3_transition',
    actTitle: 'ACT III — BLOOD',
    tagline: '"Accidents always leave paper trails."',
    camPos: three.Vector3(60.0, 8.0, -5.0),
    lookAt: three.Vector3(65.0, 2.0, 0.0),
  );

  static final CinematicSequence act4Transition = _buildActTransition(
    id: 'act4_transition',
    actTitle: 'ACT IV — THE TRUTH',
    tagline: '"Brothers in the dark, strangers in the light."',
    camPos: three.Vector3(5.0, 5.0, -145.0),
    lookAt: three.Vector3(0.0, 2.0, -140.0),
  );

  static final CinematicSequence act5Transition = _buildActTransition(
    id: 'act5_transition',
    actTitle: 'ACT V — VAYAL',
    tagline: '"The reaping."',
    camPos: three.Vector3(0.0, 20.0, -190.0),
    lookAt: three.Vector3(0.0, 3.0, -215.0),
  );

  static final Map<String, CinematicSequence> registry = {
    introArrival.id: introArrival,
    porchReveal.id: porchReveal,
    photographReveal.id: photographReveal,
    berth4Establishing.id: berth4Establishing,
    rahuConfrontationIntro.id: rahuConfrontationIntro,
    // Phase 43 additions
    fatherTruthReveal.id: fatherTruthReveal,
    truthVideoReveal.id: truthVideoReveal,
    devrajFinalConfrontation.id: devrajFinalConfrontation,
    act2Transition.id: act2Transition,
    act3Transition.id: act3Transition,
    act4Transition.id: act4Transition,
    act5Transition.id: act5Transition,
  };

  static CinematicSequence? getSequence(String id) => registry[id];
}
