Project Brief: Damani AI
1. Project Overview
Damani AI is a professional investment and sponsorship platform built with Flutter. The app facilitates a seamless connection between Investors and Sponsors, utilizing a robust onboarding process and profile verification system.
2. Tech Stack
Framework: Flutter
State Management: Riverpod (Provider/StateNotifier/AsyncNotifier)
Local Storage: Shared Preferences or Flutter Secure Storage (for UUID and Onboarding status)
Architecture: Feature-first Folder Structure
3. Visual Identity & Theme
The app maintains a premium, tech-forward aesthetic using a consistent gradient background across both themes.
3.1 Color Palette
Primary Background (Dark - Default):
Top: #050E17
Center: #0A1F33
Bottom: #040A10
Primary Background (Light):
Top: #F0F4F8
Center: #E1E9F0
Bottom: #D6E0E9
Accent Colors: (Recommended) Cyber Blue / Gold / White Text
3.2 UI Component Strategy
Glassmorphism: Use blurred overlays for cards to let the background gradient shine through.
Consistency: Background logic is handled by a BaseScaffold widget to ensure the gradient is omnipresent.
4. Detailed User Flow
Phase 1: Launch & Authentication
Splash Screen:
System checks for unique UUID and isFirstTime flag.
If first time: Redirect to 4-Screen Onboarding.
If returning: Redirect to Auth Screen.
Onboarding: 4 swipeable screens highlighting app value propositions.
Authentication:
Login: Traditional email/pass. Includes "Forgot Password" flow.
SignUp: Basic inputs (Name, Email, Password).
OTP Verification: Email-based OTP entry.
Success Screen: Animated confirmation before proceeding.
Password Recovery: Email Input → OTP Verify → Change Password → Return to Login.
Phase 2: Role Selection & Onboarding
After account creation, users must select one of two paths:
Investor Role
Sponsor Role
Role-Specific Onboarding Flow:
Start Screen: Introduction to the specific role features.
Choose Type: Selection of sub-categories (e.g., Individual vs. Institutional).
Complete Profile: Remaining data fields (Phone, Location, Bio, etc.).
Interest: Selection of industries or categories of interest.
Company Verify: Submission of official documents or IDs.
Company Profile: Setup of the public-facing company/entity page.
Verification Pending:
Status screen explaining the review process.
Action: Includes a "Skip to App" button allowing the user to browse the dashboard while verification is in progress.
5. State Management Logic (Riverpod)
ThemeModeProvider: Toggles between Dark (Default) and Light modes.
AuthProvider: Handles session, login/signup states, and OTP timing.
OnboardingProvider: Tracks page index and UUID persistence.
ProfileProvider: Manages the multi-step form data during the Role Onboarding phase.
6. Directory Structure (Proposed)
code
Text
lib/
├── core/
│   ├── constants/      # Colors, Gradients, Styles
│   ├── theme/          # Dark/Light Theme data
│   └── common_widgets/ # BaseScaffold, CustomButtons
├── features/
│   ├── onboarding/     # 4-screen onboarding logic
│   ├── auth/           # Login, Signup, OTP, Forgot Pass
│   ├── role_selection/ # Investor vs Sponsor logic
│   └── profile_setup/  # Multi-step verification flow
└── main.dart
7. Development Guidelines
Gradient Consistency: All screens must wrap their content in the LinearGradient container defined in the project requirements.
Responsiveness: Use Sizer or LayoutBuilder to ensure the onboarding and forms look consistent across all device sizes.
Security: UUID check must happen before the first frame is fully rendered to prevent "flicker" between Splash and Onboarding.