# 📱 App Store Deployment Guide

This guide will help you deploy the KUGAR Flutter app to both Google Play Store and Apple App Store.

## 🚀 Pre-Deployment Checklist

### ✅ Code Quality
- [ ] All linting issues resolved
- [ ] No debug code or print statements
- [ ] Proper error handling implemented
- [ ] Memory leaks checked and fixed
- [ ] Performance optimizations applied

### ✅ Security
- [ ] API keys and secrets removed from code
- [ ] HTTPS enforced for all network requests
- [ ] Proper certificate pinning implemented
- [ ] Input validation and sanitization
- [ ] Secure token storage

### ✅ Testing
- [ ] Unit tests written and passing
- [ ] Integration tests completed
- [ ] UI/UX testing on multiple devices
- [ ] Accessibility testing completed
- [ ] Performance testing done

### ✅ Assets & Resources
- [ ] App icons generated for all sizes
- [ ] Splash screens configured
- [ ] All images optimized
- [ ] Appropriate file sizes maintained
- [ ] Legal assets (privacy policy, terms) included

## 🤖 Android Deployment (Google Play Store)

### 1. Configure Gradle Files

#### `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.kugar.pinggirpapas"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 2. Generate Signed APK/AAB

```bash
# Generate App Bundle (Recommended for Play Store)
flutter build appbundle --release

# Or generate APK (for testing)
flutter build apk --release
```

### 3. Play Store Console Setup

1. **Create Developer Account**
   - Visit [Google Play Console](https://play.google.com/console)
   - Pay registration fee ($25)
   - Complete identity verification

2. **Create New Application**
   - Select app type (Game, App, etc.)
   - Fill in app details
   - Choose package name (com.kugar.pinggirpapas)

3. **Store Listing**
   - App name: "KUGAR - E-Pinggirpapas Sumenep"
   - Short description: Max 80 characters
   - Full description: Max 4000 characters
   - Screenshots (Minimum 2, Maximum 8)
   - App icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)

4. **Content Rating**
   - Complete content rating questionnaire
   - Get appropriate age rating

5. **App Content**
   - Declare app permissions
   - Upload privacy policy
   - Provide target audience information

6. **Pricing & Distribution**
   - Set app price (Free/Paid)
   - Select distribution countries
   - Set content guidelines

7. **Release**
   - Upload AAB file
   - Complete release notes
   - Choose release type (Internal, Alpha, Beta, Production)
   - Submit for review

## 🍎 iOS Deployment (Apple App Store)

### 1. Configure Xcode Project

#### Update `Info.plist`
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access for delivery tracking</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to upload images</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice features</string>
```

### 2. Build iOS App

```bash
# Build for iOS
flutter build ios --release

# Or use Xcode
# Open ios/Runner.xcworkspace in Xcode
# Archive and distribute through Xcode
```

### 3. App Store Connect Setup

1. **Apple Developer Account**
   - Join Apple Developer Program ($99/year)
   - Complete enrollment process

2. **Create New App**
   - Sign in to [App Store Connect](https://appstoreconnect.apple.com)
   - Click "My Apps" → "+"
   - Fill in app information
   - Set bundle ID (com.kugar.pinggirpapas)

3. **App Information**
   - App name: "KUGAR - E-Pinggirpapas Sumenep"
   - Primary language
   - SKU (unique identifier)
   - Bundle ID

4. **Pricing and Availability**
   - Set price tier
   - Availability date
   - Distribution countries

5. **App Metadata**
   - Description (4000 characters max)
   - Keywords (100 characters max)
   - Support URL
   - Marketing URL
   - Privacy policy URL

6. **App Privacy**
   - Complete privacy questionnaire
   - Declare data collection practices
   - Provide privacy policy

7. **Build Upload**
   - Use Xcode Organizer to archive
   - Upload to App Store Connect
   - Wait for processing

8. **Review Submission**
   - Add screenshots (Required for all device sizes)
   - Add app preview (optional)
   - Complete review information
   - Submit for review

## 🔧 Build Configuration

### Environment Variables

Create different configurations for different environments:

#### `lib/core/constants/app_constants.dart`
```dart
class AppConstants {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );
  
  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://dev-kugar.e-pinggirpapas-sumenep.com/api';
      case 'staging':
        return 'https://staging-kugar.e-pinggirpapas-sumenep.com/api';
      case 'production':
      default:
        return 'https://kugar.e-pinggirpapas-sumenep.com/api';
    }
  }
}
```

### Build Commands

```bash
# Development build
flutter build apk --debug --dart-define=ENVIRONMENT=development

# Staging build
flutter build apk --release --dart-define=ENVIRONMENT=staging

# Production build
flutter build apk --release --dart-define=ENVIRONMENT=production
```

## 📊 App Store Optimization (ASO)

### Keywords
- KUGAR
- Pinggirpapas
- Sumenep
- Shopping
- E-commerce
- Local products
- Indonesia

### Description Tips
- Use primary keywords in first 2-3 lines
- Highlight unique features
- Include user benefits
- Add call-to-action

### Visual Assets
- High-quality screenshots showing key features
- Feature graphic for Play Store
- App preview video (optional but recommended)

## 🔍 Testing Before Release

### Internal Testing
- Test on multiple devices
- Test different Android/iOS versions
- Test network conditions
- Test accessibility features

### Beta Testing
- Google Play Internal Testing
- TestFlight for iOS
- Collect user feedback
- Fix reported issues

## 📋 Post-Release Checklist

- [ ] Monitor crash reports
- [ ] Track app performance
- [ ] Respond to user reviews
- [ ] Update app store listing
- [ ] Plan for version updates

## 🚨 Common Issues & Solutions

### Android
- **Issue**: App rejected for insufficient permissions
- **Solution**: Justify each permission in store listing

- **Issue**: 64-bit requirement
- **Solution**: Ensure all libraries support 64-bit architecture

### iOS
- **Issue**: App rejected for missing metadata
- **Solution**: Complete all required fields in App Store Connect

- **Issue**: Guideline violations
- **Solution**: Review Apple Human Interface Guidelines

## 📞 Support Resources

### Google Play Developer Support
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- Developer policies and guidelines

### Apple Developer Support
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- App Review Guidelines

---

**Note**: This deployment guide should be customized based on your specific app requirements and store policies. Always check the latest store guidelines before submission.
