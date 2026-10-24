# Damani Frontend Compliance & Store Launch Integration Guide

**Target Audience:** Flutter Mobile Developers  
**Production API Base URL:** `https://api.damani.app/api/v1/`  
**Swagger Docs:** `https://api.damani.app/docs/`  
**Public Account Deletion URL:** `https://api.damani.app/account-deletion/`  
**Last Updated:** October 2026  

---

## 📌 Executive Summary
To ensure the Damani mobile app is **approved on the first submission by both the Apple App Store and Google Play Store**, and to comply with financial/securities regulations, the Flutter app requires **3 quick UI implementations** and **1 global string find-and-replace**.

The backend changes are **100% backwards-compatible** — no existing app functionality will break.

---

## 1. User & Content Reporting *(Mandatory for Apple Guideline 1.2)*

### Why It's Required:
Apple **strictly rejects** apps that feature user listings or chat unless users have the ability to report inappropriate content or abusive users, with a guaranteed 24-hour moderation response.

### Where to Add in UI:
1. **Listing / Project Details Screen:**  
   Add a 3-dot overflow menu (`⋮`) or flag icon in the AppBar with an option: **"Report Listing"**.
2. **Chat Conversation Screen:**  
   Add a 3-dot menu in the chat AppBar or on message long-press with an option: **"Report User / Message"**.

### Reporting Bottom Sheet / Dialog:
Show a dialog with:
- **Reason Dropdown / Radio Buttons:**
  - `SPAM` — Spam or Commercial Solicitation
  - `INAPPROPRIATE` — Inappropriate or Offensive Content
  - `HARASSMENT` — Harassment or Bullying
  - `FRAUD` — Suspected Fraud or Misrepresentation
  - `COPYRIGHT` — Intellectual Property Violation
  - `OTHER` — Other Policy Violation
- **Optional Details:** A multiline text field (*"Please provide details..."*).
- **Submit Button:** Calls the API below.

### API Specification:
* **Endpoint:** `POST /api/v1/core/reports/` *(or `/api/v1/moderation/report/`)*
* **Auth:** `Bearer <access_token>`
* **Content-Type:** `application/json`

#### Request Payload:
```json
{
  "reported_project_id": 14,
  "reason": "SPAM",
  "details": "This project contains spam links and misleading revenue claims."
}
```
*(Or if reporting a user or message: pass `"reported_user_id": 25` or `"reported_message_id": 102`)*.

#### Success Response (`201 Created`):
```json
{
  "status": "success",
  "message": "Thank you for your report. Our moderation team reviews all reports within 24 hours.",
  "data": {
    "report_id": 3
  }
}
```

---

## 2. In-App Account Deletion *(Mandatory for Apple 5.1.1 & Google Play)*

### Why It's Required:
Both Apple and Google require that if an app allows account creation, it **must** allow account deletion directly inside the app.

### Where to Add in UI:
* Go to **Settings Screen ➔ Account Settings**.
* Add a red **"Delete Account"** button at the bottom of the screen.
* When tapped, display a confirmation modal:
  > *"Are you sure you want to delete your account? Your personal profile and data will be permanently purged in accordance with our 90-day retention schedule."*
* Require the user to enter their account password to confirm.

### API Specification:
* **Endpoint:** `POST /api/v1/users/delete-account/`
* **Auth:** `Bearer <access_token>`
* **Content-Type:** `application/json`

#### Request Body:
```json
{
  "password": "UserPassword123!"
}
```

#### Success Response (`200 OK`):
```json
{
  "status": "success",
  "message": "Account has been deleted successfully. You have been logged out."
}
```
* **Frontend Action on Success:** Clear local secure storage (`flutter_secure_storage` / `shared_preferences`), clear auth tokens, and navigate to the Login / Onboarding screen.

> ℹ️ **Google Play Store Listing Note:** Google Play requires a public web link for account deletion outside the app. The backend already hosts this live at:  
> **`https://api.damani.app/account-deletion/`** (Use this URL in your Google Play Console Data Safety form).

---

## 3. Legal & Securities Wording Update *(Mandatory Compliance)*

### Why It's Required:
Damani is **not** a licensed broker-dealer or crowdfunding platform; no financial transactions take place inside the app. To prevent securities violations and app store scrutiny, **never use words like "raised", "funded", or "invested"**.

### Global Find & Replace in Flutter Strings:

