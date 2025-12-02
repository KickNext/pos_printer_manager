import 'dart:ui';

class CategoryForPrinter {
  CategoryForPrinter({
    required this.id,
    required this.displayName,
    required this.color,
  });

  factory CategoryForPrinter.fromJson(Map<String, dynamic> json) =>
      CategoryForPrinter(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        color: colorFromJson(json['color'] as int),
      );

  final String id;
  final String displayName;
  final Color color;
  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'color': colorToJson(color),
  };
}

Color colorFromJson(int color) => Color(color);
int colorToJson(Color color) => color.toARGB32();
