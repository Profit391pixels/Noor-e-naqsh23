
# Noor-e-Naqsh - Flutter App (converted from HTML)

Factory Management App with Firebase Firestore.

## Features migrated from index.html
- Dhaga Entries (with SAFE_CALC 2+2 support, raw values preserved)
- Labour Salary (remarks fix, payout breakdown, PNG receipt share)
- Party Bills (invoice with screenshot share, mobile-safe download)
- Thaan Khata
- Hall Rent, Electricity, Firqi, Paper Roll (generic expense screen)
- Dashboard with Urdu labels

## Setup
1. flutter pub get
2. Firebase is already configured with your existing project:
   - Project: noor-e-naqsh-6b697
   - Collections: dhagaEntries, paperRollEntries, thaanEntries, labourEntries, hallEntries, electricityEntries, firqiEntries, partyBills
   - If you use new Firebase project, run `flutterfire configure`

3. For Android: ensure `android/app/google-services.json` exists (download from Firebase console)
4. flutter run

## What was fixed vs HTML
- Labour remarks reset bug fixed (now uses remarks field)
- Dhaga paid zero bug fixed (uses SafeCalc.calc instead of +value)
- Party Bill mobile invoice download: now uses screenshot + share_plus, with scale 1 for mobile to avoid blank canvas
- Card now shows remarks with 📝

## Structure
lib/
 - main.dart
 - utils/safe_calc.dart  # SAFE_CALC equivalent
 - models/entry.dart
 - services/firestore_service.dart
 - screens/
   - dashboard_screen.dart
   - dhaga_screen.dart
   - labour_screen.dart (with receipt share)
   - party_bill_screen.dart (with invoice share)
   - thaan_screen.dart
   - generic_expense_screen.dart

## Next steps you may want
- Add login with Firebase Auth
- Add offline caching with hive
- Add PDF invoice instead of PNG
- Add Urdu font (Jameel Noori) in assets

Run `flutter build apk` for Android APK.
