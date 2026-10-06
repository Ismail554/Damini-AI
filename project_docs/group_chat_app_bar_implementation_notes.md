# 🚀 Backend Implementation Notes: Group Chat App Bar

To the Frontend Developer: 

I have fully implemented **100% of the backend features** requested in your `group_chat_app_bar_api_spec.md`. The database schema has been updated to handle inactive members and `SYSTEM` message types, and the WebSocket layer is now fully operational.

Here are the details on the live endpoints:

---

## 1. Endpoints Deployed

You can now hit all of the following endpoints. They exactly match the request and response shapes defined in your spec.

| Action | HTTP Endpoint |
| :--- | :--- |
| **Fetch Header** | `GET /api/v1/notifications/chat/conversations/{id}/header/` |
| **Confirm Investors** | `POST /api/v1/notifications/chat/conversations/{id}/confirm-investors/` |
| **Remove Participant** | `DELETE /api/v1/notifications/chat/conversations/{conversation_id}/participants/{user_id}/` |
| **Leave Group** | `POST /api/v1/notifications/chat/conversations/{id}/leave/` |
| **Report Group** | `POST /api/v1/notifications/chat/conversations/{id}/report/` |

---

## 2. WebSocket & System Messages (Live!)

The coolest part of this implementation is the WebSocket layer. When an action occurs via the REST APIs above (like confirming an investor, leaving, or removing someone), the backend **automatically**:
1. Creates a `SYSTEM` message in the database (e.g., `"🎉 Confirmed investors: David Chen... has joined!"`).
2. Broadcasts it instantly over `ws/chat/{conversation_id}/`.

### WebSocket Events to Listen For
Ensure your Flutter app's WebSocket listener handles these specific `event_type` strings:
- `investor_confirmed`
- `participant_removed`
- `participant_left`

The payload for these WebSocket events exactly matches your specification.

---

## 3. Security (RBAC) Notes
- The backend strictly enforces that **only the Project Creator** (Sponsor) can call `/confirm-investors/` and `/participants/{user_id}/`. Any other user will get a `403 Forbidden`.
- The backend strictly prevents the Project Creator from calling `/leave/`. They will get a `400 Bad Request`.

You are good to go! Everything is live.
