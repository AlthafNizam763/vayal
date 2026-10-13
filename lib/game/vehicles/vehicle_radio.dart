/// Radio station metadata for in-car FM tuning.
class RadioStation {
  final String id;
  final String name;
  final String description;

  const RadioStation({
    required this.id,
    required this.name,
    this.description = '',
  });
}

/// In-car FM Radio Tuner supporting Malayalam broadcast channels and noir soundtracks.
class VehicleRadio {
  int currentChannel = 0;
  bool isPoweredOn = true;

  static const List<RadioStation> stations = [
    RadioStation(
      id: 'radio_veyrapuram',
      name: '92.7 Veyrapuram FM',
      description: 'Classic Malayalam Hits & Harbour Beats',
    ),
    RadioStation(
      id: 'radio_malabar',
      name: 'Malabar Retro Waves',
      description: '80s Synth & Carnatic Fusion',
    ),
    RadioStation(
      id: 'radio_harbour',
      name: 'Harbour Noir Beats',
      description: 'Late Night Sax & Rain',
    ),
    RadioStation(
      id: 'radio_off',
      name: 'Radio Off',
      description: 'Muted',
    ),
  ];

  static List<String> get stationNames => stations.map((s) => s.name).toList();

  RadioStation get currentStation => stations[currentChannel];
  String get currentStationName => isPoweredOn ? currentStation.name : 'Radio Off';

  void Function(int channel, String name)? onStationChanged;

  /// Switches to next broadcast station.
  void nextStation() {
    currentChannel = (currentChannel + 1) % stations.length;
    isPoweredOn = stations[currentChannel].id != 'radio_off';
    onStationChanged?.call(currentChannel, currentStationName);
  }

  /// Switches to previous broadcast station.
  void previousStation() {
    currentChannel = (currentChannel - 1 + stations.length) % stations.length;
    isPoweredOn = stations[currentChannel].id != 'radio_off';
    onStationChanged?.call(currentChannel, currentStationName);
  }

  /// Sets a specific station by its unique identifier.
  void setStation(String id) {
    final idx = stations.indexWhere((s) => s.id == id);
    if (idx != -1) {
      currentChannel = idx;
      isPoweredOn = stations[currentChannel].id != 'radio_off';
      onStationChanged?.call(currentChannel, currentStationName);
    }
  }

  /// Toggles in-car radio power.
  void togglePower() {
    isPoweredOn = !isPoweredOn;
    if (!isPoweredOn) {
      currentChannel = stations.indexWhere((s) => s.id == 'radio_off');
    } else {
      currentChannel = 0;
    }
    onStationChanged?.call(
      currentChannel,
      currentStationName,
    );
  }
}
