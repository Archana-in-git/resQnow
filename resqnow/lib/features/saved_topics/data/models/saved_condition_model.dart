import 'dart:convert';
import '../../../medical_conditions/data/models/condition_model.dart';

class SavedConditionModel {
  final String id;
  final String name;
  final List<String> imageUrls;
  final String severity;
  final List<String> firstAidDescription;
  final List<String> doNotDo;
  final String videoUrl;
  final List<RequiredKit> requiredKits;
  final List<FaqItem> faqs;
  final List<String> doctorType;
  final String hospitalLocatorLink;
  final int savedAt;

  SavedConditionModel({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.severity,
    required this.firstAidDescription,
    required this.doNotDo,
    required this.videoUrl,
    required this.requiredKits,
    required this.faqs,
    required this.doctorType,
    required this.hospitalLocatorLink,
    required this.savedAt,
  });

  /// Factory method to create from ConditionModel
  factory SavedConditionModel.fromCondition(ConditionModel condition) {
    return SavedConditionModel(
      id: condition.id,
      name: condition.name,
      imageUrls: condition.imageUrls,
      severity: condition.severity,
      firstAidDescription: condition.firstAidDescription,
      doNotDo: condition.doNotDo,
      videoUrl: condition.videoUrl,
      requiredKits: condition.requiredKits,
      faqs: condition.faqs,
      doctorType: condition.doctorType,
      hospitalLocatorLink: condition.hospitalLocatorLink,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to ConditionModel
  ConditionModel toConditionModel() {
    return ConditionModel(
      id: id,
      name: name,
      imageUrls: imageUrls,
      severity: severity,
      firstAidDescription: firstAidDescription,
      doNotDo: doNotDo,
      videoUrl: videoUrl,
      requiredKits: requiredKits,
      faqs: faqs,
      doctorType: doctorType,
      hospitalLocatorLink: hospitalLocatorLink,
    );
  }

  /// Convert to Map for saving to database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrls': jsonEncode(imageUrls),
      'severity': severity,
      'firstAidDescription': jsonEncode(firstAidDescription),
      'doNotDo': jsonEncode(doNotDo),
      'videoUrl': videoUrl,
      'requiredKits': jsonEncode(
        requiredKits.map((kit) => kit.toMap()).toList(),
      ),
      'faqs': jsonEncode(faqs.map((faq) => faq.toMap()).toList()),
      'doctorType': jsonEncode(doctorType),
      'hospitalLocatorLink': hospitalLocatorLink,
      'savedAt': savedAt,
    };
  }

  /// Create from Map (from database)
  factory SavedConditionModel.fromMap(Map<String, dynamic> map) {
    return SavedConditionModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrls: List<String>.from(jsonDecode(map['imageUrls'] ?? '[]')),
      severity: map['severity'] ?? 'low',
      firstAidDescription: List<String>.from(
        jsonDecode(map['firstAidDescription'] ?? '[]'),
      ),
      doNotDo: List<String>.from(jsonDecode(map['doNotDo'] ?? '[]')),
      videoUrl: map['videoUrl'] ?? '',
      requiredKits: (jsonDecode(map['requiredKits'] ?? '[]') as List<dynamic>)
          .map((kit) => RequiredKit.fromMap(kit as Map<String, dynamic>))
          .toList(),
      faqs: (jsonDecode(map['faqs'] ?? '[]') as List<dynamic>)
          .map((faq) => FaqItem.fromMap(faq as Map<String, dynamic>))
          .toList(),
      doctorType: List<String>.from(jsonDecode(map['doctorType'] ?? '[]')),
      hospitalLocatorLink: map['hospitalLocatorLink'] ?? '',
      savedAt: map['savedAt'] ?? 0,
    );
  }
}
