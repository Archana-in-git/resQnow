# 🚨 ResQNow - Emergency Response Mobile App

ResQNow is a Flutter-based mobile app designed to help users respond quickly during medical emergencies by offering:

- 🚑 One-tap emergency calling
- 🧠 First aid instructions
- 🗺️ Hospital locator using live location
- 🗣️ Voice command support
- 🌍 Multi-language support
- 📹 Instructional videos (YouTube/WebView)

---

## 📁 Tech Stack

| Layer            | Technology / Tool            | Purpose                                  |
| ---------------- | ---------------------------- | ---------------------------------------- |
| Frontend         | Flutter (Dart)               | Cross-platform Android app               |
| Auth             | Firebase Authentication      | Secure sign-in                           |
| Database         | Firebase Firestore (NoSQL)   | Store user data, conditions, etc.        |
| Storage          | Firebase Storage             | Save user images (future use)            |
| Maps             | Google Maps SDK + Geolocator | Locate hospitals, get real-time location |
| Calling          | url_launcher                 | Make emergency calls                     |
| Voice            | speech_to_text, flutter_tts  | Voice commands and TTS guidance          |
| Multilingual     | flutter_localizations        | Translate content                        |
| State Management | provider / Riverpod          | Manage UI state                          |
| Notifications    | FCM (optional)               | Push alerts                              |

---

## 🚧 Project Status

> **Under Development**  
> The app is currently being structured. Collaborators welcome!

---

## 🤝 Contributing

To contribute:

1. Fork the repo
2. Create a feature branch
3. Submit a pull request

---

## 📜 License

This project is part of an academic submission and is not currently under an open-source license.
