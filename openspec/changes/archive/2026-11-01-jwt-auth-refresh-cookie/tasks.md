# Tasks

## 1. Account and refresh-session persistence

- [x] 1.1 Add compatible password-hashing and JWT dependencies; verify the bundle resolves with `bundle check`.
- [x] 1.2 Add additive migrations and `User`/`RefreshSession` models for normalized unique emails, password digests, refresh-token digests, family identifiers, expiry, and revocation; verify migrations apply and focused model specs cover validation and associations.
- [x] 1.3 Add model specs for password and email validation plus service specs proving refresh-token digests are stored instead of raw tokens; verify with `bundle exec rspec spec/models spec/services/authentication`.

## 2. Token and refresh-session services

- [x] 2.1 Implement access-JWT issuance and verification with a fixed algorithm, required signing secret, account subject, and 15-minute expiry; verify valid, malformed, wrong-signature, and expired-token service specs.
- [x] 2.2 Implement opaque refresh-token creation and digest-only persistence with an absolute 30-day family deadline; verify generated tokens are unique and the stored value is not the raw token.
- [x] 2.3 Implement transactional refresh rotation, logout revocation, and token-family reuse detection; verify service specs for rotation, expiry, replay, and revocation.

## 3. Authentication endpoints and cookie lifecycle

- [x] 3.1 Add registration, login, refresh, and logout routes and controller actions under `/api/v1/auth`; verify route recognition and request specs for success, validation, and generic invalid-credential responses.
- [x] 3.2 Enable cookie middleware and issue/replace/expire the host-only refresh cookie with the specified HttpOnly, SameSite, path, and production Secure attributes; verify cookie assertions in request specs.
- [x] 3.3 Validate the configured request origin for refresh and logout and reject missing/mismatched origins without rotating a session; verify CSRF-focused request specs.

## 4. Protect REST writes and GraphQL mutations

- [x] 4.1 Add shared Bearer-token authentication to REST write actions for books and authors while retaining public reads; verify request specs for unauthenticated 401, authenticated writes, and public GET routes.
- [x] 4.2 Populate GraphQL context with the authenticated user and require it in the shared mutation base class; verify GraphQL request specs for public queries, rejected unauthenticated mutations, and successful authenticated mutations.
- [x] 4.3 Verify authentication errors do not execute or partially persist protected writes; run the focused REST and GraphQL request specs.

## 5. Configuration and integration

- [x] 5.1 Add required signing-key and allowed-origin configuration for each deployment environment without committing secrets; verify startup/configuration fails clearly when required production values are missing.
- [x] 5.2 Document registration, login, Bearer access-token use, refresh-cookie behavior, logout, and the same-site browser assumption; verify the documented routes and cookie behavior match the request specs.
- [x] 5.3 Run the complete RSpec suite and `openspec validate jwt-auth-refresh-cookie --strict`; resolve any regressions or specification-format errors.
