source 'https://github.com/CocoaPods/Specs.git'

# ==============
#
# Attention
#
# Before installing Au10tix pods for the first time
# execute the next command in your terminal:
# pod repo add AU10TIX_IOS_ARTIFACTS_GITHUB https://au10tixmobile:{github_pat}@github.com/au10tixmobile/iOS_Artifacts_cocoapods_spec.git
#
# In order to obtain personal access token - contact Au10tix support.
#
# ==============

source 'https://github.com/au10tixmobile/iOS_Artifacts_cocoapods_spec.git'

platform :ios, '13.0'

target 'IOSIntegrationSample' do
  use_frameworks!

  # Au10tix SDK Pods - All Features
  # Core SDK
  pod 'Au10tixSecureMeKit', '4.7.0'

  # UI Components for each feature
  pod 'Au10tixSmartDocumentCaptureUI', '4.7.0'
  pod 'Au10tixPassiveFaceLivenessUI', '4.7.0'
  pod 'Au10tixProofOfAddressUI', '4.7.0'
  pod 'Au10tixNFCPassportUI', '4.7.0'
  pod 'Au10tixVoiceConsentUI', '4.7.0'

  # Additional capabilities
  pod 'Au10tixLocalDataInferenceKit', '4.7.0'
  
  # ======================================
  # CUSTOMIZATION GUIDE FOR BACKEND:
  # ======================================
  # To create a minimal sample for a specific customer,
  # comment out the pods for features they don't need:
  #
  # For Document Capture Only:
  #   - Keep: Au10tixSecureMeKit, Au10tixSmartDocumentCaptureUI
  #   - Remove: All others
  #
  # For Face Liveness Only:
  #   - Keep: Au10tixSecureMeKit, Au10tixPassiveFaceLivenessUI
  #   - Remove: All others
  #
  # For NFC Passport Only:
  #   - Keep: Au10tixSecureMeKit, Au10tixNFCPassportUI
  #   - Remove: All others
  #
  # After modifying, run: pod install
  # ======================================

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      
      # Fix for sandbox/rsync permission errors with frameworks
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
end
