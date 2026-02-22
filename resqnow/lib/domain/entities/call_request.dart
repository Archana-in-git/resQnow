import 'package:equatable/equatable.dart';

class CallRequest extends Equatable {
  final String id;
  final String requesterId; // User requesting the call
  final String requesterName;
  final String requesterEmail;
  final String? requesterPhone;
  final String? requesterProfileImage;

  final String donorId; // Donor being requested
  final String donorName;
  final String donorPhone;

  final DateTime requestedAt;
  final String status; // 'pending', 'approved', 'rejected', 'expired'
  final DateTime? approvedAt;
  final String? adminNotes;

  final String? chatChannelId; // After approval, for direct communication

  const CallRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterEmail,
    this.requesterPhone,
    this.requesterProfileImage,
    required this.donorId,
    required this.donorName,
    required this.donorPhone,
    required this.requestedAt,
    required this.status,
    this.approvedAt,
    this.adminNotes,
    this.chatChannelId,
  });

  @override
  List<Object?> get props => [
    id,
    requesterId,
    requesterName,
    requesterEmail,
    requesterPhone,
    requesterProfileImage,
    donorId,
    donorName,
    donorPhone,
    requestedAt,
    status,
    approvedAt,
    adminNotes,
    chatChannelId,
  ];

  // copyWith method
  CallRequest copyWith({
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
    return CallRequest(
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
  String toString() => 'CallRequest(id: $id, status: $status)';
}
