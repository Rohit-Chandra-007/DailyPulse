# Provider Migration Guide

This guide documents the migration of providers to a centralized location.

## What Changed?

### Before (Old Structure)
```
lib/
├── features/auth/
│   └── auth_provider.dart        ❌ Provider mixed with feature
└── core/
    └── theme_provider.dart       ❌ Provider in core utilities
```

### After (New Structure)
```
lib/
└── providers/                    ✅ All providers centralized
    ├── auth_provider.dart
    ├── theme_provider.dart
    ├── providers.dart            ✅ Barrel file
    └── README.md
```

## Migration Steps Completed

### 1. ✅ Created Providers Folder
- Created `lib/providers/` directory
- Moved `auth_provider.dart` from `lib/features/auth/`
- Moved `theme_provider.dart` from `lib/core/`

### 2. ✅ Created Barrel File
- Created `lib/providers/providers.dart`
- Exports all providers for easy importing

### 3. ✅ Updated All Imports

**Files Updated:**
- `lib/main.dart`
- `lib/app_scaffold.dart`
- `lib/features/auth/auth_wrapper.dart`
- `lib/features/auth/sign_in_screen.dart`
- `lib/features/auth/sign_up_screen.dart`
- `lib/features/settings/settings_screen.dart`

**Import Changes:**
```dart
// Old imports
import 'features/auth/auth_provider.dart';
import 'core/theme_provider.dart';

// New imports
import 'providers/providers.dart';  // All providers
// OR
import 'providers/auth_provider.dart';  // Specific provider
```

### 4. ✅ Deleted Old Files
- Removed `lib/features/auth/auth_provider.dart`
- Removed `lib/core/theme_provider.dart`

### 5. ✅ Verified Everything Works
- All imports updated correctly
- No compilation errors
- `flutter analyze` passes with no issues

## Benefits Achieved

### 🎯 Better Organization
- All state management in one place
- Clear separation between UI and state
- Easier to find and maintain providers

### 📦 Cleaner Imports
```dart
// Before: Multiple imports
import 'features/auth/auth_provider.dart';
import 'core/theme_provider.dart';

// After: Single import
import 'providers/providers.dart';
```

### 🚀 Scalability
- Easy to add new providers
- Consistent pattern for all state management
- No confusion about where providers should go

### 🧪 Testability
- Providers isolated from features
- Easy to mock for testing
- Clear dependencies

## How to Add New Providers

Follow this pattern for any new provider:

### Step 1: Create Provider File
```dart
// lib/providers/my_new_provider.dart
import 'package:flutter/foundation.dart';

class MyNewProvider extends ChangeNotifier {
  // Your state
  String _data = '';
  
  String get data => _data;
  
  // Your methods
  void updateData(String newData) {
    _data = newData;
    notifyListeners();
  }
}
```

### Step 2: Export in Barrel File
```dart
// lib/providers/providers.dart
export 'auth_provider.dart';
export 'theme_provider.dart';
export 'my_new_provider.dart';  // Add this line
```

### Step 3: Register in main.dart
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => MyNewProvider()),  // Add this
  ],
  child: MaterialApp(...),
)
```

### Step 4: Use in Your Features
```dart
import 'package:dailypulse/providers/providers.dart';

// In your widget
final myProvider = context.watch<MyNewProvider>();
```

## Rollback (If Needed)

If you need to rollback this change:

1. Copy providers back to original locations
2. Update imports in all files
3. Delete `lib/providers/` folder

However, the new structure is recommended for better maintainability.

## Questions?

Refer to:
- `lib/providers/README.md` - Provider documentation
- `PROJECT_STRUCTURE.md` - Overall project structure
- Flutter Provider documentation: https://pub.dev/packages/provider
