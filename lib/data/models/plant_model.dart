class Plant {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> suitableSeasons; // ["musim hujan", "musim kemarau"]
  final double minTemp; // Suhu minimum dalam °C
  final double maxTemp; // Suhu maksimum
  final int minHumidity; // Kelembapan minimum (%)
  final int maxHumidity; // Kelembapan maksimum
  final String description;
  final double estimatedCost; // Dalam IDR

  Plant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.suitableSeasons,
    required this.minTemp,
    required this.maxTemp,
    required this.minHumidity,
    required this.maxHumidity,
    required this.description,
    required this.estimatedCost,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      suitableSeasons: List<String>.from(json['suitableSeasons']),
      minTemp: json['minTemp'].toDouble(),
      maxTemp: json['maxTemp'].toDouble(),
      minHumidity: json['minHumidity'],
      maxHumidity: json['maxHumidity'],
      description: json['description'],
      estimatedCost: json['estimatedCost'].toDouble(),
    );
  }

}
