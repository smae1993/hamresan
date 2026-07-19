# Flutter application instructions

Use the existing feature-first structure and Riverpod/GoRouter stack. Domain entities must not import platform plugins. Platform and socket code belong in data services behind repository contracts.

## Transfer changes

- `ContentItem.key` is a local source path only for locally selected files.
- `ContentItem.byteSize` is the exact size; `size` is presentation-only.
- `TransferSession.id` and `peerId` must survive the complete flow.
- Progress is weighted by bytes through `TransferProgress`.
- Write received files to a temporary path, verify integrity, then rename.
- Sanitize remote names and generate collision-safe destinations.
- Bound all network allocations before reading them.

## UI changes

- Preserve RTL layout and Vazirmatn typography.
- Show waiting, connecting, transferring, verifying, success, failure, rejection, and cancellation honestly.
- Remove demo data from production flows.

## Verification

Format, analyze, test, and build at least one affected target. Add tests for protocol, state-machine, path-safety, or persistence changes.
