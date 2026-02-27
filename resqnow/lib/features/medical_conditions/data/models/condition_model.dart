import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified FaqItem — used by both app and admin
class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});

  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'question': question, 'answer': answer};
}

/// Unified ConditionModel — single source of truth for app + admin
class ConditionModel {
  final String id;
  final String name;
  final String categoryId;
  final String severity; // low | medium | high | critical
  final List<String> imageUrls;
  final List<String> firstAidDescription;
  final String? videoUrl;
  final List<FaqItem> faqs;
  final List<String> doctorType;
  final String? hospitalLocatorLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConditionModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.severity,
    required this.imageUrls,
    required this.firstAidDescription,
    this.videoUrl,
    required this.faqs,
    required this.doctorType,
    this.hospitalLocatorLink,
    this.createdAt,
    this.updatedAt,
  });

  // ─── Firestore Read (App + Admin) ────────────────────────────────────────

  factory ConditionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConditionModel.fromJson({'id': doc.id, ...data});
  }

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      severity: json['severity'] as String? ?? 'low',
      imageUrls: _toStringList(json['imageUrls']),
      // Support both old field name 'firstAidSteps' and current 'firstAidDescription'
      firstAidDescription: _toStringList(
        json['firstAidDescription'] ?? json['firstAidSteps'],
      ),
      videoUrl: json['videoUrl'] as String?,
      faqs: _toFaqList(json['faqs']),
      doctorType: _toStringList(json['doctorType'] ?? json['doctorTypes']),
      hospitalLocatorLink: json['hospitalLocatorLink'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  // ─── Firestore Write (App + Admin) ───────────────────────────────────────

  /// Use this when writing to Firestore (do NOT include 'id' in the document body)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'severity': severity,
      'imageUrls': imageUrls,
      'firstAidDescription': firstAidDescription,
      'videoUrl': videoUrl,
      'faqs': faqs.map((f) => f.toMap()).toList(),
      'doctorType': doctorType,
      'hospitalLocatorLink': hospitalLocatorLink,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  static List<FaqItem> _toFaqList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => FaqItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value > 10000000000 ? value : value * 1000,
      );
    }
    return null;
  }
}
