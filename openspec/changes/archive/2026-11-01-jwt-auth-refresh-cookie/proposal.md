# Proposal

## Why

The Rails API currently has no user model or authentication flow, leaving write operations for books and authors publicly accessible. This change establishes account authentication with short-lived JWT access tokens and a protected refresh-token lifecycle so clients can authenticate writes without storing long-lived credentials in JavaScript-accessible storage.

## What Changes

- Add public account registration and authentication endpoints, plus refresh and logout operations.
- Issue short-lived JWT access tokens for the `Authorization: Bearer` header.
- Deliver refresh tokens only in an HttpOnly cookie, with secure cookie settings, rotation, persistence for revocation, and logout support.
- Require authenticated users for REST write operations and GraphQL mutations while retaining public read operations.
- Add authentication and refresh-session persistence, password handling, authorization integration, and automated coverage.

## Capabilities

### New Capabilities

- `authentication`: Account registration, login, access-token verification, refresh-token rotation and revocation, cookie security, and protection of write operations.

### Modified Capabilities

None.

## Impact

- Database: introduce user and refresh-session records; there is no existing users table.
- Rails API: add authentication endpoints and shared authorization behavior for REST controllers and GraphQL execution.
- GraphQL: populate request context with the authenticated user and require authentication for mutations.
- Middleware/configuration: enable cookie support in the API-only application and configure secure, HttpOnly, SameSite refresh-cookie behavior, including CSRF defenses for cookie-authenticated refresh/logout requests.
- Dependencies and tests: select/introduce password hashing and JWT support, then cover registration, token lifecycle, unauthorized writes, and public reads in the existing RSpec suite.
