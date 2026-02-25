import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow/domain/entities/call_request.dart';

class CallRequestModel extends CallRequest {
  const CallRequestModel({
    required super.id,
    required super.requesterId,
    required super.requesterName,
    required super.requesterEmail,
    super.requesterPhone,
    super.requesterProfileImage,
    required super.donorId,
    required super.donorName,
    required super.donorPhone,
    required super.requestedAt,
    required super.status,
    super.approvedAt,
    super.adminNotes,
    super.chatChannelId,
  });

  /// Convert model to Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterEmail': requesterEmail,
      'requesterPhone': requesterPhone,
      'requesterProfileImage': requesterProfileImage,
      'donorId': donorId,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'requestedAt': requestedAt,
      'status': status,
      'approvedAt': approvedAt,
      'adminNotes': adminNotes,
      'chatChannelId': chatChannelId,
    };
  }

  /// Create model from Firestore document
  factory CallRequestModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CallRequestModel(
      id: id ?? map['id'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterEmail: map['requesterEmail'] ?? '',
      requesterPhone: map['requesterPhone'],
      requesterProfileImage: map['requesterProfileImage'],
      donorId: map['donorId'] ?? '',
      donorName: map['donorName'] ?? '',
      donorPhone: map['donorPhone'] ?? '',
      requestedAt: map['requestedAt'] is Timestamp
          ? (map['requestedAt'] as Timestamp).toDate()
          : (map['requestedAt'] as DateTime? ?? DateTime.now()),
      status: map['status'] ?? 'pending',
      approvedAt: map['approvedAt'] is Timestamp
          ? (map['approvedAt'] as Timestamp).toDate()
          : (map['approvedAt'] as DateTime?),
      adminNotes: map['adminNotes'],
      chatChannelId: map['chatChannelId'],
    );
  }

  /// Create model from snapshot
  factory CallRequestModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return CallRequestModel.fromMap(snapshot.data() ?? {}, id: snapshot.id);
  }

  /// Create new instance with updated fields
  @override
  CallRequestModel copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterEmail,
    String? requesterPhone,
    String? requesterProfileImage,
    String? donorId,
    String? donorName,
    String? donorPhone,
    DateTime? requestedAt,
    String? status,
    DateTime? approvedAt,
    String? adminNotes,
    String? chatChannelId,
  }) {
    return CallRequestModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterEmail: requesterEmail ?? this.requesterEmail,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      requesterProfileImage:
          requesterProfileImage ?? this.requesterProfileImage,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      chatChannelId: chatChannelId ?? this.chatChannelId,
    );
  }

  @override
  String toString() => 'CallRequestModel(id: $id, status: $status)';
}
