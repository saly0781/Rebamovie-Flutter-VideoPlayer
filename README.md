# Rebamovie-Flutter-VideoPlayer

## Overview
Rebamovie-Flutter-VideoPlayer is a feature-rich video player application built with Flutter. It provides advanced video playback functionality with ad integration, quality selection, episode management, and a polished user interface.

## Features
- Video playback with Chewie player
- Ad integration with countdown timer
- Quality selection (Auto, SD, HD, Full HD)
- Episode and season navigation
- Continue watching functionality
- Download management
- Picture-in-picture mode
- Subtitle support
- Haptic feedback
- Audio wave visualization
- Dark/light theme support

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code
- Dart SDK (bundled with Flutter)

### Installation Steps

1. Clone the repository:
```bash
git clone <repository-url>
cd Rebamovie-Flutter-VideoPlayer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure your backend API endpoints in the constants file

4. Run the application:
```bash
flutter run
```

### Development
To run in development mode:
```bash
flutter run lib/main.dart
```

### Build
To create a release build:
```bash
flutter build apk --release
```

## API Endpoints and Data Structures

### API Endpoints
- GET `/api/cinema/{movieId}` - Fetches cinema data including movies, series, episodes
- POST `/api/download` - Initiates video download
- DELETE `/api/download/{downloadId}` - Cancels/removes a download
- GET `/api/downloads` - Retrieves list of downloads

### Data Structures

#### Cinema Data
```dart
class CinemaData {
  String id;
  String title;
  String description;
  String coverImage;
  bool isSeason;
  List<ApiEpisodeData> episodes;
}
```

#### Episode Data
```dart
class ApiEpisodeData {
  String episodeId;
  int episode;
  String title;
  String description;
  String videoUrl;
  String longCover;
  bool locked;
  Map<String, String> qualityUrls; // Maps quality to URL
  List<Subtitle> subtitles;
}
```

#### Continue Watching
```dart
class ContinueWatching {
  String movieId;
  String episodeId;
  Duration continueWatching;
  DateTime timestamp;
}
```

#### Download Item
```dart
class DownloadItem {
  String id;
  String fileName;
  String url;
  double progress;
  DownloadStatus status;
  DateTime createdAt;
}
```

## Architecture

The application follows a modular architecture with separate concerns for UI, business logic, and data management. The main components include:

- **Video Player**: Built with video_player and chewie packages
- **State Management**: Uses provider for managing app state
- **API Integration**: Custom API calls with error handling
- **Download Manager**: Handles video downloads with progress tracking
- **UI Components**: Reusable widgets with animations and effects

## Key Classes Documentation

### VideoPlayer
The main StatefulWidget that manages the entire video player experience, including:
- Video playback controls
- Ad integration
- Quality selection
- Episode navigation
- Download management

### AudioWaveData
Manages the play/pause state of the audio wave animation using ChangeNotifier pattern.

### AnimatedControlButton
Provides animated buttons with bounce effect and haptic feedback for both tap and long press interactions.

### _initializePlayer()
Method that initializes the video player with the current episode, handling loading states, continue watching data, and error states.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[Specify license here]