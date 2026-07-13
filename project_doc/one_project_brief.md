# Project Brief: Damani AI

## 1. Project Overview

**Damani AI** is a professional investment and sponsorship platform built with **Flutter**. The application creates a seamless ecosystem connecting **Investors** and **Sponsors** through a structured onboarding process, secure authentication, and profile verification system.

---

## 2. Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| State Management | Riverpod (Provider / StateNotifier / AsyncNotifier) |
| Local Storage | Shared Preferences or Flutter Secure Storage (UUID & onboarding status) |
| Architecture | Feature-first Folder Structure |

---

## 3. Visual Identity & Theme

Damani AI follows a premium, modern, and technology-focused design language using a consistent gradient background across both Dark and Light themes.

### 3.1 Color Palette

#### Dark Theme (Default)

- **Top:** `#050E17`
- **Center:** `#0A1F33`
- **Bottom:** `#040A10`

#### Light Theme

- **Top:** `#F0F4F8`
- **Center:** `#E1E9F0`
- **Bottom:** `#D6E0E9`

#### Accent Colors

- Cyber Blue
- Gold
- White (Primary Text)

---

### 3.2 UI Component Strategy

#### Glassmorphism

Use frosted-glass cards with blurred translucent backgrounds so the gradient remains visible.

#### Consistent Background

A reusable `BaseScaffold` widget should provide the application's gradient background for every screen.

---

## 4. User Flow

### Phase 1 — Launch & Authentication

### Splash Screen

On launch:

1. Check for stored UUID.
2. Check `isFirstTime` flag.

Navigation logic:

- **First launch** → 4-screen onboarding
- **Returning user** → Authentication

---

### Onboarding

Four swipeable introduction screens highlighting:

- Investment opportunities
- Sponsor discovery
- Secure verification
- Professional networking

---

### Authentication

#### Login

- Email
- Password
- Forgot Password

#### Sign Up

- Full Name
- Email
- Password

#### OTP Verification

- Email-based OTP
- Timer & resend functionality

#### Success Screen

Animated confirmation before continuing.

---

### Password Recovery Flow

Email Input

↓

OTP Verification

↓

Create New Password

↓

Return to Login

---

## 5. Role Selection & Profile Onboarding

After account creation, users choose one role:

- Investor
- Sponsor

---

### Role-Specific Flow

#### Step 1 — Introduction

Overview of platform features for the selected role.

#### Step 2 — Choose Type

Examples:

- Individual
- Institutional

---

#### Step 3 — Complete Profile

Collect information such as:

- Phone Number
- Location
- Biography
- Additional details

---

#### Step 4 — Interests

Choose industries or investment categories.

---

#### Step 5 — Company Verification

Upload:

- Government ID
- Company documents
- Verification files

---

#### Step 6 — Company Profile

Configure public-facing organization profile.

---

### Verification Pending

Display verification status with explanation.

Actions:

- Wait for approval
- **Skip to App** (dashboard accessible while verification is pending)

---

## 6. State Management (Riverpod)

### ThemeModeProvider

Responsibilities:

- Dark Mode (default)
- Light Mode
- Theme persistence

---

### AuthProvider

Responsibilities:

- Login
- Signup
- Session management
- OTP timer
- Authentication state

---

### OnboardingProvider

Responsibilities:

- Current onboarding page
- UUID persistence
- First-launch detection

---

### ProfileProvider

Responsibilities:

- Multi-step onboarding forms
- Validation
- Temporary profile data
- Submission

---

## 7. Proposed Directory Structure

```text
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── gradients.dart
│   │   └── styles.dart
│   │
│   ├── theme/
│   │   ├── dark_theme.dart
│   │   ├── light_theme.dart
│   │   └── theme_provider.dart
│   │
│   └── common_widgets/
│       ├── base_scaffold.dart
│       ├── custom_button.dart
│       ├── glass_card.dart
│       └── loading_indicator.dart
│
├── features/
│   ├── onboarding/
│   ├── auth/
│   ├── role_selection/
│   └── profile_setup/
│
└── main.dart
```

---

## 8. Development Guidelines

### Gradient Consistency

Every screen must be wrapped with the application's reusable `BaseScaffold` so the gradient background remains consistent throughout the app.

---

### Responsive Design

Use:

- `Sizer`
- `LayoutBuilder`
- Responsive spacing
- Adaptive typography

to ensure consistent layouts across all screen sizes.

---

### Security

The UUID and onboarding status must be checked **before the first frame is rendered** to avoid flickering between:

Splash Screen → Onboarding → Authentication

---

## 9. Core Features Summary

- Professional Flutter application
- Investor & Sponsor ecosystem
- Secure email authentication
- OTP verification
- Password recovery
- Multi-step profile onboarding
- Company verification workflow
- Glassmorphism UI
- Premium gradient theme
- Riverpod state management
- Feature-first architecture
- Responsive layouts
- Persistent onboarding and session handling

---

## 10. Future Enhancements

Potential roadmap items:

- Push notifications
- Real-time messaging
- AI-powered investment matching
- Document OCR verification
- Video KYC
- Admin moderation dashboard
- Analytics dashboard
- Multi-language support
- In-app support chat
- Dark/Light theme customization
```