# ResQNow Private Messaging System - Implementation Guide

## 📋 Overview

This is a production-ready, privacy-focused in-app messaging system for the ResQNow Flutter + Firebase application. The system is designed to protect user privacy by:

- ❌ **NOT storing** phone numbers, emails, or direct contact details
- ✅ **Storing only** names, blood groups, and profile images
- ✅ **Using** real-time Firestore streams for live updates
- ✅ **Supporting** easy chat room creation between users
- ✅ **Following** clean architecture principles

---

## 📁 Folder Structure

```
lib/features/chat/
├── data/
│   ├── models/
│   │   ├── message.dart           # Message model with Firestore serialization
│   │   ├── chat_room.dart          # ChatRoom model with room metadata
│   │   └── index.dart              # Barrel export for models
│   ├── services/
│   │   └── chat_service.dart       # Firestore CRUD operations & streams
│   └── [data layer - business logic independent of UI]
│
├── presentation/
│   ├── controllers/
│   │   └── chat_controller.dart    # Provider state management for chat
│   ├── pages/
│   │   └── chat_screen.dart        # Main chat UI with dash_chat_2
│   └── [presentation layer - UI & user interaction]
```

---

## 🗄️ Firestore Schema

### Collections & Documents

```
Firestore Root: /chats

/chats/{chatRoomId}/
├── metadata (document) - Room information
│   ├── participant1Id (string)           - User who initiated chat
│   ├── participant2Id (string)           - Donor/Receiver
│   ├── participant1Name (string)         - User's first name
│   ├── participant2Name (string)         - Donor's first name
│   ├── participant1BloodGroup (string)   - User's blood group
│   ├── participant2BloodGroup (string)   - Donor's blood group
│   ├── participant1ImageUrl (string, optional)
│   ├── participant2ImageUrl (string, optional)
│   ├── lastMessage (string)              - Preview for chat list
│   ├── lastMessageTime (timestamp)       - For sorting
│   ├── createdAt (timestamp)
│   └── unreadCount (number)              - Unread messages counter
│
└── messages/ (subcollection)
    └── {messageId} (document)
        ├── id (string)
        ├── senderId (string)
        ├── senderName (string)
        ├── senderBloodGroup (string)
        ├── senderImageUrl (string, optional)
        ├── text (string)
        ├── timestamp (timestamp)
        └── isRead (boolean)
```

### Sample Firestore Structure (JSON)

```json
{
  "chats": {
    "user1_donor1": {
      "participant1Id": "user1",
      "participant2Id": "donor1",
      "participant1Name": "John",
      "participant2Name": "Sarah",
      "participant1BloodGroup": "O+",
      "participant2BloodGroup": "B-",
      "participant1ImageUrl": "https://...",
      "participant2ImageUrl": "https://...",
      "lastMessage": "Thanks for helping!",
      "lastMessageTime": 1707590400000,
      "createdAt": 1707504000000,
      "unreadCount": 0,
      "messages": {
        "msg1": {
          "id": "msg1",
          "senderId": "user1",
          "senderName": "John",
          "senderBloodGroup": "O+",
          "text": "Hi Sarah, are you available?",
          "timestamp": 1707590300000,
          "isRead": true
        },
        "msg2": {
          "id": "msg2",
          "senderId": "donor1",
          "senderName": "Sarah",
          "senderBloodGroup": "B-",
          "text": "Thanks for helping!",
          "timestamp": 1707590400000,
          "isRead": false
        }
      }
    }
  }
}
```

---

## 🔐 Firestore Security Rules (Recommended)

Add these rules to your Firebase Console under **Firestore > Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Chat room access - only participants can read/write
    match /chats/{chatId} {
      allow read, write: if request.auth.uid in [
        resource.data.participant1Id,
        resource.data.participant2Id
      ];

      // Messages subcollection
      match /messages/{messageId} {
        allow read: if request.auth.uid in [
          get(/databases/$(database)/documents/chats/$(chatId)).data.participant1Id,
          get(/databases/$(database)/documents/chats/$(chatId)).data.participant2Id
        ];

        allow create: if request.auth.uid == request.resource.data.senderId &&
                         request.auth.uid in [
                           get(/databases/$(database)/documents/chats/$(chatId)).data.participant1Id,
                           get(/databases/$(database)/documents/chats/$(chatId)).data.participant2Id
                         ];

        allow update: if request.auth.uid == resource.data.senderId;
        allow delete: if request.auth.uid == resource.data.senderId;
      }
    }
  }
}
```

---

## 🔄 Data Flow Diagram

```
User clicks "Message" on Donor Details Page
        ↓
