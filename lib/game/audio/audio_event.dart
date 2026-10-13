/// High-level sound classification categories.
enum AudioCategory {
  music,
  ambient,
  combat,
  vehicle,
  movement,
  ui,
  voice,
  sfx,
}

/// All discrete audio events and sound triggers throughout VAYAL.
enum AudioEvent {
  // --- Music Themes ---
  themeMenu,
  themeHome,
  themeSuspense,
  themeCombat,
  themeHarbour,
  themeEndingWalkAway,
  themeEndingRevenge,
  themeEndingExpose,

  // --- Environmental Ambience ---
  ambientForestWind,
  ambientVillageRain,
  ambientCityTraffic,
  ambientPortWaves,

  // --- Combat SFX ---
  combatPunchLight,
  combatPunchHeavy,
  combatBlock,
  combatDodge,
  combatPain,
  combatMacheteSlash,
  combatBluntSwing,
  combatGunshot,
  combatReload,

  // --- Vehicle SFX ---
  vehicleEngineIdle,
  vehicleEngineRev,
  vehicleBrake,
  vehicleHorn,
  vehicleCrash,

  // --- Player Movement SFX ---
  footstepWalk,
  footstepSprint,
  jumpGrunt,
  landThud,

  // --- Narrative, Missions & UI SFX ---
  uiClick,
  uiDialogueNext,
  missionObjectiveTick,
  missionCompleteFanfare,
  choiceSelect,
  actTitleGong,
}

/// Metadata describing sound characteristics, category, looping, and 3D falloff.
class AudioCue {
  final AudioEvent event;
  final AudioCategory category;
  final String title;
  final double defaultVolume;
  final bool isLooping;
  final double spatialMinDistance; // Distance within which sound is at full volume
  final double spatialMaxDistance; // Distance beyond which sound is completely silent
  final double basePitch;

  const AudioCue({
    required this.event,
    required this.category,
    required this.title,
    this.defaultVolume = 1.0,
    this.isLooping = false,
    this.spatialMinDistance = 5.0,
    this.spatialMaxDistance = 50.0,
    this.basePitch = 1.0,
  });

  bool get isMusic => category == AudioCategory.music;
  bool get isAmbient => category == AudioCategory.ambient;
  bool get isSfx => category != AudioCategory.music && category != AudioCategory.ambient;
}

