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

- Flutter SDK (^3.6.0 or later). Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) to set up Flutter.
- Dart SDK (comes with Flutter)
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

## Flutter Installation Guide

If you don't have Flutter installed, please follow these steps:

1.  Go to the [Flutter official website](https://flutter.dev/docs/get-started/install).
2.  Select your operating system (Windows, macOS, Linux, ChromeOS).
3.  Follow the detailed instructions provided for your OS to download and install the Flutter SDK.
4.  Set up your PATH environment variable.
5.  Run `flutter doctor` in your terminal to verify the installation and check for any missing dependencies.
6.  Set up your preferred editor (Android Studio, VS Code, etc.) with the Flutter and Dart plugins.

## How to Use

1. **Home Screen**: Enter a game ID and tap "Create Game" to start a new game, or select from previously saved games
2. **Game Room**: Play chess, with the game state automatically saved
3. **Game Management**: View, load, or delete saved games from the home screen

## Project Structure

```
lib/
  ├── main.dart          # Main application entry point
  ├── app/               # App configuration, BLoC observer
  │   ├── app_bloc_observer.dart
  │   └── app.dart
  ├── core/              # Core utilities, common models, and design patterns
  │   ├── common/
  │   ├── models/
  │   └── patterns/
  ├── data/              # Data layer: datasources, entities, repositories
  │   ├── datasource/    # Database/API implementations
  │   ├── entities/      # Data entities (if different from models)
  │   └── repository/    # Repository implementations
  ├── di/                # Dependency injection setup
  │   ├── app_module.dart
  │   ├── injection.config.dart
  │   └── injection.dart
  ├── presentation/      # UI layer: screens, widgets, and presentation logic
  │   ├── assets/        # UI assets (if any specific to presentation)
  │   ├── difficulty/    # Difficulty selection screens/widgets
  │   ├── game_room/     # Game room screens/widgets
  │   ├── main/          # Main screen/navigation hub
  │   ├── match_history/ # Match history screens/widgets
  │   ├── setup/         # Game setup screens/widgets
  │   └── welcome/       # Welcome/initial screens
  ├── router/            # App navigation and routing
  └── theme/             # App theming and styles
```

## Dependencies

The main dependencies used in this project are (refer to `pubspec.yaml` for exact versions):

- `flutter_bloc`: ^9.1.1 - State management
- `go_router`: ^15.1.2 - Navigation
- `get_it`: ^8.0.3 - Dependency injection
- `sqflite`: ^2.4.1 - SQLite database
- `flutter_screenutil`: ^5.9.3 - Responsive UI
- `equatable`: ^2.0.7 - Value equality

## Coding Conventions

This project aims to follow standard Flutter and Dart coding conventions:

- **Effective Dart**: Adhere to the guidelines in [Effective Dart](https://dart.dev/guides/language/effective-dart).
  - Use `PascalCase` for type names (classes, enums, typedefs, type parameters).
  - Use `camelCase` for member names (methods, properties, variables) and top-level functions/variables.
  - Use `lowercase_with_underscores` for library, package, directory, and source file names.
- **Flutter Specific**:
  - Prefer `const` constructors for widgets where possible for performance.
  - Keep widget build methods pure and free of side effects.
  - Organize files by feature or layer.
  - Use relative imports for files within the same package.
- **Linting**: The project should be configured with a linter (e.g., `flutter_lints` or `lints`) to enforce these conventions.
- **Comments**: Write clear and concise comments where necessary, especially for public APIs and complex logic.
  - Use `///` for documentation comments.
  - Use `//` for implementation comments.

### Commit Messages

Follow this pattern for commit messages:
`<type>/<your_name_or_branch_name>/<description>`

- **`<type>`**: `feat` (for new features), `fix` (for bug fixes), `docs` (for documentation changes), `style` (for code style changes), `refactor` (for code refactoring), `test` (for adding or improving tests), `chore` (for build process or auxiliary tools and libraries such as documentation generation).
- **`<your_name_or_branch_name>`**: Your name or the branch name you are working on (e.g., `tinhpham`, `feature-xyz`).
- **`<description>`**: A concise description of the changes.

Example: `feat/tinhpham/handle-logic-chess-board`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Adding New Assets

1.  Place your new asset files (e.g., images, icons) into the `assets/` directory (this directory is at the same level as the `lib/` directory).
    - For example, add new icons to `assets/icons/` or new images to `assets/images/`.
2.  After adding new assets, regenerate the asset helper class by running the following command in your terminal:
    ```powershell
    dart run build_runner build --delete-conflicting-outputs
    ```
3.  Use the generated asset paths from the class located in `lib/presentation/assets/assets.gen.dart` in your code.

### Pull Request Process

- All development should be done in feature branches.
- When your feature or fix is complete, create a Pull Request (PR) targeting the `dev` branch.
- Ensure your code follows the coding conventions and that all tests pass before submitting a PR.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Chess piece designs by [Source - e.g., Lichess, Wikimedia Commons, etc. Please update this]
- Icons by [Source - e.g., Flaticon, Material Icons, etc. Please update this]
- Special thanks to the Flutter and Dart teams for the amazing framework
