# Backend Requirements & API Specification — Damini AI Project Creation

> **Audience**: Backend Development Team (Django / DRF)  
> **Source**: Flutter Frontend Engineering  
> **Feature**: AI-Powered Project Creation & Blueprint Generation Flow (`Damini Advisor`)  
> **Status**: Ready for Integration / Action Required  

---

## 1. Overview & Architecture

The mobile app includes an AI conversational assistant (`Damini Advisor`) that guides sponsors through drafting a project step-by-step:
1. **Industry Selection** (`industry`)
2. **Project Concept & Description** (`description`)
3. **Funding Target & Financials** (`funding_goal`)
4. **Blueprint Generation & Final Review** (`done`)

On step 4 (`done`), the backend returns a generated `draft` object. When the sponsor taps **"Apply Blueprint to Create & Edit Project"**, this draft pre-populates all 18+ fields in the Project Creation & Editing form (`CreateProjectView`), allowing sponsors to edit and review before launching or saving.

```
┌─────────────────────────────────┐
│ AI Chat Session (Step 1 -> 4)   │
│ - Dynamic Suggestions per step  │
└────────────────┬────────────────┘
                 │ Step 4: Complete
                 ▼
┌─────────────────────────────────┐
│ Blueprint Card Generated        │
│ "Apply Blueprint to Project"    │
└────────────────┬────────────────┘
                 │ Pre-fill
                 ▼
┌─────────────────────────────────┐
│ Create & Edit Project Form      │
│ (All fields loaded & editable)  │
└─────────────────────────────────┘
```

---

## 2. API Endpoints

### 2.1 Start Conversation
- **Method**: `POST`
- **Path**: `/api/v1/ai/projects/conversations/`
- **Auth**: Bearer Token required

#### Request Body:
```json
{
  "initial_context": "Clean energy project in Austin" // Optional
}
```

#### Expected Response (`200 OK`):
```json
{
  "conversation_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "step": "industry",
  "step_index": 1,
  "total_steps": 4,
  "step_title": "Select Industry",
  "message": {
    "id": "msg_001",
    "content": "Hi, I'm Damini Advisor. I will guide you through creating your project. To start, what industry is your project in?",
    "role": "assistant",
    "timestamp": "2026-10-12T09:00:00Z",
    "suggestions": [
      "Technology",
      "Clean Energy",
      "Real Estate",
      "Healthcare",
      "Fintech"
    ]
  }
}
```

> **CRITICAL REQUIREMENT**: `message.suggestions` **MUST** be returned in the assistant's message. The mobile app renders these as interactive chips that update dynamically on every response.

---

### 2.2 Send Message & Advance Conversation
- **Method**: `POST`
- **Path**: `/api/v1/ai/projects/conversations/{conversation_id}/messages/`
- **Auth**: Bearer Token required

#### Request Body:
```json
{
  "content": "Technology"
}
```

#### Step Progression Responses:

#### Step 2 Response: Project Concept (`200 OK`)
```json
{
  "step": "description",
  "step_index": 2,
  "total_steps": 4,
  "step_title": "Project Concept",
  "message": {
    "id": "msg_003",
    "content": "Great! Technology is booming. Now tell me about your project concept. What problem does it solve and what is its unique value?",
    "role": "assistant",
    "timestamp": "2026-10-12T09:01:00Z",
    "suggestions": [
      "AI-driven diagnostic platform for rural clinics",
      "B2B SaaS supply chain optimization tool",
      "Next-generation cybersecurity defense hub"
    ]
  },
  "extracted_data": {
    "industry": "Technology"
  },
  "draft": null
}
```

#### Step 3 Response: Funding Target (`200 OK`)
```json
{
  "step": "funding_goal",
  "step_index": 3,
  "total_steps": 4,
  "step_title": "Funding Target",
  "message": {
    "id": "msg_005",
    "content": "Exciting concept! What is your total funding target to launch and scale this venture?",
    "role": "assistant",
    "timestamp": "2026-10-12T09:02:00Z",
    "suggestions": [
      "$500,000",
      "$1,500,000",
      "$5,000,000",
      "$10,000,000"
    ]
  },
  "extracted_data": {
    "industry": "Technology",
    "description": "AI-driven diagnostic platform..."
  },
  "draft": null
}
```