DonorDetailsPage._navigateToChat()
        ↓
go_router navigates to /chat/:otherUserId
        ↓
ChatScreen initializes with donor info
        ↓
ChatController.getChatRoom() called
        ↓
ChatService.getOrCreateChatRoom()
        ├─ Check if chat room exists in Firestore
        ├─ If YES → Return existing ChatRoom
        └─ If NO → Create new ChatRoom document
        ↓
ChatScreen displays messages
        ↓
User types message and taps send
        ↓
ChatController.sendMessage() called
        ↓
ChatService.sendMessage()
        ├─ Create Message document in subcollection
        └─ Update ChatRoom's lastMessage field
        ↓
Firestore triggers update
        ↓
StreamBuilder refreshes message list (ordered by timestamp)
```

---

## 📱 Key Classes & Their Responsibilities

### 1. **Message** (`message.dart`)

- Represents a single message
- Handles serialization to/from Firestore
- Contains sender info (no phone/email)

**Key Methods:**

- `toMap()` - Convert to Firestore document
- `fromMap()` - Create from Firestore data
- `fromSnapshot()` - Create from DocumentSnapshot
- `copyWith()` - Immutable copy with modifications

---

### 2. **ChatRoom** (`chat_room.dart`)

- Represents a conversation between two users
- Stores metadata (participants, blood groups, last message)
- Auto-sorted by lastMessageTime

**Key Methods:**

- `toMap()` - Firestore serialization
- `fromMap()` - Firestore deserialization
- `fromSnapshot()` - DocumentSnapshot conversion

---

### 3. **ChatService** (`chat_service.dart`)

- Core business logic for chat operations
- Handles all Firestore CRUD operations
- Manages real-time streams

**Key Methods:**

```dart
// Get or create chat room
Future<ChatRoom> getOrCreateChatRoom({...})

// Send a message
Future<void> sendMessage({...})

// Get messages as stream (real-time)
Stream<List<Message>> getMessagesStream(String chatRoomId)

// Get chat room metadata stream
Stream<ChatRoom?> getChatRoomStream(String chatRoomId)

// Get all chat rooms for current user
Future<List<ChatRoom>> getUserChatRooms()

// Delete chat room
Future<void> deleteChatRoom(String chatRoomId)

