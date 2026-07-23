# Damani AI - User Flow Brief

## 1. Initial Entry & Onboarding
*   **Splash Screen:** System checks for UUID and first-time user flag.
*   **First-Time Onboarding:** 
    *   4-screen swipeable introduction.
    *   Final screen leads to **Auth Welcome Screen**.

## 2. Authentication Flow
*   **Auth Welcome Screen:** Choose between **Login** or **Sign Up**.
*   **Login Flow:**
    *   Enter Credentials → Direct to **Main App** (based on previously selected role).
    *   *Sub-flow (Forgot Password):* Email Field → OTP Verification → Reset Password → Return to Login.
*   **Sign Up Flow:**
    *   **Create Account:** Input Name, Email, and Password.
    *   **Email Verification:** Enter OTP sent to email.
    *   **Success Screen:** Visual confirmation of account creation.

## 3. Role Selection & Profile Setup
*   **Role Selection:** User chooses between **Investor** or **Sponsor**.
*   **Role-Based Onboarding:**
    1.  **Start Screen:** Introduction to role-specific capabilities.
    2.  **Choose Type:** Categorize user type (Individual/Corporate).
    3.  **Complete Profile:** Fill in remaining bio/contact data.
    4.  **Interests:** Select preferred industry sectors.
    5.  **Company Info/Verification:** Input company details and upload documents.
    6.  **Verification Pending Screen:** 
        *   Displays status message.
        *   **Action:** "Skip to Dashboard" button to enter the app immediately.

## 4. Main Application (Role-Based)

### A. Investor Role
*   **Tab 1: Explore (Home)**
    *   Welcome Card & Notifications.
    *   Search Project Bar.
    *   Trending Projects (Vertical Scroll).
    *   Featured Opportunities.
    *   **AI FAB:** Floating button for AI assistance.
*   **Tab 2: Saved** (Heart Icon) - Bookmarked projects.
*   **Tab 3: Chat** (Message Icon) - Communication with Sponsors.
*   **Tab 4: Person** (Profile Icon) - Settings and Personal Info.

### B. Sponsor Role
*   **Tab 1: Dashboard** - Project management and statistics.
*   **Tab 2: Saved** - Bookmarked investors or templates.
*   **Tab 3: Chat** - Communication with Investors.
*   **Tab 4: Person** - Business profile and settings.

## 5. Global Navigation Components
*   **Background:** Consistent Gradient (Dark/Light) across all screens.
*   **Chat System:** Common UI for both roles to manage active conversations and messaging.