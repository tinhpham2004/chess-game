# Chess Game

A Flutter-based chess game application that allows users to create, save, load, and manage chess games. The app uses a clean architecture approach with BLoC pattern for state management.

## Features

- Create new chess games with unique IDs
- Save and load chess game states
- View a list of saved games
- Delete saved games
- Simple and intuitive UI

## Architecture

The project follows clean architecture principles, organized into several layers:

- **Presentation Layer**: UI components, screens, and BLoC state management
- **Logic Layer**: Business logic and game rules
- **Data Layer**: Repositories and data sources
- **Core Layer**: Common utilities and patterns

### Key Components

- **BLoC Pattern**: For state management using `flutter_bloc`
- **SQLite Database**: For local storage using `sqflite`
- **Dependency Injection**: Using `get_it`
- **Navigation**: Using `go_router`

## Getting Started

### Prerequisites

- Flutter SDK (^3.6.0)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/tinhpham2004/chess_game.git
   ```

2. Navigate to the project directory:

   ```
   cd chess_game
   ```

3. Install dependencies:

   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## How to Use

1. **Home Screen**: Enter a game ID and tap "Create Game" to start a new game, or select from previously saved games
2. **Game Room**: Play chess, with the game state automatically saved
3. **Game Management**: View, load, or delete saved games from the home screen

## Project Structure

```
lib/
  ├── app/               # App configuration and facades
  ├── core/              # Core utilities and common functionality
  ├── data/              # Data layer with models, repositories, and data sources
  │   ├── datasource/    # Database and API implementations
  │   ├── models/        # Data models
  │   └── repository/    # Repository implementations
  ├── di/                # Dependency injection
  ├── logic/             # Business logic
  │   ├── ai/            # AI opponent logic
  │   └── game_room/     # Game room logic
  ├── presentation/      # UI layer
  │   ├── ai/            # AI game screens
  │   ├── game_room/     # Game room screens
  │   └── home/          # Home screens
  └── router/            # App navigation
```

## Dependencies

- `flutter_bloc`: ^9.1.1 - State management
- `go_router`: ^15.1.2 - Navigation
- `get_it`: ^8.0.3 - Dependency injection
- `sqflite`: ^2.4.1 - SQLite database
- `flutter_screenutil`: ^5.9.3 - Responsive UI
- `equatable`: ^2.0.7 - Value equality

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Chess piece designs by [Source]
- Icons by [Source]
- Special thanks to the Flutter and Dart teams for the amazing framework