// Clear chat history (keep room metadata)
Future<void> clearChatHistory(String chatRoomId)
```

---

### 4. **ChatController** (`chat_controller.dart`)

- Provider-based state management
- Bridges UI and ChatService
- Handles loading states and errors

**Properties:**

- `currentChatRoom` - Active chat room
- `messages` - Current message list
- `isLoading` - Loading indicator
- `errorMessage` - Error handling

---

### 5. **ChatScreen** (`chat_screen.dart`)

- Main UI using `dash_chat_2` package
- Real-time message updates
- Message input & send functionality
- Chat options menu (clear history, delete chat)

---

## 🚀 Usage Guide

### Step 1: Initialize ChatController in Provider Setup

Add to your `main.dart` or provider setup:

```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(create: (_) => ChatController()),
  ],
  child: MyApp(),
)
```

### Step 2: Navigate to Chat

From any screen (e.g., DonorDetailsPage):

```dart
context.push(
  '/chat/${donor.id}',
  extra: {
    'otherUserId': donor.id,
    'otherUserName': donor.name,
    'otherUserBloodGroup': donor.bloodGroup,
    'otherUserImageUrl': donor.profileImageUrl,
    'currentUserName': currentUserName,
    'currentUserBloodGroup': currentUserBloodGroup,
    'currentUserImageUrl': currentUserImageUrl,
  },
);
```

### Step 3: Chat Screen Handles Everything

The ChatScreen automatically:

- Gets or creates chat room
- Loads existing messages
- Streams real-time updates
- Displays UI with dash_chat_2

---

## 🔒 Privacy & Security Features

### What's NOT Stored:

- ❌ Phone numbers
- ❌ Email addresses
- ❌ Direct calling information
- ❌ External contact details

### What's Stored (Safe):

- ✅ First names (or anonymized labels)
- ✅ Blood group (for context)
- ✅ Profile images (optional, user-controlled)
- ✅ Message content & timestamps

### Security Measures:

1. **Firestore Rules** - Only chat participants can access
2. **UID-based Access** - Authentication required
3. **No Sensitive Data Exposure** - Clean data model
4. **Participant Verification** - Both users must be registered

---

## 🎨 UI Features

The ChatScreen includes:

- **Header with Donor Info** - Name + Blood Group Badge + Verified Badge
- **Real-time Messages** - Streams from Firestore
- **Message Input** - Text field with send button
- **Options Menu** - Clear history / Delete chat
- **Dark Mode Support** - Full theme support
- **Timestamp Display** - When each message was sent
- **Sender Info** - Name and blood group per message

---

## 📊 Database Indices

To optimize Firestore queries, create these indices in **Firestore > Indexes**:

```
Collection: chats
Fields to Index:
1. participant1Id (Ascending) + lastMessageTime (Descending)
2. participant2Id (Ascending) + lastMessageTime (Descending)
```

---

## ⚡ Performance Optimizations

1. **Subcollection for Messages** - Cleaner data structure, easier pagination
2. **Lazy Loading** - Messages stream only recent messages
3. **Indexed Queries** - Fast sorting by lastMessageTime
4. **Efficient State Management** - Provider notifies only on changes

---

## 🧪 Testing the Implementation

### Test Scenario 1: Create Chat

1. User A (blood donor) views User B (requester) details
2. User A clicks "Message"
3. ChatScreen opens with new chat room created

### Test Scenario 2: Send Message

1. Chat room exists
2. User types message and sends
3. Message appears in both participants' chats in real-time

### Test Scenario 3: Load Existing Chat

1. User A sends message to User B
2. User A closes app and reopens
3. Previous messages load from Firestore
4. New messages stream in real-time

---

## 🔧 Customization Tips

### Change App Bar Color:

In `chat_screen.dart`:

```dart
backgroundColor: AppColors.customColor,
```

### Change Message Bubble Colors:

In `_buildChatUI()`:

```dart
currentUserContainerColor: YourColor,
containerColor: YourColor,
```

### Add Image Support:

Extend Message model with imageUrl field and update ChatService

### Add Typing Indicator:

Use `isTyping` field in ChatRoom and StreamBuilder

### Add Message Reactions:

Add `reactions` array to Message model

---

## 📦 Dependencies Used

```yaml
cloud_firestore: ^5.1.0 # Firestore operations
firebase_auth: ^5.1.0 # Authentication
provider: ^6.1.2 # State management
go_router: ^16.0.0 # Navigation
dash_chat_2: ^0.0.33 # Chat UI package
timeago: ^3.6.0 # Timestamp formatting
```

---

## 🐛 Troubleshooting

### Issue: Messages not loading

**Solution:** Check Firestore security rules, ensure user is authenticated

### Issue: Chat room not created

**Solution:** Verify both users exist in database, check Firebase console logs

### Issue: Real-time updates not working

**Solution:** Check internet connection, verify Firestore listener limits

### Issue: Dark mode colors off

**Solution:** Ensure `isDarkMode` is correctly determined from `Theme.of(context)`

---

## 📈 Future Enhancements

1. **Message Search** - Search past conversations
2. **Chat List Screen** - All chats with unread badges
3. **Typing Indicator** - Show when other user is typing
4. **Message Reactions** - Emoji reactions on messages
5. **File Sharing** - Share documents/images
6. **Voice Messages** - Record and send audio
7. **Message Encryption** - End-to-end encryption
8. **Call Integration** - In-app calls (after admin approval)
9. **Chat Backup** - Periodic backup to cloud
10. **Bot Integration** - Auto-responders

---

## 📄 File Summary

| File                   | Purpose                        | Lines    |
| ---------------------- | ------------------------------ | -------- |
| `message.dart`         | Message model & serialization  | ~70      |
| `chat_room.dart`       | ChatRoom model & serialization | ~110     |
| `chat_service.dart`    | Firestore CRUD & streams       | ~300     |
| `chat_controller.dart` | Provider state management      | ~90      |
| `chat_screen.dart`     | Main UI with dash_chat_2       | ~350     |
| **Total**              | Complete chat system           | **~920** |

---

## 🎓 Learning Outcomes

By studying this implementation, you'll learn:

- ✅ Clean Architecture in Flutter
- ✅ Firestore real-time databases
- ✅ Provider state management
- ✅ go_router navigation with parameters
- ✅ Stream-based UI updates
- ✅ Data model serialization
- ✅ Privacy-first design patterns

---

## 📞 Support

For issues or questions:

1. Check the Firestore console for errors
2. Review security rules
3. Ensure authentication is working
4. Check provider setup in main.dart

---

**Status:** ✅ Production-Ready | **Last Updated:** February 2026 | **Version:** 1.0
