# Hsum Chaint mobile

Native Flutter app for donors (system role 3) and monks (system role 2).
The C# controllers, DTOs and service rules in the sibling backend repository are
the source of truth. The HTML file is a visual reference; its role switcher,
API inspector, example users and demo responses are not shipped.

## Run

Use the backend origin only; paths already include /api or /api/v1:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=https://your-api-host
```

The development default is https://localhost:7067, from the backend launch
settings. On Android Emulator, localhost refers to the emulator. For the local
HTTP profile, run the backend on a reachable interface at port 5174 and use:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5174
```

Android permits HTTP in debug builds only. Physical devices need a reachable
LAN host or HTTPS deployment; iOS needs a trusted HTTPS certificate.
Android uses NDK r29 stable (29.0.14206865) instead of the previous beta pin.
Release builds should use the deployed HTTPS origin. Configure the backend's
database and JWT settings using its own README before testing live requests.
Certificates are never bypassed by the client.

## Implemented

- Burmese donor/monk authentication, registration and role-specific five-tab shell.
- Calendar with month navigation, monastery/status filters, daily offerings and pending review count.
- Paginated donor history and monastery operations, one-time and monthly recurring
  requests, manual entries and batch entry queue.
- Review notes, scheduling, completion, cancellation and permission-gated deletion.
- Public monastery listing and separate keyword search, joined spaces, received
  invitations, monastery creation/edit/delete, member invitations/roles/removal.
- Paginated notifications, unread badge, mark-read, swipe-delete and clear-all.
- Account editing, monk profile and delivery/notification settings using native pickers.

GetX, go_router and Dio remain in place. No new packages were added.
Padauk Regular/Bold are bundled for offline Burmese text with their SIL Open Font
License in assets/fonts/OFL.txt; source: https://github.com/google/fonts/tree/main/ofl/padauk. Backend
Result envelopes and pagination are parsed explicitly. Access-token refresh is
shared across concurrent expired requests and retried once. Logout clears
credentials; sessions live in memory and app restarts require login.

## Backend-specific behavior

- Register uses POST /api/v1/auth/register with roleId 2 or 3. The backend has no
  OTP or password-recovery endpoints, so these legacy screens are not routed.
- Login returns data.id, data.accessToken, data.refreshToken, roleId and permissions;
  profile data is loaded separately from /api/user/{id}.
- Listing uses /api/v1/monasteries; nonblank search uses /search?keyword=...
  with pageNumber/pageSize. Ordering is owned by the backend.
- Manual donations require a managing space role as well as route permission.
  Space capability hints match the backend's default Owner/Admin/Editor/Viewer
  seed roles; the backend rechecks permissions for every request and displays
  refusals in the app. There is no effective per-space permissions DTO.
- Donation deletion requires the login permission Donation.Delete. Some backend
  seed scripts do not assign that permission to monks, so deletion stays hidden
  until the backend issues it. Completed donations cannot be deleted or cancelled.
- The calendar groups dates in UTC using pickupTime, falling back to createdAt.
  Detail times are displayed in device local time. The API does not expose
  per-meal morning/noon grouping, member counts on monastery listing DTOs or a
  separate reviewerNote field; the app does not fabricate those fields.
- Settings are nullable DateTime values, not time-only values.
- One-time schedules/settings are sent as UTC ISO timestamps. Recurring requests
  send StartDate, DayOfMonth, MonthsCount and signed TimeSpan strings offset from
  the backend's UTC midnight to preserve the selected local calendar day.
  Missing days (e.g. February 31) are clamped by the backend. Recurrence assumes
  the device's UTC offset at the selected start date, suitable for Myanmar's
  fixed timezone; automatic adjustment across daylight-saving changes is not provided.
- In-app notifications are loaded from the API on screen entry and after changes.
  Background push delivery and polling are not added.

## Verification

```powershell
flutter analyze
flutter test
flutter build web
```

Tests use a fake Dio transport and exercise real request/response parsing,
refresh failure/concurrency, API paths and payloads, authorization controls,
Burmese layouts and donation workflows. They do not replace a live backend/device
smoke test with donor and monk accounts.
