import 'package:cloud_firestore/cloud_firestore.dart';

class ConditionModel {
  final String id;
  final String name;
  final List<String> imageUrls;
  final String severity; // low | medium | high | critical
  final List<String> firstAidDescription;
  final String videoUrl;
  final List<FaqItem> faqs;
  final List<String> doctorType;
  final String hospitalLocatorLink;

  ConditionModel({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.severity,
    required this.firstAidDescription,
    required this.videoUrl,
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
      videoUrl: data['videoUrl'] ?? '',
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
      'videoUrl': videoUrl,
      'faqs': faqs.map((faq) => faq.toMap()).toList(),
      'doctorType': doctorType,
      'hospitalLocatorLink': hospitalLocatorLink,
    };
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
