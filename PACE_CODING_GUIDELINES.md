# Pace Coding Guidelines and Project Log

## Project Goals
- Simple Flutter UPI scan and pay flow using Riverpod.
- Local transaction storage with Hive.
- Clean, scalable structure with reusable components.

## Status Log
- 2026-02-23
  - Set up Riverpod app shell, scan -> amount -> pay flow, and transaction list.
  - Added UPI payload parsing, UPI service wrapper, and transaction model.
  - Added local persistence with Hive (box: pace, key: local_transactions).
  - Added reusable UI components: PrimaryButton, SectionCard, EmptyState.
  - Added shared formatters utility for date/time display.
  - Added Hive-backed TransactionStore abstraction and in-memory test override.
  - Updated widget test harness for PaceApp.

## Next Focus
- Add permissions + platform configuration for scanner and UPI intents.
- Add transaction detail screen and basic filters.
- Add basic unit tests for parsing and persistence.
