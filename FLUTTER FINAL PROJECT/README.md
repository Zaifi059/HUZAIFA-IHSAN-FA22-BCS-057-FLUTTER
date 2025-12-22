**NetworkOfOne** is a comprehensive **Flutter-based basketball referee management system** designed to streamline game scheduling, referee check-ins, GPS verification, and automated payouts.

📱 This application is developed as a **Final Year Mobile Application Development (MAD) Project**.

---

## 🎓 Academic Information

- **Student Name:** Huzaifa Ihsan  
- **Registration No:** FA22-BCS-057  
- **Degree Program:** Bachelor of Computer Science (BCS)  
- **Semester:** 7th Semester  
- **Campus:** COMSATS University Islamabad, Vehari Campus  
- **Course:** Mobile Application Development (MAD)  
- **Submitted To:** **Sir Abrar Saddique**

---
## screenshots

---
## 🌟 Features

### 👥 Multi-Role Support
- **Admin Dashboard**
  - Manage games, referees, and payouts
  - Monitor reports and analytics
- **Scheduler Dashboard**
  - Create and manage games
  - Assign referees and update game details
- **Referee Dashboard**
  - View assigned matches
  - GPS-based check-in system
  - Track earnings and payouts

---

### 🎯 Core Functionality
- 📍 **GPS Check-In** for referee verification
- 🔄 **Real-Time Updates** across dashboards
- 🔐 **Role-Based Authentication**
- 🗺️ **Location Services** (No external API keys required)
- 💸 **Automated Payment Processing**

---

## 💰 Payment System

Supported payment methods:
- **XRPL (XRP Ledger)** – Primary payment method
- **PayPal**
- **Venmo**
- **Bank Transfer**

✔ Payments processed within **3 seconds**  
✔ Automatic retry and stuck-payment resolution  
✔ Complete payout history and tracking  

---

## 🚀 Getting Started

### 🔧 Prerequisites
- Flutter SDK **3.24.0 or later**
- Dart SDK **3.5.0 or later**
- Android Studio / VS Code
- Git
- Android SDK (for APK builds)

---

## 📥 Installation

### 1️⃣ Clone Repository
```bash
git clone https://github.com/neuroxes/NetworkOfOne.git
cd NetworkOfOne
````

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Configure Supabase

Edit `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 4️⃣ Run Application

```bash
flutter run
```

---

## 📱 Build APK

### Debug APK

```bash
flutter build apk --debug
```

### Release APK

```bash
flutter build apk --release
```

### App Bundle (Play Store)

```bash
flutter build appbundle --release
```

📂 Output Location:

* `build/app/outputs/flutter-apk/`

---

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── config/
│   ├── router/
│   ├── theme/
│   ├── widgets/
│   └── utils/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── game_management/
│   ├── check_in/
│   └── payout/
└── services/
    ├── location_service.dart
    ├── automated_payout_service.dart
    └── xrpl_payout_service.dart
```

---

## 🗄️ Database (Supabase)

### Tables

* `users`
* `games`
* `checkins`
* `payouts`
* `game_updates`

✔ Real-time database updates
✔ Secure role-based access

---

## 🔐 Authentication

* Email & password login
* Role-based dashboards
* Session persistence

### 🧪 Test Accounts

```
Admin: admin@networkofone.com / admin123
Scheduler: scheduler@test.com / scheduler123
Referee: referee@test.com / referee123
```

---

## 🛠️ Development Tools

* Flutter
* Dart
* Supabase
* Riverpod
* GoRouter

---

## 📦 Dependencies

* `flutter`
* `supabase_flutter`
* `flutter_riverpod`
* `go_router`
* `google_fonts`
* `location`
* `permission_handler`
* `geocoding`
* `crypto`
* `intl`

---

## 📄 License

This project is developed for **academic purposes** and is licensed under the **MIT License**.

---

## 🏆 Acknowledgment

I would like to express my sincere gratitude to
**Sir Abrar Saddique**
for guidance, supervision, and continuous support throughout the development of this Final Year MAD project.

---

