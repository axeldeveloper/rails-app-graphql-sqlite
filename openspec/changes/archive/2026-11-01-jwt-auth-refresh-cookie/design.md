# Design

## Context

See [proposal.md](./proposal.md) for motivation and [authentication spec](./specs/authentication/spec.md) for externally visible behavior. The application is Rails 7.1 in API-only mode, with REST resources under `/api/v1` and a GraphQL endpoint at `/graphql`. There is no `User` table or authentication dependency. Cookie middleware is currently commented out in `config/application.rb`; REST controllers derive from `Api::ApplicationApiController`, while GraphQL uses a separate controller and schema.

## Goals / Non-Goals

**Goals:**
- Keep access-token authentication consistent across REST and GraphQL while retaining their public read behavior.
- Keep long-lived refresh credentials out of JSON responses, browser-accessible storage, database plaintext, and logs.
- Make refresh-session rotation and revocation persistent and safe to retry or reject.

**Non-Goals:**
- Roles, per-record ownership, and authorization beyond requiring an authenticated account for writes. Any authenticated account can perform the existing book and author write operations.
- Password reset, email verification, social login, a browser UI, and cross-site frontend support.
- Immediate revocation of already-issued access JWTs. Logout revokes refresh sessions; access JWTs expire within 15 minutes.

## Decisions

### Separate short-lived access JWTs from opaque refresh credentials

Use signed JWTs only for access tokens, sent as `Authorization: Bearer`. Include the account subject and standard issue/expiration claims; validate the configured signing algorithm and expiration and reject malformed tokens. Keep the access lifetime at 15 minutes. Store the signing key in encrypted Rails credentials or a required environment secret, separate from application/client data, and fail startup or token issuance when it is missing.

Use a cryptographically random opaque refresh token instead of a second JWT. A refresh session stores the token's SHA-256 digest, account, family identifier, absolute expiration, and revocation state. The raw refresh value exists only in the response cookie and request memory. This design allows server-side revocation and reuse detection, unlike a stateless refresh JWT. Add `bcrypt` for Rails `has_secure_password` and a maintained JWT library for access-token signing and verification; lock compatible versions in the bundle.

### Model refresh rotation as a persistent token family

Add a `User` model with normalized, case-insensitively unique email and `password_digest`, and a `RefreshSession` model associated with a user. Persist a family identifier and keep revoked token digests through the family expiration so reuse can be detected. On refresh, verify and replace the active digest in a database transaction; on reuse, revoke all sessions in that family. The 30-day family deadline is absolute and is not extended by rotation. Keep this logic in a session/token service rather than duplicating it in controller actions.

### Isolate authentication endpoints and browser cookie handling

Add `POST /api/v1/auth/register`, `/login`, `/refresh`, and `/logout`, implemented by a dedicated authentication controller and service layer. Registration and login create a refresh session and issue an access token; refresh rotates both credentials; logout revokes the presented session. Return only the access token and safe account fields in JSON.

Enable `ActionDispatch::Cookies` middleware for the API-only application and make cookie access available to the auth controller. Set the refresh cookie with `HttpOnly`, `SameSite=Lax`, `Path=/api/v1/auth`, and `Secure` in production; leave `Domain` unset to keep the cookie host-only. Expire it on rejected refresh and logout. Configure the exact allowed browser origin per environment and validate it for refresh and logout requests; do not use wildcard origins with credentials. Same-site deployments are in scope; cross-site deployments would need a separate CORS and cookie policy decision.

### Share bearer authentication, enforce writes at each API boundary

Implement a shared bearer-token authenticator that resolves the current user without raising for ordinary public reads. In `Api::ApplicationApiController`, require authentication on create, update, and destroy actions for books and authors, returning the existing API's JSON error style with HTTP 401. Keep read actions and the genre filter public.

For GraphQL, resolve the same bearer token in `GraphqlController` and pass `current_user` through schema context. Enforce authentication in the shared GraphQL mutation base class so every mutation, including future mutation fields, is protected; do not infer authorization from the HTTP verb because GraphQL queries and mutations both use POST. Keep GraphQL queries public and return a GraphQL authentication error without executing an unauthenticated mutation.

### Treat the refresh cookie as a CSRF-sensitive credential

The refresh cookie is sent automatically by browsers, so refresh and logout remain POST-only and require a matching configured `Origin`. `SameSite=Lax` provides defense in depth but is not the sole CSRF control. Do not rely on HttpOnly as a CSRF defense. Do not enable credentialed cross-origin CORS as part of this same-site change.

## Risks / Trade-offs

- [A signing-key leak permits forged access tokens until the key is replaced] → Store a dedicated secret in credentials/environment configuration, never commit it, and reject tokens with any algorithm other than the configured one.
- [A stolen refresh token can be used until rotation or expiration] → Persist only digests, rotate each use, revoke the family on reuse, use HTTPS and a host-only HttpOnly cookie, and keep the family deadline to 30 days.
- [A reused refresh token can indicate a legitimate concurrent refresh race] → Serialize refresh of a session in a transaction and test concurrent/replayed requests; fail closed by revoking the family when reuse is confirmed.
- [Adding authentication changes existing write clients] → Keep reads public, document the Bearer header and auth endpoints, and return consistent 401 responses rather than silently accepting unauthenticated writes.
- [Public registration and login can be abused] → Keep responses generic where account existence could be revealed, avoid logging credentials, and consider rate limiting before production exposure.
- [Cookie origin configuration can be incorrect after deployment] → Require an explicit allowed origin for production and test cookie and origin behavior in request specs.

## Migration Plan

1. Add password/JWT dependencies, additive user and refresh-session migrations, and the required signing-key and allowed-origin configuration before enabling protected writes.
2. Deploy the authentication endpoints, cookie middleware, shared bearer authentication, and route/mutation protection together so clients can register or log in before making writes.
3. Keep the database migration additive. To roll back application code, redeploy the previous version and leave user/session tables in place; do not reverse the migration after accounts have been created without an explicit data-retention decision.

## Open Questions

None. The frontend is assumed to be same-site with the API; cross-site clients are out of scope for this change.
