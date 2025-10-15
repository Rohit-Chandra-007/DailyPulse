# Providers

This folder contains all global state management providers for the DailyPulse app using the Provider package.

## Structure

```
lib/providers/
├── auth_provider.dart      # Authentication state management
├── theme_provider.dart     # Theme state management
└── providers.dart          # Barrel file (exports all providers)
```

## Providers

### 1. AuthProvider (`auth_provider.dart`)

Manages authentication state globally using Firebase Auth.

**Features:**
- User authentication (sign in, sign up, sign out)
- Auth state listening (automatic updates)
- Error handling with user-friendly messages
- Loading states

**Usage:**
```dart
// Watch for changes
final authProvider = context.watch<AuthProvider>();
final user = authProvider.user;
final isAuthenticated = authProvider.isAuthenticated;

// Perform actions
await context.read<AuthProvider>().signIn(email: email, password: password);
await context.read<AuthProvider>().signUp(email: email, password: password, name: name);
await context.read<AuthProvider>().signOut();
```

**Properties:**
- `user` - Current Firebase user
- `status` - Auth status (initial, authenticated, unauthenticated, loading)
- `errorMessage` - Error message if authentication fails
- `isAuthenticated` - Boolean for quick auth check

### 2. ThemeProvider (`theme_provider.dart`)

Manages theme state globally with persistent storage.

**Features:**
- Three theme modes (Light, Dark, System)
- Persistent storage using SharedPreferences
- Theme toggling
- Automatic theme restoration on app start

**Usage:**
```dart
// Watch for changes
final themeProvider = context.watch<ThemeProvider>();
final currentMode = themeProvider.themeMode;

// Change theme
await context.read<ThemeProvider>().setLightTheme();
await context.read<ThemeProvider>().setDarkTheme();
await context.read<ThemeProvider>().setSystemTheme();
await context.read<ThemeProvider>().toggleTheme(context);
```

**Properties:**
- `themeMode` - Current theme mode
- `isDarkMode` - Boolean for dark mode check
- `isLightMode` - Boolean for light mode check
- `isSystemMode` - Boolean for system mode check

## Setup

All providers are registered in `main.dart` using `MultiProvider`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MaterialApp(...),
)
```

## Import

Use the barrel file to import all providers:

```dart
import 'package:dailypulse/providers/providers.dart';
```

Or import individual providers:

```dart
import 'package:dailypulse/providers/auth_provider.dart';
import 'package:dailypulse/providers/theme_provider.dart';
```

## Adding New Providers

1. Create a new provider file in this folder (e.g., `user_data_provider.dart`)
2. Extend `ChangeNotifier`
3. Add it to `providers.dart` barrel file
4. Register it in `main.dart` MultiProvider

Example:
```dart
// user_data_provider.dart
class UserDataProvider extends ChangeNotifier {
  // Your state and methods
}

// providers.dart
export 'user_data_provider.dart';

// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => UserDataProvider()),
  ],
  ...
)
```

## Best Practices

1. **Use `context.watch<T>()`** when you need to rebuild on changes
2. **Use `context.read<T>()`** when you only need to call methods
3. **Use `Consumer<T>`** for targeted rebuilds in specific widgets
4. **Keep providers focused** - Each provider should manage one concern
5. **Use async/await** for asynchronous operations
6. **Call `notifyListeners()`** after state changes

## Current Usage

### AuthProvider is used in:
- `lib/features/auth/auth_wrapper.dart` - Route authentication
- `lib/features/auth/sign_in_screen.dart` - Sign in functionality
- `lib/features/auth/sign_up_screen.dart` - Sign up functionality
- `lib/app_scaffold.dart` - Display user name
- `lib/features/settings/settings_screen.dart` - User profile & sign out

### ThemeProvider is used in:
- `lib/main.dart` - Apply theme to MaterialApp
- `lib/features/settings/settings_screen.dart` - Theme selection UI
