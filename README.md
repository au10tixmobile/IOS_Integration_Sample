# IOSIntegrationSample - Au10tix SDK Comprehensive Integration

A comprehensive, all-in-one SwiftUI sample application demonstrating all Au10tix SDK features and capabilities.

## Overview

This integration sample showcases the complete Au10tix identity verification SDK in a modern SwiftUI application. All features are consolidated into single files for easy customization and backend integration.

## Features

✅ **Smart Document Capture (SDC)** - Intelligent ID document capture with auto-detection  
✅ **Passive Face Liveness (PFL)** - Live selfie verification without user interaction  
✅ **Proof of Address (POA)** - Utility bill and bank statement verification  
✅ **NFC Passport Reading** - Extract data from passport NFC chips  
✅ **Voice Consent** - Voice-based consent recording  
✅ **Video Session** - Combined video and voice verification  
✅ **ID Liveness** - Multi-angle document liveness detection  
✅ **SecureMe Flow** - Complete identity verification with multiple steps (no configuration needed)  

## Requirements

- **iOS Version**: iOS 13.0+
- **Development**: SwiftUI, Xcode 13+
- **Permissions**: Camera, Microphone, NFC, Photo Library, Location
- **Capabilities**: NFC Tag Reading (for passport feature)

## Project Structure

```
IOSIntegrationSample/
├── IOSIntegrationSampleApp.swift    # App entry point
├── ContentView.swift                # Main UI with all features
├── Au10tixSDKManager.swift         # SDK initialization & workflow
├── Au10tixFeatureViews.swift       # Individual feature implementations
├── Au10tixUIComponents.swift       # Reusable UI components
├── Info.plist                      # Permissions configuration
└── IOSIntegrationSample.entitlements # NFC capabilities
```

### Key Files

#### 1. **ContentView.swift** (Main UI)
- All-in-one interface for accessing all Au10tix features
- Feature selection with SwiftUI cards
- SDK initialization and status display
- Easy to customize for specific customer needs

#### 2. **Au10tixSDKManager.swift** (SDK Management)
- Centralized SDK initialization
- Workflow management
- Local module updates for offline classification
- Observable state management

#### 3. **Au10tixFeatureViews.swift** (Feature Implementations)
- All 7 Au10tix features in one file
- UIKit-SwiftUI bridges for each SDK component
- Complete delegate implementations
- Ready for backend customization

#### 4. **Au10tixUIComponents.swift** (UI Components)
- Reusable SwiftUI components
- Feature buttons, cards, and banners
- Loading indicators and result displays
- Consistent UI styling

## Setup Instructions

### 1. Install Au10tix SDK via CocoaPods

Add to your `Podfile`:

```ruby
source 'https://github.com/au10tixmobile/iOS_Artifacts_cocoapods_spec.git'

target 'IOSIntegrationSample' do
  use_frameworks!
  
  pod 'Au10tixSecureMeKit'
  pod 'Au10tixPassiveFaceLivenessUI'
  pod 'Au10tixProofOfAddressUI'
  pod 'Au10tixSmartDocumentCaptureUI'
  pod 'Au10tixVoiceConsentUI'
  pod 'Au10tixNFCPassportUI'
  pod 'Au10tixLocalDataInferenceKit'
end
```

Then run:
```bash
pod repo add AU10TIX_IOS_ARTIFACTS_GITHUB https://au10tixmobile:{github_pat}@github.com/au10tixmobile/iOS_Artifacts_cocoapods_spec.git
pod install
```

### 2. Configure Xcode Project

**IMPORTANT**: Follow the detailed setup in `XCODE_SETUP.md`

Quick steps:

1. **Open Workspace**
   ```bash
   open IOSIntegrationSample.xcworkspace
   ```

2. **Configure Info.plist Permissions**
   - Target → Info tab → Add permissions (see XCODE_SETUP.md)
   - OR enable "Generate Info.plist File" in Build Settings

3. **Enable NFC Capability**
   - Target → Signing & Capabilities
   - Add "Near Field Communication Tag Reading"
   - Entitlements file is already configured

4. **Build Settings**
   - Minimum deployment target: iOS 13.0
   - Swift Language Version: Swift 5.0+
   - Generate Info.plist File: Yes (recommended)

### 3. Initialize SDK with Your Workflow

Replace the sample JWT in `Au10tixSDKManager.swift`:

```swift
// In Au10tixSDKManager.swift, update sampleWorkflowResponse
static let sampleWorkflowResponse = """
{
    "sessionId": "YOUR_SESSION_ID",
    "response": {
        "session": "YOUR_JWT_TOKEN",
        "accessToken": "YOUR_ACCESS_TOKEN",
        // ... rest of your workflow response
    }
}
"""
```

