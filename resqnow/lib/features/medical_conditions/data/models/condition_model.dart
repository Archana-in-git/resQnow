import 'package:cloud_firestore/cloud_firestore.dart';

class ConditionModel {
  final String id;
  final String name;
  final List<String> imageUrls;
  final String severity; // low | medium | high | critical
  final List<String> firstAidDescription;
  final List<String> doNotDo;
  final String videoUrl;
  final List<RequiredKit> requiredKits;
  final List<FaqItem> faqs;
  final List<String> doctorType;
  final String hospitalLocatorLink;

  ConditionModel({
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
  });

  /// Factory method to create from Firestore document
  factory ConditionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ConditionModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      severity: data['severity'] ?? 'low',
      firstAidDescription: List<String>.from(data['firstAidDescription'] ?? []),
      doNotDo: List<String>.from(data['doNotDo'] ?? []),
      videoUrl: data['videoUrl'] ?? '',
      requiredKits: (data['requiredKits'] as List<dynamic>? ?? [])
          .map((kit) => RequiredKit.fromMap(kit))
          .toList(),
      faqs: (data['faqs'] as List<dynamic>? ?? [])
          .map((faq) => FaqItem.fromMap(faq))
          .toList(),
      doctorType: List<String>.from(data['doctorType'] ?? []),
      hospitalLocatorLink: data['hospitalLocatorLink'] ?? '',
    );
  }

  /// Convert to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrls': imageUrls,
      'severity': severity,
      'firstAidDescription': firstAidDescription,
      'doNotDo': doNotDo,
      'videoUrl': videoUrl,
      'requiredKits': requiredKits.map((kit) => kit.toMap()).toList(),
      'faqs': faqs.map((faq) => faq.toMap()).toList(),
      'doctorType': doctorType,
      'hospitalLocatorLink': hospitalLocatorLink,
    };
  }
}

class RequiredKit {
  final String name;
  final String iconUrl;

  RequiredKit({required this.name, required this.iconUrl});

  factory RequiredKit.fromMap(Map<String, dynamic> map) {
    return RequiredKit(name: map['name'] ?? '', iconUrl: map['iconUrl'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconUrl': iconUrl};
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});

  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'question': question, 'answer': answer};
  }
}
