# Swift Rewrite Plan — 出了吗？

## Branches
- `flutter-backup` — Flutter version, frozen, do not modify
- `main` — Swift rewrite target

---

## App Structure (from Flutter reference)

### Navigation flow
```
SplashScreen (intro animation + choice)
    ├── partner path → TraceChecklist → TraceReport → (save/lock)
    ├── self path    → SelfRiskCheck → SelfReflection → MindSanctuary
    └── records path → ArchiveAccess (passphrase) → TraceArchive
```

### Screens (11 total)
| # | Screen | Flutter file | Notes |
|---|--------|-------------|-------|
| 1 | Splash + Choice | `splash_screen.dart` (555 lines) | Blob animation, 4 dots → line → labels |
| 2 | Trace Checklist | `trace_checklist_screen.dart` | Swipe cards, anomaly tool panel |
| 3 | Trace Report | `trace_report_screen.dart` | Cinematic header, evidence grid, timeline, key input |
| 4 | Self Risk Check | `self_risk_check_screen.dart` | Different question set |
| 5 | Self Reflection | `self_reflection_screen.dart` | Results + AI chat entry |
| 6 | Mind Sanctuary | `mind_sanctuary_screen.dart` (796 lines) | DeepSeek AI chat |
| 7 | Archive Access | `archive_access_screen.dart` | Passphrase input → decrypt |
| 8 | Trace Archive | `trace_archive_screen.dart` | Searchable list, expandable cards, evidence preview |

---

## Services to rewrite in Swift

| Service | Flutter | Swift equivalent |
|---------|---------|-----------------|
| Encryption | `encryption_service.dart` — AES-256-GCM, SHA-256 record ID | `CryptoKit` — `AES.GCM`, `SHA256` |
| Supabase storage | `investigation_storage_service.dart` | `supabase-swift` SDK |
| Evidence upload/download | `evidence_service.dart` | `supabase-swift` Storage + `CryptoKit` |
| DeepSeek chat | `deepseek_service.dart` — streaming HTTP | `URLSession` with `AsyncStream` |
| Image/audio picker | `image_picker`, `record` packages | `PhotosUI`, `AVFoundation` |
| Audio playback | `just_audio` | `AVAudioPlayer` / `AVAudioEngine` |

---

## State management

Flutter used Riverpod `StateNotifier`. Swift equivalent: `@Observable` class (iOS 17+) or `ObservableObject` + `@Published`.

```swift
// Equivalent of InvestigationState
@Observable class InvestigationStore {
    var passphrase: String?
    var record: InvestigationRecord?
    var pendingFiles: [PendingFile] = []
    var isBusy = false
    var error: String?
}
```

---

## Key data models

```swift
struct InvestigationRecord: Codable {
    let entryType: String        // "partner" | "self"
    let completedAt: Date
    var results: [String: String]          // itemId → "flagged"|"normal"
    var evidences: [String: [String]]      // itemId → [storageFileKey]
}

struct PendingFile {
    let itemId: String
    let url: URL   // local file URL
}
```

---

## Encryption spec (must match existing Supabase data)

The Swift encryption **must produce identical output** to the Flutter version or existing saved records become unreadable.

Flutter implementation to match:
```dart
// Record ID: SHA-256(passphrase UTF-8) → hex string
static String deriveRecordId(String passphrase) {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return digest.toString(); // lowercase hex
}

// Payload: "iv_base64:ciphertext_base64"
// Key: SHA-256(passphrase) → 32 bytes (used directly as AES-256 key)
// IV: 12 random bytes
// Mode: AES-256-GCM (tag appended to ciphertext by PointyCastle)
```

Swift equivalent:
```swift
func deriveRecordId(_ passphrase: String) -> String {
    let data = Data(passphrase.utf8)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}

func encrypt(_ passphrase: String, _ plaintext: String) throws -> String {
    let keyData = Data(SHA256.hash(data: Data(passphrase.utf8)))
    let key = SymmetricKey(data: keyData)
    let iv = AES.GCM.Nonce()   // 12 random bytes
    let sealed = try AES.GCM.seal(Data(plaintext.utf8), using: key, nonce: iv)
    let ivB64 = Data(iv).base64EncodedString()
    let ctB64 = sealed.ciphertext.base64EncodedString()  // NOTE: tag is separate in CryptoKit
    // Flutter appends tag to ciphertext — must combine:
    let combined = sealed.ciphertext + sealed.tag
    return "\(ivB64):\(combined.base64EncodedString())"
}
```

> **Critical**: Flutter's PointyCastle appends the 16-byte GCM tag directly to ciphertext. CryptoKit separates them. The Swift implementation must combine `ciphertext + tag` on encrypt, and split them on decrypt.

---

## Splash animation spec

The opening animation is the most complex piece. Key timeline (total 6000ms):

| Time | Event |
|------|-------|
| 0–400ms | 4 dots stagger fade in |
| 900–2280ms | Dots turn white→black (spin illusion) |
| 2280–3600ms | 4 dots converge to 1 golden center dot |
| 3000–3720ms | Blobs + dots fade out |
| 3360–4560ms | Golden dot stretches into vertical divider line |
| 4200–5880ms | Labels + bottom buttons slide in |

SwiftUI implementation: use `withAnimation` + `TimelineView` or a sequence of `.delay`-chained animations with `@State` flags.

Background: 3 animated blobs using `RadialGradient` + `scaleEffect` + `offset`, looping at 4500ms.

---

## Rewrite order (recommended)

1. **Project setup** — New SwiftUI app target in same Xcode project, `config.swift` (git-ignored) with credentials
2. **Models + Services** — `InvestigationRecord`, `EncryptionService`, `SupabaseService`, `EvidenceService`
3. **Splash screen** — Highest visual complexity, do first while energy is high
4. **Checklist flow** — `TraceChecklistView`, bottom action bar, card animation
5. **Report screen** — Evidence grid, timeline, key input + save
6. **Archive flow** — Access screen, archive list, evidence thumbnails + preview overlay
7. **Self path** — `SelfRiskCheckView`, `SelfReflectionView`
8. **Mind Sanctuary** — DeepSeek streaming chat
9. **Polish** — Haptics, transitions between screens, edge cases

---

## Dependencies (Swift)

```swift
// Package.swift or SPM in Xcode
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
]
// Everything else is Apple frameworks: CryptoKit, AVFoundation, PhotosUI, SwiftUI
```

No `flutter_animate`, no `riverpod`, no `just_audio`, no `image_picker` — all replaced by native APIs.

---

## Files to preserve from Flutter project

- `lib/data/questions.dart` — question content (translate to Swift structs)
- `lib/config.dart` — credentials pattern (recreate as `Sources/Config.swift`, git-ignored)
- `.github/workflows/build-ios.yml` — CI/CD (update for Swift build)
- Supabase table schema + RLS policies — unchanged

---

## Risk: encryption compatibility

The single biggest risk is that the Swift `EncryptionService` produces different output than Flutter, making existing saved records unreadable. Before any other work, write a test that:
1. Encrypts a known string with a known passphrase in Swift
2. Decrypts the Flutter-encrypted version of the same string
3. Verifies both match

Run this test before touching any UI code.
