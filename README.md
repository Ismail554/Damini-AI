# Damani AI - Investment & Sponsorship Platform

**Damani AI** is a professional investment and sponsorship ecosystem built with **Flutter**. The application connects **Investors** and **Sponsors** through structured onboarding, role-based dashboards, company verification workflows, and modern UI design (Dark Gradient Theme & Native iOS Liquid Glass navigation).

---

## 🌟 Key Features

### 1. Dual Role Ecosystem (Investor & Sponsor)
- **Investor Dashboard**: Search project bar, split hero banner carousel, category chips (`Tech`, `Real Estate`, `Health`, `Energy`), Featured Opportunities with Target ROI %, and Trending Now section.
- **Sponsor Dashboard**: Real-time metrics (`Total Views`, `Active Projects`, `Requests`), Active Project raised vs. goal progress, Recent Requests with Review CTA, and Drafts management.
- **Role Switching**: Instant active experience switcher card in Profile view.

### 2. Demo Accounts & Key Validation
Pre-configured credentials in `GlobalKeys` (`lib/shared/global_key.dart`):
- **Investor Demo**: `investor@gmail.com` -> Auto-assigns `investor` role, bypasses onboarding, navigates directly to Investor Home.
- **Sponsor Demo**: `sponsor@gmail.com` -> Auto-assigns `sponsor` role, bypasses onboarding, navigates directly to Sponsor Home.

### 3. Role-Based 6-Step Onboarding
1. **Start Screen**: Role feature slides & introduction.
2. **Choose Type**: Individual vs. Corporate categorization.
3. **Complete Profile**: Bio & contact information setup.
4. **Interests**: Industry sector selection.
5. **Company Verification**: Document upload (Government ID, business registration).
6. **Verification Pending**: Status overview with *"Skip to Dashboard"* quick access.

### 4. UI & Aesthetics
- **Theme**: Premium Dark Gradient background (`#050E17` -> `#0A1F33` -> `#040A10`).
- **Liquid Glass Navigation**: `CustomBottomNavBar` with `BackdropFilter` frosted blur, pop-up animated selected tab icon, and text label placement.
- **Floating Action Buttons**: AI Assistant robot button & Sponsor project creation button.

---

## 🏗️ Clean Architecture & Project Structure

The project strictly follows Clean Architecture and feature-first modularization (<200 lines per file discipline):

```text
lib/
├── controllers/                 # State Management (Providers)
│   ├── auth_provider.dart
│   ├── navigation_provider.dart
│   ├── opportunity_provider.dart
│   └── theme_provider.dart
│
├── core/                        # Core Utilities & Infrastructure
│   ├── constants/               # Colors, Spacing, Assets, Strings
│   ├── routing/                 # AppRouter (GoRouter configuration)
│   ├── services/                # AppService, StorageService, ConnectivityService
│   ├── theme/                   # AppTheme configuration
│   ├── utils/                   # PlatformUtils, Validator
│   └── widgets/                 # CommonBackground, GlassCard
│
├── data/                        # Data Layer
│   ├── models/                  # OpportunityModel, NavTab
│   ├── repositories/            # OpportunityRepository & Implementation
│   └── services/                # OpportunityService
│
├── shared/                      # Global Shared Components
│   ├── global_key.dart          # Storage keys & role key validation
│   ├── screens/                 # Shared onboarding & verification screens
│   └── widgets/                 # Shared role selection & document upload cards
│
├── views/                       # UI Feature Modules
│   ├── auth/                    # Login, Signup, OTP, Forgot & Reset Password
│   ├── home/                    # Shell (`home_view.dart`, `custom_bottom_nav_bar.dart`)
│   ├── investor/                # Investor Feature & Widgets
│   │   ├── investor_dashboard.dart
│   │   └── widgets/             # Carousel, Category Chip, Featured & Trending Cards
│   ├── sponsor/                 # Sponsor Feature & Widgets
│   │   ├── sponsor_dashboard.dart
│   │   └── widgets/             # Metric Card, Active Project Card, Request Card, Draft Card
│   ├── profile/                 # Profile Feature & Components
│   │   ├── investor_profile_view.dart
│   │   └── widgets/             # Profile Hero Card, Account Switcher, Menu Card
│   ├── role_selection/          # Role selection & onboarding entry
│   ├── onboarding/              # 4-Screen swipeable introduction
│   └── splash/                  # Splash Screen
│
├── app.dart                     # App root entry point
└── main.dart                    # App initialization
```

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider |
| **Navigation** | GoRouter |
| **Local Storage** | Shared Preferences (`StorageService`) |
| **Screen Adaptation** | `flutter_screenutil` |
| **Typography** | `google_fonts` (Outfit, Poppins, Roboto) |
| **Vector Assets** | `flutter_svg` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`

### Installation
```bash
# 1. Clone repository
git clone <repository_url>

# 2. Get dependencies
flutter pub get

# 3. Run static analysis
flutter analyze lib/

# 4. Run application
flutter run
```
