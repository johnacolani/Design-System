# Tokens Guide

Design tokens are the single source of truth for your design system.

## Token Repository

- **getTokens(workspaceId)** — Load once at startup or workspace open; uses in-memory and local cache first.
- **refreshTokens(force: true)** — Reload from Firestore and update caches.
- **watchTokens(workspaceId)** — Stream updates; use at top-level (e.g. provider), not in build() of list items.

## Cache invalidation

Tokens are stored in Firestore with a `version` or `updatedAt` field. The repository persists to local storage (shared_preferences on web). Use `refreshTokens(force: true)` when you need the latest from the server.

## Best practice

Do not call Firestore or `getTokens()` inside `build()` or inside list item builders. Load once in initState or in a provider that is initialized at app/route level.