/// Database mapping every AudioEvent to its cue metadata.
class AudioRegistry {
  static const Map<AudioEvent, AudioCue> cues = {
    // Music
    AudioEvent.themeMenu: AudioCue(
      event: AudioEvent.themeMenu,
      category: AudioCategory.music,
      title: 'Main Theme (Aadi\'s Return)',
      defaultVolume: 0.7,
      isLooping: true,
    ),
    AudioEvent.themeHome: AudioCue(
      event: AudioEvent.themeHome,
      category: AudioCategory.music,
      title: 'Home Sanctuary (Acoustic Rain)',
      defaultVolume: 0.6,
      isLooping: true,
    ),
    AudioEvent.themeSuspense: AudioCue(
      event: AudioEvent.themeSuspense,
      category: AudioCategory.music,
      title: 'Shadows in Veyrapuram (Investigation)',
      defaultVolume: 0.65,
      isLooping: true,
    ),
    AudioEvent.themeCombat: AudioCue(
      event: AudioEvent.themeCombat,
      category: AudioCategory.music,
      title: 'Berth 4 Confrontation (High Pulse)',
      defaultVolume: 0.8,
      isLooping: true,
    ),
    AudioEvent.themeHarbour: AudioCue(
      event: AudioEvent.themeHarbour,
      category: AudioCategory.music,
      title: 'Industrial Rust (Port Veyrapuram)',
      defaultVolume: 0.65,
      isLooping: true,
    ),
    AudioEvent.themeEndingWalkAway: AudioCue(
      event: AudioEvent.themeEndingWalkAway,
      category: AudioCategory.music,
      title: 'The Green Field (Walk Away Theme)',
      defaultVolume: 0.75,
      isLooping: true,
    ),
    AudioEvent.themeEndingRevenge: AudioCue(
      event: AudioEvent.themeEndingRevenge,
      category: AudioCategory.music,
      title: 'The Iron Crown (Revenge Theme)',
      defaultVolume: 0.8,
      isLooping: true,
    ),
    AudioEvent.themeEndingExpose: AudioCue(
      event: AudioEvent.themeEndingExpose,
      category: AudioCategory.music,
      title: 'The Ledger of Veyrapuram (Expose Theme)',
      defaultVolume: 0.75,
      isLooping: true,
    ),

    // Ambient
    AudioEvent.ambientForestWind: AudioCue(
      event: AudioEvent.ambientForestWind,
      category: AudioCategory.ambient,
      title: 'Teak Canopy Wind',
      defaultVolume: 0.5,
      isLooping: true,
    ),
    AudioEvent.ambientVillageRain: AudioCue(
      event: AudioEvent.ambientVillageRain,
      category: AudioCategory.ambient,
      title: 'Kerala Monsoon Rooftop Rain',
      defaultVolume: 0.55,
      isLooping: true,
    ),
    AudioEvent.ambientCityTraffic: AudioCue(
      event: AudioEvent.ambientCityTraffic,
      category: AudioCategory.ambient,
      title: 'Distal Highway & City Hum',
      defaultVolume: 0.45,
      isLooping: true,
    ),
    AudioEvent.ambientPortWaves: AudioCue(
      event: AudioEvent.ambientPortWaves,
      category: AudioCategory.ambient,
      title: 'Arabian Sea Waves on Concrete Jetty',
      defaultVolume: 0.6,
      isLooping: true,
    ),

    // Combat
    AudioEvent.combatPunchLight: AudioCue(
      event: AudioEvent.combatPunchLight,
      category: AudioCategory.combat,
      title: 'Light Jab Impact',
      defaultVolume: 0.8,
      spatialMinDistance: 4.0,
      spatialMaxDistance: 30.0,
    ),
    AudioEvent.combatPunchHeavy: AudioCue(
      event: AudioEvent.combatPunchHeavy,
      category: AudioCategory.combat,
      title: 'Heavy Hook Bone Impact',
      defaultVolume: 0.95,
      spatialMinDistance: 4.0,
      spatialMaxDistance: 35.0,
    ),
    AudioEvent.combatBlock: AudioCue(
      event: AudioEvent.combatBlock,
      category: AudioCategory.combat,
      title: 'Defensive Forearm Block',
      defaultVolume: 0.75,
      spatialMinDistance: 4.0,
      spatialMaxDistance: 25.0,
    ),
    AudioEvent.combatDodge: AudioCue(
      event: AudioEvent.combatDodge,
      category: AudioCategory.combat,
      title: 'Rapid Cloth Dodge Whoosh',
      defaultVolume: 0.6,
      spatialMinDistance: 3.0,
      spatialMaxDistance: 20.0,
    ),
    AudioEvent.combatPain: AudioCue(
      event: AudioEvent.combatPain,
      category: AudioCategory.combat,
      title: 'Impact Pain Grunt',
      defaultVolume: 0.85,
      spatialMinDistance: 4.0,
      spatialMaxDistance: 30.0,
    ),
    AudioEvent.combatMacheteSlash: AudioCue(
      event: AudioEvent.combatMacheteSlash,
      category: AudioCategory.combat,
      title: 'Vettukathi Steel Slash Impact',
      defaultVolume: 0.9,
      spatialMinDistance: 4.0,
      spatialMaxDistance: 35.0,
    ),
    AudioEvent.combatBluntSwing: AudioCue(
      event: AudioEvent.combatBluntSwing,
      category: AudioCategory.combat,
      title: 'Iron Rod Heavy Whoosh & Clang',
      defaultVolume: 0.9,
      spatialMinDistance: 4.0,
      spatialMaxDistance: 35.0,
    ),
    AudioEvent.combatGunshot: AudioCue(
      event: AudioEvent.combatGunshot,
      category: AudioCategory.combat,
      title: 'High Caliber Gunshot Crack & Reverb',
      defaultVolume: 1.0,
      spatialMinDistance: 10.0,
      spatialMaxDistance: 90.0,
    ),
    AudioEvent.combatReload: AudioCue(
      event: AudioEvent.combatReload,
      category: AudioCategory.combat,
      title: 'Weapon Cylinder Snap & Shell Eject',
      defaultVolume: 0.75,
      spatialMinDistance: 3.0,
      spatialMaxDistance: 15.0,
    ),

    // Vehicles
    AudioEvent.vehicleEngineIdle: AudioCue(
      event: AudioEvent.vehicleEngineIdle,
      category: AudioCategory.vehicle,
      title: 'Premier Padmini Engine Idle',
      defaultVolume: 0.6,
      isLooping: true,
      spatialMinDistance: 5.0,
      spatialMaxDistance: 45.0,
    ),
    AudioEvent.vehicleEngineRev: AudioCue(
      event: AudioEvent.vehicleEngineRev,
      category: AudioCategory.vehicle,
      title: 'Engine RPM Acceleration',
      defaultVolume: 0.85,
      spatialMinDistance: 6.0,
      spatialMaxDistance: 55.0,
    ),
    AudioEvent.vehicleBrake: AudioCue(
      event: AudioEvent.vehicleBrake,
      category: AudioCategory.vehicle,
      title: 'Rubber Tire Brake Screech',
      defaultVolume: 0.7,
      spatialMinDistance: 5.0,
      spatialMaxDistance: 40.0,
    ),
    AudioEvent.vehicleHorn: AudioCue(
      event: AudioEvent.vehicleHorn,
      category: AudioCategory.vehicle,
      title: 'Dual Tone Horn Honk',
      defaultVolume: 0.9,
      spatialMinDistance: 10.0,
      spatialMaxDistance: 80.0,
    ),
    AudioEvent.vehicleCrash: AudioCue(
      event: AudioEvent.vehicleCrash,
      category: AudioCategory.vehicle,
      title: 'Vehicle Metal Crash Deformation',
      defaultVolume: 1.0,
      spatialMinDistance: 8.0,
      spatialMaxDistance: 70.0,
    ),

    // Movement
    AudioEvent.footstepWalk: AudioCue(
      event: AudioEvent.footstepWalk,
      category: AudioCategory.movement,
      title: 'Footstep (Dirt / Asphalt Walk)',
      defaultVolume: 0.45,
      spatialMinDistance: 2.0,
      spatialMaxDistance: 15.0,
    ),
    AudioEvent.footstepSprint: AudioCue(
      event: AudioEvent.footstepSprint,
      category: AudioCategory.movement,
      title: 'Footstep (Sprint Boot Strike)',
      defaultVolume: 0.65,
      spatialMinDistance: 3.0,
      spatialMaxDistance: 20.0,
    ),
    AudioEvent.jumpGrunt: AudioCue(
      event: AudioEvent.jumpGrunt,
      category: AudioCategory.movement,
      title: 'Jump Effort Grunt',
      defaultVolume: 0.5,
      spatialMinDistance: 3.0,
      spatialMaxDistance: 15.0,
    ),
    AudioEvent.landThud: AudioCue(
      event: AudioEvent.landThud,
      category: AudioCategory.movement,
      title: 'Jump Landing Ground Thud',
      defaultVolume: 0.7,
      spatialMinDistance: 4.0,
      spatialMaxDistance: 20.0,
    ),

    // UI & Mission
    AudioEvent.uiClick: AudioCue(
      event: AudioEvent.uiClick,
      category: AudioCategory.ui,
      title: 'Tactile Interface Click',
      defaultVolume: 0.5,
    ),
    AudioEvent.uiDialogueNext: AudioCue(
      event: AudioEvent.uiDialogueNext,
      category: AudioCategory.ui,
      title: 'Dialogue Progression Beep',
      defaultVolume: 0.55,
    ),
    AudioEvent.missionObjectiveTick: AudioCue(
      event: AudioEvent.missionObjectiveTick,
      category: AudioCategory.ui,
      title: 'Objective Completed Chime',
      defaultVolume: 0.8,
    ),
    AudioEvent.missionCompleteFanfare: AudioCue(
      event: AudioEvent.missionCompleteFanfare,
      category: AudioCategory.ui,
      title: 'Mission Complete Noir Fanfare',
      defaultVolume: 0.9,
    ),
    AudioEvent.choiceSelect: AudioCue(
      event: AudioEvent.choiceSelect,
      category: AudioCategory.ui,
      title: 'Pivotal Moral Choice Bass Hit',
      defaultVolume: 0.85,
    ),
    AudioEvent.actTitleGong: AudioCue(
      event: AudioEvent.actTitleGong,
      category: AudioCategory.ui,
      title: 'Cinematic Act Transition Low Gong',
      defaultVolume: 0.9,
    ),
  };

  static AudioCue getCue(AudioEvent event) {
    return cues[event] ??
        AudioCue(
          event: event,
          category: AudioCategory.sfx,
          title: event.name,
        );
  }
}