| Old Term in App | Replace With | Location |
| :--- | :--- | :--- |
| **"Total Raised"** / **"Raised Amount"** | **"Capital Requested"** or **"Capital Committed"** | Project cards, details tab, stats |
| **"Funds Raised"** | **"Indicative Commitments"** | Dashboards, summaries |
| **"Invest Now"** / **"Invest"** | **"Express Interest"** or **"Request Collaboration"** | CTA buttons on project pages |
| **"Investment Amount"** | **"Indicative Amount"** | Offer / collaboration request input |
| **"Target Funded"** | **"Target Committed"** | Progress indicators / progress bars |
| **"Damini"** *(typo)* | **"Damani"** | Headers, branding, AI mentions |

---

## 4. Deal Pipeline & Introductions Tracker *(New Stages)*

When investors and sponsors collaborate, introductions now progress through the official 4 deal stages:

```
[INTERESTED] ➔ [AGREED_TO_PROCEED] ➔ [ROADMAP_SENT] ➔ [CLOSED_OFF_PLATFORM]
                                         ↳ (or DECLINED / WITHDRAWN)
```

### Supported Status Choices on `CollaborationRequest`:
* `INTERESTED` — Investor expressed interest with indicative amount.
* `AGREED_TO_PROCEED` — Sponsor and Investor agreed to move forward (non-binding commitment confirmed).
* `ROADMAP_SENT` — Project roadmap sent to investor.
* `CLOSED_OFF_PLATFORM` — Deal concluded off-platform (self-reported).
* `DECLINED` / `WITHDRAWN` — Deal withdrawn or dropped.
* *(Note: Legacy `PENDING`, `APPROVED`, `CONFIRMED` are still accepted for backwards compatibility).*

### New Fields Returned on `CollaborationRequest`:
```json
{
  "id": 5,
  "project_id": 12,
  "status": "AGREED_TO_PROCEED",
  "proposed_budget": "50000.00",
  "committed_amount": "50000.00",
  "currency": "USD",
  "roadmap_sent_at": "2026-10-24T02:00:00Z"
}
```

---

## 5. RevenueCat Mobile Integration *(PRO Subscriptions)*

The backend is pre-configured with a live RevenueCat webhook listener at:  
`https://api.damani.app/api/v1/subscriptions/revenuecat-webhook/`

### Flutter Setup Steps (`purchases_flutter`):
1. **Add Dependency:**
   ```bash
   flutter pub add purchases_flutter
   ```

2. **Initialize RevenueCat on App Startup (`main.dart`):**
   ```dart
   import 'dart:io';
   import 'package:purchases_flutter/purchases_flutter.dart';

   Future<void> initPlatformState(String userEmail) async {
     await Purchases.setLogLevel(LogLevel.debug);

     late PurchasesConfiguration configuration;
     if (Platform.isAndroid) {
       configuration = PurchasesConfiguration("goog_YOUR_PUBLIC_GOOGLE_KEY");
     } else if (Platform.isIOS) {
       configuration = PurchasesConfiguration("appl_YOUR_PUBLIC_APPLE_KEY");
     }
     
     // Set App User ID to user email so backend webhooks match automatically
     configuration.appUserID = userEmail;
     await Purchases.configure(configuration);
   }
   ```

3. **Trigger Paywall & Purchases (`subscription_provider.dart`):**
   ```dart
   try {
     CustomerInfo customerInfo = await Purchases.purchasePackage(selectedPackage);
     if (customerInfo.entitlements.all["pro_access"]?.isActive == true) {
       // User is now PRO! Backend will sync automatically via webhook.
     }
   } catch (e) {
     // Handle user cancellation or payment failure
   }
   ```

---

## 6. App Reviewer Demo Accounts *(For Store Submission Notes)*

When submitting the build to **App Store Connect** and **Google Play Console**, copy and paste these pre-approved demo credentials:

```text
==================================================
APP STORE & GOOGLE PLAY REVIEW NOTES:
==================================================
1. Investor Demo Account:
   Email:    reviewer.investor@damani.app
   Password: ReviewerDamani2026!

2. Sponsor Demo Account:
   Email:    reviewer.sponsor@damani.app
   Password: ReviewerDamani2026!

Public Account Deletion URL:
https://api.damani.app/account-deletion/
==================================================
```

*(These accounts are permanently pre-vetted with `is_demo: true`, so reviewers can browse active projects, test chat, and sign demo NDAs without affecting live production analytics).*
