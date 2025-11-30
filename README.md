# KUGAR - E-Pinggirpapas Sumenep Mobile App

A modern, production-ready Flutter mobile application for the E-Pinggirpapas Sumenep platform, featuring Material Design 3, comprehensive e-commerce functionality, and advanced features.

## 🚀 Features

### Core Features
- **Authentication**: Secure login/logout with token management
- **Product Catalog**: Browse products with search, filters, and categories
- **Shopping Cart**: Add/remove items, quantity management
- **Checkout**: Complete purchase flow with payment integration
- **Order Tracking**: Real-time order status updates

### Advanced Features
- **QR Scanner**: Scan product QR codes for quick access
- **Virtual Tour**: 360° facility tours using WebView
- **Chat Support**: AI-powered customer support with live chat
- **Reviews & Ratings**: Customer feedback system
- **Push Notifications**: Order updates and promotions

### Technical Features
- **Material Design 3**: Modern UI with dynamic color theming
- **State Management**: Riverpod for reactive state management
- **Navigation**: Go Router for declarative routing
- **Networking**: Dio HTTP client with interceptors
- **Local Storage**: SharedPreferences and SQLite
- **Image Caching**: Cached network images with placeholders
- **Animations**: Smooth transitions and micro-interactions

## 🛠 Architecture

The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                 # Core utilities and constants
│   ├── constants/        # App constants
│   ├── router/          # Navigation configuration
│   └── utils/           # Utility functions
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── services/        # API services
├── domain/              # Business logic
│   ├── entities/        # Domain entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
├── presentation/        # UI layer
│   ├── pages/           # Screen widgets
│   ├── widgets/         # Reusable components
│   └── providers/       # Riverpod providers
└── shared/              # Shared utilities
    ├── extensions/      # Dart extensions
    ├── themes/          # App theming
    └── widgets/         # Common widgets
```

## 📱 Screens

- **Splash Screen**: Animated app introduction
- **Authentication**: Login and registration
- **Home**: Feature dashboard with quick actions
- **Product Catalog**: Grid/list view with filters
- **Product Detail**: Detailed product information
- **Shopping Cart**: Cart management
- **Checkout**: Order completion
- **Order Tracking**: Real-time tracking
- **QR Scanner**: Camera-based QR code scanning
- **Virtual Tour**: WebView-based 360° tours
- **Chat Support**: Customer service interface
- **Reviews**: Product review system

## 🎨 Design System

- **Material Design 3**: Latest Material Design specifications
- **Dynamic Color**: Automatic color theming based on system colors
- **Typography**: Consistent font hierarchy
- **Components**: Reusable UI components
- **Dark Mode**: Automatic dark/light theme switching

## 🔧 Dependencies

### Core Dependencies
- `flutter_riverpod`: State management
- `go_router`: Declarative routing
- `dio`: HTTP client
- `shared_preferences`: Local storage
- `cached_network_image`: Image caching

### UI Dependencies
- `material_color_utilities`: Color utilities
- `dynamic_color`: Dynamic theming
- `shimmer`: Loading animations
- `lottie`: Advanced animations

### Feature Dependencies
- `mobile_scanner`: QR code scanning
- `webview_flutter`: WebView integration
- `geolocator`: Location services
- `image_picker`: Camera/gallery access
- `flutter_local_notifications`: Push notifications

### Development Dependencies
- `flutter_lints`: Code quality
- `mockito`: Testing
- `json_serializable`: Code generation
- `flutter_launcher_icons`: App icons
- `flutter_native_splash`: Splash screen

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.9.2)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/siapaajaboleh888/E-pinggirpapas-Sumenep.git
   cd kugar_flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Generate app icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

5. **Generate splash screen**
   ```bash
   flutter pub run flutter_native_splash:create
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration
Update the API base URL in `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String apiBaseUrl = 'https://kugar.e-pinggirpapas-sumenep.com/api';
  // ... other constants
}
```

### Environment Variables
Create different configurations for development, staging, and production environments.

### App Icons
Place your app icon at `assets/icons/app_icon.png` (1024x1024 PNG).

### Splash Logo
Place your splash logo at `assets/icons/splash_logo.png`.

## 📱 Build & Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 📊 Performance

- **60 FPS**: Smooth animations and transitions
- **Lazy Loading**: Efficient memory usage
- **Image Caching**: Optimized image loading
- **State Management**: Efficient re-renders

## 🔒 Security

- **Token Management**: Secure JWT token storage
- **API Security**: HTTPS with proper headers
- **Input Validation**: Form validation and sanitization
- **Error Handling**: Graceful error management

## 🌐 Internationalization

The app is structured to support multiple languages. Add localizations in `lib/l10n/`.

## 📈 Analytics & Monitoring

Integration ready for:
- Firebase Analytics
- Crashlytics
- Performance monitoring

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and inquiries:
- **Email**: support@kugar.com
- **Phone**: +62 123-456-789
- **Address**: Pinggirpapas, Sumenep, Indonesia

## 🌟 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- The open-source community for invaluable packages

---

**Built with ❤️ for the E-Pinggirpapas Sumenep community**