**Important**: Retrieve this JWT from your backend's "create workflow" API call.

## Usage Guide

### Basic Flow

1. **Launch App** → Main screen shows all available features
2. **Initialize SDK** → Tap "Initialize Au10tix SDK" button
3. **Select Feature** → Choose from 8 available verification features
4. **Complete Verification** → Follow on-screen instructions
5. **Review Results** → Captured data is processed by Au10tix backend

### Feature-Specific Notes

#### Smart Document Capture
- Toggle "Local Classification" for offline document detection
- Automatically updates local ML modules when enabled
- Supports all major ID document types

#### Passive Face Liveness
- No user interaction required
- Detects photo/video spoofing attempts
- Real-time quality feedback

#### NFC Passport
- Requires NFC-capable device (iPhone 7+)
- User must first scan passport MRZ optically
- Reads chip data securely

#### Voice Consent
- Customize consent text and duration
- Records audio for verification
- Useful for compliance requirements

#### Video Session
- Combines voice and video verification
- Configurable session durations
- Multi-purpose verification

#### ID Liveness
- Multi-angle document capture
- Detects photo/screen presentation attacks
- Configurable capture times for each angle

#### SecureMe Flow
- Pre-configured complete identity verification flow
- Combines SDC Front, SDC Back, and Passive Face Liveness
- No configuration needed - works out of the box
- Streamlined multi-step verification process

## Customization for Customers

### Removing Features

To create a custom sample with specific features only, see **`FEATURE_MAPPING.md`** for detailed instructions on removing individual features.

### Customizing UI

All UI components are in `Au10tixUIComponents.swift`:
- Modify colors in `FeatureCard`
- Adjust spacing in `ContentView`
- Customize banners and alerts

### Adding Custom Logic

Extend coordinators in `Au10tixFeatureViews.swift`:

```swift
extension SDCCoordinator: SDCSessionDelegate {
    func sdcSession(_ sdcSession: SDCSession, didCapture image: Au10Image, ...) {
        // Add custom processing here
        // Send to your backend
        // Show custom UI
    }
}
```

## Architecture

### SwiftUI + UIKit Bridge

The app uses `UIViewControllerRepresentable` to bridge Au10tix's UIKit components into SwiftUI:

```swift
SmartDocumentCaptureUIWrapper → UIViewControllerRepresentable
    ↓
SDCViewController (Au10tix UI)
    ↓
SDCCoordinator (Delegate handling)
    ↓
SwiftUI State Updates
```

### State Management

- **Au10tixSDKManager**: `@ObservableObject` for SDK state
- **ContentView**: Main state container
- **Feature Views**: Local `@State` for feature-specific data

## Permissions

All required permissions are configured in `Info.plist`:

| Permission | Purpose | Required For |
|------------|---------|--------------|
| Camera | Document/selfie capture | SDC, PFL, POA |
| Microphone | Voice recording | Voice Consent, Video Session |
| NFC | Passport chip reading | NFC Passport |
| Photo Library | Image selection | SDC, POA |
| Location | Enhanced verification | Optional |

## Troubleshooting

### SDK Initialization Fails
- Verify JWT token is valid and not expired
- Check network connectivity
- Ensure all required pods are installed

### NFC Not Working
- Confirm device supports NFC (iPhone 7+)
- Verify entitlements are properly configured
- Check Info.plist has NFC usage description

### Camera Permission Denied
- Check Info.plist has camera usage description
- Prompt user to enable in Settings
- Verify app has camera entitlement

### Build Errors
- Clean build folder (Cmd+Shift+K)
- Delete derived data
- Run `pod deintegrate && pod install`

## Backend Integration

### Workflow Creation

Before initializing the SDK, your backend should:

1. Call Au10tix Create Workflow API
2. Receive JWT session token
3. Pass token to iOS app
4. App initializes SDK with token

### Results Processing

After feature completion:

1. Au10tix SDK uploads data to backend
2. Your backend polls Au10tix Results API
3. Retrieve verification results
4. Present to user or take action

## Best Practices

1. **Always use backend JWT** - Never hardcode tokens
2. **Handle errors gracefully** - Show user-friendly messages
3. **Request permissions early** - Better UX
4. **Update local modules** - For offline classification
5. **Test on real devices** - Simulators don't support camera/NFC

## Support

For technical support or questions:
- **Documentation**: Au10tix Developer Portal
- **Email**: support@au10tix.com
- **Integration Issues**: Contact your Au10tix account manager

## License

This sample code is provided for integration purposes with Au10tix SDK.  
See Au10tix license agreement for SDK usage terms.

---

**Version**: 1.0  
**Last Updated**: December 2025  
**Minimum iOS**: 13.0  
**SDK Version**: Check Podfile for latest versions
