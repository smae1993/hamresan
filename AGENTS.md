# AI contribution instructions

## Scope

The Flutter application is under `app/`. Read `docs/ARCHITECTURE.md`, `docs/PROTOCOL.md`, and `docs/SECURITY.md` before editing discovery, transport, file persistence, or trust logic.

## Required checks

Run from `app/`:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Run an appropriate platform build when platform configuration changes.

## Invariants

- Never use a peer display name as its identifier.
- Store sizes as exact integer bytes; format only in UI code.
- Never report success before the receiver's integrity ACK.
- Never trust network-provided paths, names, counts, lengths, or IDs.
- Never silently convert network, disk, checksum, or permission errors into success.
- Protocol wire changes require a version bump, documentation, and compatibility tests.
- Do not claim encryption until authenticated encryption is implemented and tested.
- Web is not a supported target for the raw UDP/TCP transport.

Keep commits focused and update the relevant document when behavior changes.