#### Step 4 Response: Blueprint Ready (`200 OK`)
```json
{
  "step": "done",
  "step_index": 4,
  "total_steps": 4,
  "step_title": "Blueprint Ready!",
  "message": {
    "id": "msg_007",
    "content": "Your AI project blueprint is ready! I've structured your financials, timeline, and target returns. Review the card below and apply it to edit full project details.",
    "role": "assistant",
    "timestamp": "2026-10-12T09:03:00Z",
    "suggestions": [
      "Apply to Project"
    ]
  },
  "extracted_data": {
    "industry": "Technology",
    "description": "AI-driven diagnostic platform...",
    "funding_goal": "5000000"
  },
  "draft": {
    "id": "draft_48f8a123-74b8",
    "title": "MedAI: Autonomous Clinical Diagnostics Hub",
    "short_description": "AI-powered diagnostic platform empowering rural and underserved clinics with instant pathology insights.",
    "full_description": "MedAI bridges the diagnostic divide by equipping clinics with machine learning pipelines capable of analyzing medical imaging and patient vitals in real time.",
    "minimum_investment": "25000",
    "funding_goal": "5000000",
    "target_roi": "24",
    "industry": "Technology",
    "industry_id": 1,
    "country": "United States",
    "location": "Austin, TX",
    "funding_stage": "Seed",
    "timeline": "24 months",
    "timeline_months": 24,
    "current_status": "MVP validated in 3 pilot clinics; proprietary model trained on 100k anonymized scans.",
    "next_milestones": "FDA clearance submission Q1 2027; commercial rollout across 40 clinics Q3 2027.",
    "use_of_funds": "45% R&D & Regulatory, 30% Clinical Validation, 15% Sales & Marketing, 10% Operations.",
    "skin_in_the_game": "500000",
    "minimum_contribution": "10000",
    "expected_roi": "24",
    "potential_monthly_revenue": "180000",
    "hold_period_months": 36,
    "timeline_to_operations_months": 12,
    "team_members_text": "Dr. Sarah Lin (Chief Medical Officer), David Vance (AI Lead, Ex-Google)",
    "confidentiality_agreement_text": ""
  }
}
```

---

### 2.3 Get Conversation History
- **Method**: `GET`
- **Path**: `/api/v1/ai/projects/conversations/{conversation_id}/`
- **Auth**: Bearer Token required

#### Expected Response (`200 OK`):
```json
{
  "conversation_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "step": "description",
  "step_index": 2,
  "total_steps": 4,
  "step_title": "Project Concept",
  "messages": [
    {
      "id": "msg_001",
      "content": "Hi, I'm Damini Advisor...",
      "role": "assistant",
      "timestamp": "2026-10-12T09:00:00Z",
      "suggestions": ["Technology", "Clean Energy"]
    },
    {
      "id": "msg_002",
      "content": "Technology",
      "role": "user",
      "timestamp": "2026-10-12T09:00:30Z"
    }
  ],
  "extracted_data": {
    "industry": "Technology"
  },
  "draft": null
}
```

---

### 2.4 Reset / Delete Conversation
- **Method**: `DELETE`
- **Path**: `/api/v1/ai/projects/conversations/{conversation_id}/`
- **Expected Response**: `200 OK` or `204 No Content`

---

## 3. Key Backend Guidelines & Action Items

### 3.1 Suggestions Must Change Dynamically Per Step (P0)
- In the initial response: suggestions must be popular **industries**.
- In step 2 (`description`): suggestions must be **project concept ideas matching the selected industry** (e.g. if the sponsor selected "Clean Energy", suggestions should be "Solar farm", "EV charging network", etc.).
- In step 3 (`funding_goal`): suggestions must be **funding amounts** (e.g. `"$500,000"`, `"$2,000,000"`).
- In step 4 (`done`): suggestions should include `["Apply to Project"]`.

### 3.2 Draft Must Always Be an Object (Never a String) (P0)
- `draft` must be `null` while the conversation is in progress.
- Once complete (`step: "done"`), `draft` **MUST be a JSON object / Map**, not a serialized JSON string or draft ID string.
- The mobile app now safely guards against string casts, but for proper data binding, the complete object schema must be returned.

### 3.3 Draft Field Name Compatibility
The Flutter client's `ProjectDraftModel.fromMap` automatically maps either snake_case or camelCase:

| Client Model Property | Backend JSON Key (snake_case) | Backend JSON Key (camelCase) |
|---|---|---|
| `title` | `title` | `title` |
| `shortDesc` | `short_description` | `shortDesc` |
| `fullDesc` | `full_description` / `business_description` | `fullDesc` |
| `minInvestment` | `minimum_investment` | `minInvestment` |
| `fundingGoal` | `funding_goal` | `fundingGoal` |
| `targetRoi` | `target_roi` | `targetRoi` |
| `industry` | `industry` / `industry_name` | `industry` |
| `industryId` | `industry_id` | `industryId` |
| `country` | `country` | `country` |
| `location` | `location` | `location` |
| `fundingStage` | `funding_stage` | `fundingStage` |
| `timeline` | `timeline` / `timeline_months` | `timeline` |
| `status` | `current_status` | `status` |
| `milestones` | `next_milestones` | `milestones` |
| `useOfFunds` | `use_of_funds` | `useOfFunds` |
| `sponsorInvestment` | `skin_in_the_game` | `sponsorInvestment` |
| `minContribution` | `minimum_contribution` | `minContribution` |
| `expectedRoi` | `expected_roi` | `expectedRoi` |
| `monthlyRevenue` | `potential_monthly_revenue` | `monthlyRevenue` |
| `holdPeriod` | `hold_period_months` | `holdPeriod` |
| `timelineOps` | `timeline_to_operations_months` | `timelineOps` |
| `teamMembers` | `team_members_text` | `teamMembers` |
| `ndaAgreement` | `confidentiality_agreement_text` | `ndaAgreement` |

### 3.4 Rate Limiting & Error Responses
- For rate limits / model throttling: Return status `429` with JSON body:
  ```json
  {
    "message": "AI model is currently generating high volume. Please wait.",
    "retry_after": 25
  }
  ```
  The Flutter app automatically renders a live countdown timer and disables sending until the retry interval elapses.
- For conversation expiration: Return `404`, and the app will smoothly start a fresh session.
