# 🚨 ResQNow – Emergency First Aid & Response App

**ResQNow** is a cross-platform mobile application that provides users with immediate access to emergency assistance, first aid instructions, and nearby hospitals during critical situations. Designed especially for the Indian context, ResQNow combines quick emergency features with educational resources to empower users to act swiftly and safely.

---

## 📱 App Features

### 🔑 Core (MVP) Features
- **🆘 Emergency Button** – One-tap call to national emergency numbers (e.g., 112) with real-time location.
- **📍 Nearby Hospital Locator** – Google Maps integration to find nearby clinics/hospitals with directions and contact.
- **🔍 Search First Aid by Condition** – Symptom- and condition-based search with severity tags.
- **📖 First Aid Info Pages** – Medical summaries with symptoms, treatment, kits needed, severity, and doctor type.
- **📇 User Medical Profile** – Store blood group, allergies, chronic illnesses, and emergency contacts.
- **🌐 Offline Support** – Access to saved emergency data even without internet.
- **🧠 Smart Filtering** – Filter by injury type, body part, or urgency.
- **📌 Favorites** – Save frequently used aid guides or hospitals.

### 🌟 Planned Features (Future)
- **🎙️ Voice Commands** – Hands-free emergency access.
- **📸 Image Recognition** – Upload injury pictures to get aid suggestions.
- **🌐 Multilingual Support** – First aid content in Hindi, Tamil, Telugu, etc.
- **🧑‍🤝‍🧑 Community Discussions** – Share stories, ask questions, crowdsource local help.
- **⌚ IoT Integration** – Smartwatch & wearable support for vitals/emergency alerts.
- **🛍️ First Aid Shop** – Curated kits and health supplies.
- **🤖 AI Symptom Assistant** – Chatbot to help assess severity & give aid.
- **📚 Tutorials & Workshops** – Learn CPR, burns, trauma care via videos.

---

## 🧰 Tech Stack

### 💻 Frontend
- **Flutter** (Material 3 UI)
- **Dart**
- **Provider** (state management)
  
### ☁️ Backend & Services
- **Firebase** (Auth, Firestore, Storage)
- **Firebase Cloud Functions**
- **Firebase Analytics**
  
### 🗺️ APIs & SDKs
- **Google Maps API** (Nearby hospitals)
- **Geolocator**
- **Flutter Phone Direct Caller**

### 🧪 Testing & QA
- **BrowserStack / LambdaTest** (cross-platform testing)
- **Codecov** (code coverage)
- **Honeybadger** (real-time crash/error reporting)

### 🔐 DevOps & Security
- **Travis CI** (CI/CD)
- **Doppler** (secret management)
- **AstraSecurity** (web/admin panel security)

### 📦 Package Highlights
```yaml
dependencies:
  flutter:
  firebase_core: ^...
  cloud_firestore: ^...
  google_maps_flutter: ^2.5.3
  geolocator: ^14.0.2
  flutter_phone_direct_caller: ^...
  provider: ^6.1.2
