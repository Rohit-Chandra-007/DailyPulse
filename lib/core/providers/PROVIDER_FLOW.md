# Provider Flow Diagram

## App Architecture with Providers

```
┌─────────────────────────────────────────────────────────────┐
│                         main.dart                            │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              MultiProvider                          │    │
│  │                                                     │    │
│  │  ┌──────────────────┐  ┌──────────────────┐      │    │
│  │  │  ThemeProvider   │  │   AuthProvider   │      │    │
│  │  │                  │  │                  │      │    │
│  │  │ • themeMode      │  │ • user           │      │    │
│  │  │ • isDarkMode     │  │ • status         │      │    │
│  │  │ • setTheme()     │  │ • signIn()       │      │    │
│  │  │ • toggleTheme()  │  │ • signUp()       │      │    │
│  │  └──────────────────┘  │ • signOut()      │      │    │
│  │                         └──────────────────┘      │    │
│  └────────────────────────────────────────────────────┘    │
│                           │                                 │
│                           ▼                                 │
│                    MaterialApp                              │
│                           │                                 │
│                           ▼                                 │
│                     AuthWrapper                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌──────────────────┐                  ┌──────────────────┐
│  Unauthenticated │                  │  Authenticated   │
│                  │                  │                  │
│  SignInScreen    │                  │  AppScaffold     │
│       │          │                  │       │          │
│       ▼          │                  │       ▼          │
│  SignUpScreen    │                  │  ┌────────────┐  │
└──────────────────┘                  │  │ 4 Tabs:    │  │
                                      │  │            │  │
                                      │  │ 1. Log     │  │
                                      │  │ 2. History │  │
                                      │  │ 3. Insights│  │
                                      │  │ 4. Settings│  │
                                      │  └────────────┘  │
                                      └──────────────────┘
```

## Provider Access Patterns

### 1. AuthProvider Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      AuthProvider                            │
│                                                              │
│  Firebase Auth ──► authStateChanges() ──► _onAuthStateChanged│
│                                                   │          │
│                                                   ▼          │
│                                          notifyListeners()   │
│                                                   │          │
└───────────────────────────────────────────────────┼──────────┘
                                                    │
                    ┌───────────────────────────────┼───────────────────────────┐
                    │                               │                           │
                    ▼                               ▼                           ▼
        ┌──────────────────────┐      ┌──────────────────────┐    ┌──────────────────────┐
        │   AuthWrapper        │      │   AppScaffold        │    │  SettingsScreen      │
        │                      │      │                      │    │                      │
        │ • Listens to status  │      │ • Shows user name    │    │ • Shows profile      │
        │ • Routes to screens  │      │                      │    │ • Sign out button    │
        └──────────────────────┘      └──────────────────────┘    └──────────────────────┘
```

### 2. ThemeProvider Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     ThemeProvider                            │
│                                                              │
│  SharedPreferences ──► Load Theme ──► _themeMode            │
│                                            │                 │
│                                            ▼                 │
│                                   notifyListeners()          │
│                                            │                 │
└────────────────────────────────────────────┼─────────────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
                    ▼                        ▼                        ▼
        ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
        │   MaterialApp    │    │  SettingsScreen  │    │  All Screens     │
        │                  │    │                  │    │                  │
        │ • Applies theme  │    │ • Theme selector │    │ • Use isDark     │
        │ • themeMode      │    │ • Change theme   │    │ • Adapt colors   │
        └──────────────────┘    └──────────────────┘    └──────────────────┘
```

## Data Flow Examples

### Example 1: User Signs In

```
1. User enters credentials in SignInScreen
                │
                ▼
2. SignInScreen calls: context.read<AuthProvider>().signIn()
                │
                ▼
3. AuthProvider.signIn() calls Firebase Auth
                │
                ▼
4. Firebase Auth updates auth state
                │
                ▼
5. AuthProvider._onAuthStateChanged() triggered
                │
                ▼
6. AuthProvider.notifyListeners() called
                │
                ▼
7. AuthWrapper rebuilds (Consumer listening)
                │
                ▼
8. AuthWrapper shows AppScaffold (authenticated)
                │
                ▼
9. User sees main app
```

### Example 2: User Changes Theme

```
1. User taps theme option in SettingsScreen
                │
                ▼
2. SettingsScreen calls: context.read<ThemeProvider>().setDarkTheme()
                │
                ▼
3. ThemeProvider updates _themeMode
                │
                ▼
4. ThemeProvider saves to SharedPreferences
                │
                ▼
5. ThemeProvider.notifyListeners() called
                │
                ▼
6. MaterialApp rebuilds (Consumer listening)
                │
                ▼
7. MaterialApp applies new theme
                │
                ▼
8. All screens rebuild with new theme
                │
                ▼
9. User sees theme change immediately
```

## Provider Communication

```
┌─────────────────────────────────────────────────────────────┐
│                    Widget Tree                               │
│                                                              │
│  MaterialApp (Consumer<ThemeProvider>)                      │
│       │                                                      │
│       └─► AuthWrapper (Consumer<AuthProvider>)             │
│              │                                               │
│              ├─► SignInScreen                               │
│              │      └─► Uses: context.read<AuthProvider>()  │
│              │                                               │
│              └─► AppScaffold                                │
│                     │                                        │
│                     ├─► Uses: context.watch<AuthProvider>() │
│                     │                                        │
│                     └─► SettingsScreen                      │
│                            ├─► context.watch<AuthProvider>()│
│                            └─► context.watch<ThemeProvider>()│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Best Practices Applied

### ✅ Use `context.watch<T>()` when:
- Widget needs to rebuild on state changes
- Displaying data from provider
- Example: Showing user name, theme status

### ✅ Use `context.read<T>()` when:
- Only calling methods (no rebuild needed)
- Event handlers (button taps)
- Example: Sign out button, theme change button

### ✅ Use `Consumer<T>` when:
- Need targeted rebuilds
- Only part of widget should rebuild
- Example: MaterialApp theme, AuthWrapper routing

## Provider Lifecycle

```
App Start
    │
    ▼
1. main() initializes Firebase & Hive
    │
    ▼
2. MultiProvider creates provider instances
    │
    ├─► ThemeProvider()
    │      └─► Loads theme from SharedPreferences
    │
    └─► AuthProvider()
           └─► Listens to Firebase authStateChanges
    │
    ▼
3. MaterialApp builds with providers available
    │
    ▼
4. All child widgets can access providers
    │
    ▼
5. Providers notify listeners on state changes
    │
    ▼
6. Widgets rebuild automatically
    │
    ▼
App Running (providers active)
    │
    ▼
App Closed
    └─► ThemeProvider saves state to SharedPreferences
```

## Summary

- **Global Access**: All providers available throughout widget tree
- **Automatic Updates**: Widgets rebuild when provider state changes
- **Persistent State**: Theme saved to SharedPreferences
- **Firebase Integration**: Auth state synced with Firebase
- **Clean Architecture**: Separation of state and UI
- **Scalable**: Easy to add new providers following same pattern
