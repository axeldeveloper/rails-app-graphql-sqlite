# Authentication Specification

## Purpose

Provides account authentication for the Rails API, with short-lived JWT access tokens and a protected refresh-session lifecycle for browser clients. It controls access to write operations while preserving public reads.

## Requirements

### Requirement: Public account registration
The system SHALL allow a person to create an account with an email address and a password of at least 12 characters without prior authentication through `POST /api/v1/auth/register`. Email addresses SHALL be normalized and unique without regard to case, and passwords SHALL be stored using a one-way password hash. Successful registration SHALL return the new account and an access token and set a refresh cookie; responses SHALL NOT expose password material.

#### Scenario: Register a new account
- **WHEN** a client submits a valid, unused email address and password to the registration endpoint
- **THEN** the system creates the account, returns a successful creation response with an access token, and sets a refresh cookie

#### Scenario: Reject a duplicate email address
- **WHEN** a client registers an email address that already belongs to an account, ignoring case
- **THEN** the system rejects the request without creating another account

#### Scenario: Reject invalid registration data
- **WHEN** a client submits a malformed email address or a password that fails the published password policy
- **THEN** the system returns a validation error and does not create an account

### Requirement: Authenticate account credentials
The system SHALL provide a public `POST /api/v1/auth/login` endpoint that verifies an account's email and password. Successful login SHALL return a short-lived access token and set a refresh cookie. Failed login responses SHALL NOT reveal whether the email address or password was incorrect.

#### Scenario: Log in with valid credentials
- **WHEN** a client submits valid account credentials
- **THEN** the system returns an access token and sets a refresh cookie for the account

#### Scenario: Reject invalid credentials
- **WHEN** a client submits an unknown email address or an incorrect password
- **THEN** the system returns the same unauthorized response shape without issuing tokens

### Requirement: Authenticate write operations with access tokens
The system SHALL issue signed JWT access tokens that expire after 15 minutes and SHALL accept them through the `Authorization: Bearer` header. REST write operations for books and authors and all GraphQL mutations SHALL require a valid access token. REST reads and GraphQL queries SHALL remain public. Missing, invalid, or expired credentials SHALL prevent a write from executing and return an unauthorized response.

#### Scenario: Reject an unauthenticated REST write
- **WHEN** a client creates, updates, or deletes a book or author without a valid access token
- **THEN** the system returns HTTP 401 and leaves the resource unchanged

#### Scenario: Accept an authenticated REST write
- **WHEN** a client creates, updates, or deletes a book or author with a valid access token
- **THEN** the system processes the operation as an authenticated user

#### Scenario: Reject an unauthenticated GraphQL mutation
- **WHEN** a GraphQL request attempts a mutation without a valid access token
- **THEN** the system returns a GraphQL authentication error and does not execute the mutation

#### Scenario: Preserve public reads
- **WHEN** a client reads books or authors through REST or submits a GraphQL query without an access token
- **THEN** the system returns the requested public data

#### Scenario: Reject an expired or invalid access token
- **WHEN** a client submits an expired, malformed, incorrectly signed, or unsupported access token for a write
- **THEN** the system returns an unauthorized response and does not execute the write

### Requirement: Protect refresh credentials in an HttpOnly cookie
The system SHALL issue refresh credentials as unpredictable opaque tokens, store only a one-way digest of each token, and deliver the raw token only in an HttpOnly cookie. The cookie SHALL use `SameSite=Lax`, be scoped to `/api/v1/auth`, and be Secure in production. Refresh and logout requests SHALL be protected against cross-site request forgery by validating their origin against the configured same-site origin.

#### Scenario: Set secure refresh-cookie attributes
- **WHEN** registration, login, or token refresh issues a refresh credential
- **THEN** the response sets an HttpOnly cookie with `SameSite=Lax`, the `/api/v1/auth` path, and the Secure attribute in production

#### Scenario: Reject a cross-site refresh request
- **WHEN** a refresh request includes a cookie but its origin is not the configured same-site origin
- **THEN** the system rejects the request and does not rotate the refresh session

#### Scenario: Do not persist a raw refresh token
- **WHEN** a refresh session is created or rotated
- **THEN** the database stores only a digest of the refresh token and the raw value is not written to application logs

### Requirement: Rotate and revoke refresh sessions
The system SHALL limit a refresh session to 30 days from its initial issue and rotate its refresh credential on every successful refresh without extending that absolute session lifetime. Each replacement SHALL invalidate the previous token. Reuse of an invalidated token SHALL revoke the associated token family. An invalid, expired, revoked, or reused refresh token SHALL NOT issue a new access token. Refresh and logout operations SHALL use `POST /api/v1/auth/refresh` and `POST /api/v1/auth/logout`, respectively.

#### Scenario: Refresh a valid session
- **WHEN** a client submits a valid refresh cookie before its expiration
- **THEN** the system issues a new access token, rotates the refresh token, and replaces the cookie

#### Scenario: Reject refresh-token reuse
- **WHEN** a client submits a refresh token that has already been rotated
- **THEN** the system revokes the associated token family, clears the cookie, and requires the account to log in again

#### Scenario: Reject an expired or revoked refresh session
- **WHEN** a client submits an expired, revoked, or unknown refresh cookie
- **THEN** the system rejects the request, clears the cookie, and issues no access token

### Requirement: Log out and clear the refresh cookie
The system SHALL provide a public logout endpoint that revokes the current refresh session and expires the refresh cookie. An access token already issued SHALL remain usable only until its normal expiration.

#### Scenario: Log out an active session
- **WHEN** a client logs out with its refresh cookie
- **THEN** the system revokes that refresh session and expires the cookie

#### Scenario: Prevent refresh after logout
- **WHEN** a client attempts to refresh with the credential revoked by logout
- **THEN** the system rejects the request and issues no new access token
