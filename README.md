# 💳 EasyCash - Mobile Banking & Digital Wallet App

EasyCash is a modern, feature-rich digital banking and wallet application built with **Flutter** and powered by **Firebase Auth** and **Cloud Firestore**. Designed with a sleek dark-themed glassmorphism UI, smooth 3D animations, real-time balance tracking, and secure 4-digit MPIN authentication.

---

## ✨ Features

### 🔐 Authentication & Security
- **4-Digit MPIN Authentication**: Custom phone number + MPIN sign-up and login mechanism backed by Firebase Auth.
- **Change MPIN**: In-app security update allowing users to change their 4-digit security PIN after re-authenticating.
- **Account Management**: Option to safely close and permanently delete account data from Firestore along with transaction history.

### 💰 Wallet & Financial Operations
- **Real-Time Balance Tracking**: Streamed balance updates directly synced with Cloud Firestore.
- **Instant Money Transfer**: Send money to major Pakistani banks (HBL, UBL, Meezan Bank, Bank Alfalah, MCB, ABL, Faysal Bank, etc.) with 14-digit account validation and transfer notes.
- **Atomic Balance Updates**: Micro-transactions managed via Firestore database transactions to ensure consistency.

### 🎴 Interactive Virtual Cards
- **3D Card Flip Animation**: Interactive card component with smooth 3D rotation revealing card details (Account Number, Expiry, CVV).
- **Animated Metallic Shine**: Custom shader mask producing continuous light-reflection animations on card assets.

### 📜 Transaction History & Digital Receipts
- **Filterable History**: View complete transaction logs with filter options (*Last 7 Days, Last 1 Month, Last 6 Months, Last 1 Year*).
- **Real-Time Logs**: Green/red status indicators for incoming and outgoing transfers.
- **Payment Success Screen**: Digital receipt view with generated transaction IDs, formatted timestamps, and custom animated checkmark graphics.

### 🎨 Design & Visual Experience
- **Dark Glassmorphism Theme**: Glossy frosted containers, glowing borders, and dark gradient radial backgrounds.
- **Custom Canvas Graphics**: Custom painters for background geometric curves and success pattern animations (`BackgroundLinesPainter`, `SuccessPatternPainter`).
- **Seamless Page Transitions**: Custom smooth fade and slide route transitions (`FadeRoute`).

---

## 🛠 Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
- **Backend Services**:
  - `firebase_core`: Firebase initialization.
  - `firebase_auth`: Secure user registration and session management.
  - `cloud_firestore`: Real-time database for user profiles, balances, and transaction logs.
- **UI & Helpers**:
  - `google_fonts`: Typography enhancements.
  - `intl`: Date formatting and numeric display.
  - `pinput`: Smooth pin input fields.
  - `shimmer`: Loading and shine visual effects.
  - `qr_flutter` & `mobile_scanner`: QR generation and scanning support.

---

## 📁 Project Architecture

```
lib/
├── main.dart                   # Application entry point & Firebase initialization
├── screens/
│   ├── started.dart            # Onboarding / Get Started screen with animated card
│   ├── login.dart              # User login screen with Phone & MPIN
│   ├── signup.dart             # Account creation screen (Full Name, CNIC, Phone, MPIN)
│   ├── home.dart               # Main dashboard with balance card & quick actions
│   ├── send.dart               # Money transfer screen with bank selection & amount input
│   ├── transaction.dart        # Transaction receipt screen with animated success checkmark
│   ├── history.dart            # Complete transaction history with dynamic filters
│   ├── cards.dart              # Interactive 3D flipping virtual card viewer
│   ├── profile.dart            # Settings, notifications toggle, and account deletion
│   └── change_mpin.dart        # Secure 4-digit MPIN update screen
├── services/
│   ├── auth_service.dart       # Firebase Authentication & MPIN helper logic
│   └── database_service.dart   # Firestore CRUD operations & transaction handler
└── utils/
    └── fade_route.dart         # Custom page navigation animation transition
```

---

## 🚀 Getting Started

### Prerequisites
1. Installed [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12+ recommended).
2. Connected Android/iOS Device or Emulator.
3. Firebase project configured with Android/iOS app files (`google-services.json` / `GoogleService-Info.plist`).

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/mughasaad-droid/Easycash.git
   cd Easycash
   ```

2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
