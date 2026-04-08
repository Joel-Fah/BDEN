import '../../core/enums/myth_category.dart';

class MythModel {
  final String id;
  final String myth; // the false claim e.g. "Donating blood makes you weak"
  final String truth; // the debunking fact
  final String? sourceName; // e.g. "WHO", "Red Cross"
  final String? sourceUrl;
  final MythCategory category;
  final int order; // display order

  const MythModel({
    required this.id,
    required this.myth,
    required this.truth,
    this.sourceName,
    this.sourceUrl,
    required this.category,
    required this.order,
  });

  factory MythModel.fromJson(Map<String, dynamic> json) => MythModel(
        id: json['id'],
        myth: json['myth'],
        truth: json['truth'],
        sourceName: json['sourceName'],
        sourceUrl: json['sourceUrl'],
        category: MythCategory.values.byName(json['category']),
        order: json['order'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'myth': myth,
        'truth': truth,
        'sourceName': sourceName,
        'sourceUrl': sourceUrl,
        'category': category.name,
        'order': order,
      };
}
