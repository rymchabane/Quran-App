class Reciter {
  final int id;
  final String name;
  final String style; // "Murattal", "Mujawwad", etc.

  Reciter({required this.id, required this.name, required this.style});

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'],
      name: json['reciter_name'] ?? json['name'] ?? 'Unknown',
      style: json['style'] ?? 'Murattal',
    );
  }
}