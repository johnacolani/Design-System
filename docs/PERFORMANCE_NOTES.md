# Flutter Web Performance — Best Practices

## 1. Reduce Firestore reads

### TokenRepository

- **Location**: `lib/data/repositories/token_repository.dart`
- **API**: `getTokens(workspaceId)`, `refreshTokens(workspaceId, force: true)`, `watchTokens(workspaceId)`
- Load tokens **once** at startup or when opening a workspace (e.g. in `TokensProvider.loadTokens()`). Do **not** call Firestore or `getTokens()` inside `build()` or inside list item builders.
- Cache: in-memory first, then **shared_preferences** (localStorage on web). Cache key includes workspace id; invalidation uses `version` or `updatedAt` from Firestore.
- **TokensProvider** (`lib/providers/tokens_provider.dart`): use `loadTokens(workspaceId)` in init or route enter; use `tokens` getter in UI. For live updates, call `watchTokens(workspaceId)` once at app/route level and listen to the provider.

### Firestore structure (assumption)

- Tokens: `design_systems/{designSystemId}/meta/tokens` — document with `version` (int), `updatedAt` (Timestamp), `tokens` (Map).

---

## 2. Static documentation pages

### DocsService

- **Location**: `lib/services/docs_service.dart`
- **Strategy**: Prefer **assets** for public docs (no network); use **Firestore** only for authenticated private docs.
- **API**: `getDoc(docId, useAsset: true, userId: null)` for public; `getDoc(docId, useAsset: false, userId: uid)` for private. Results are cached in memory (and optionally local).
- **Docs screen**: `lib/screens/docs_screen.dart` — renders markdown via `flutter_markdown`; loads doc in `initState` / on tap, not in `build()`.

### Firestore (assumption)

- Public: `docs/{docId}` with `content`, `updatedAt`, `title`.
- Private: `users/{userId}/private_docs/{docId}`.

---

## 3. Lazy loading component gallery

### ComponentRepository

- **Location**: `lib/data/repositories/component_repository.dart`
- **Paginated API**: `getComponentPage(designSystemId, category, limit, startAfter)` — call when user **opens** a category (e.g. ExpansionTile `onExpansionChanged`), not in `build()` for every category.
- **Firestore**: `design_systems/{designSystemId}/component_items` — each doc: `category`, `name`, `data` (map). Query: `where('category', isEqualTo: category).orderBy('name').limit(N).startAfterDocument(lastDoc)`.

### UI pattern

- **ComponentGalleryScreen** (`lib/screens/component_gallery_screen.dart`): list of `ExpansionTile`s; each tile loads its category **on first expand** via `_loadPage()`. "Load more" uses `startAfter` for the next page. FutureBuilder/StreamBuilder only at the **top level** of the screen or inside the expanded tile, not in a list item builder for every category.

### Firestore index

- Composite: `collection_group` / `category` + `name` if you add `orderBy('name')`. Create index in Firebase Console when the query runs.

---

## 4. General Flutter Web performance

- **Code splitting**: Use `deferred as` and `loadLibrary()` for heavy screens (e.g. export, PDF) to reduce initial JS bundle.
- **Image caching**: Use `cached_network_image` for remote images; set sensible cache width/height to reduce decode cost.
- **Avoid rebuild reads**: Never call Firestore, `getTokens()`, or any async read inside `build()` or inside `ListView.builder` item builder. Load at widget init or in a provider that is created once and listened to.
- **Provider**: Keep Firestore streams in a single provider (e.g. TokensProvider.watchTokens); widgets only read from the provider’s synchronous state.

---

## File structure (suggested)

```
lib/
  data/
    repositories/
      token_repository.dart    # Tokens: cache + Firestore
      component_repository.dart # Components: paginated Firestore
  services/
    docs_service.dart          # Docs: assets + Firestore, cache
    firebase_service.dart
    token_engine.dart
  providers/
    tokens_provider.dart       # Exposes tokens; load/watch at top level
    design_system_provider.dart
    user_provider.dart
  screens/
    docs_screen.dart           # Markdown docs (assets/Firestore)
    component_gallery_screen.dart # Lazy ExpansionTile + pagination
assets/
  docs/
    getting-started.md
    tokens-guide.md
```

---

## Measurable impact

- **Token reads**: One read per workspace open (or when forcing refresh); subsequent UI reads from memory/local cache.
- **Docs**: Public docs = 0 Firestore reads (assets); private = 1 read per doc, then cached.
- **Component gallery**: N reads per category (N = pages), only when user expands that category and taps "Load more".
