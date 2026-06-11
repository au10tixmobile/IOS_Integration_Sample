//
//  Au10tixFeatureViews.swift
//  IOSIntegrationSample
//
//  Created by Mohammad Kittany on 03/12/2025.
//
//  Individual feature implementations for all Au10tix SDK capabilities
//

import SwiftUI
import UIKit

#if canImport(Au10tixCore)
import Au10tixCore
#endif

#if canImport(Au10tixBaseUI)
import Au10tixBaseUI
#endif

#if canImport(Au10tixSmartDocumentCaptureKit)
import Au10tixSmartDocumentCaptureKit
#endif

#if canImport(Au10tixSmartDocumentCaptureUI)
import Au10tixSmartDocumentCaptureUI
#endif

#if canImport(Au10tixPassiveFaceLivenessKit)
import Au10tixPassiveFaceLivenessKit
#endif

#if canImport(Au10tixPassiveFaceLivenessUI)
import Au10tixPassiveFaceLivenessUI
#endif

#if canImport(Au10tixProofOfAddressKit)
import Au10tixProofOfAddressKit
#endif

#if canImport(Au10tixProofOfAddressUI)
import Au10tixProofOfAddressUI
#endif

#if canImport(Au10tixNFCPassportKit)
import Au10tixNFCPassportKit
#endif

#if canImport(Au10tixNFCPassportUI)
import Au10tixNFCPassportUI
#endif

#if canImport(Au10tixVoiceConsentUI)
import Au10tixVoiceConsentUI
#endif

#if canImport(Au10tixLocalDataInferenceKit)
import Au10tixLocalDataInferenceKit
#endif

#if canImport(Au10tixSecureMeKit)
import Au10tixSecureMeKit
#endif

// MARK: - SDC Configuration
class SDCConfiguration: ObservableObject {
    @Published var useLocalClassification = false
    @Published var isFrontSide = true
    @Published var enableSuspiciousBehavior = true
    @Published var enableUpload = true
    @Published var enableCaptureButton = true
    @Published var enableCloseButton = true
    @Published var displayIntro = true
}

// MARK: - Smart Document Capture View
struct SmartDocumentCaptureView: View {
    let onDismiss: () -> Void
    
    @StateObject private var config = SDCConfiguration()
    @State private var isLoading = false
    @State private var showUIComponent = false
    @State private var showCustomSession = false
    @State private var showSettings = false
    @State private var showImagePicker = false
    @State private var imagePickerMode: ImagePickerMode = .classification
    @State private var selectedImages: [UIImage] = []
    
    enum ImagePickerMode {
        case classification  // 1 image (front only)
        case ocr            // 2 images (front & back)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Capture ID documents with automatic detection and quality checks",
                        type: .info
                    )
                    
                    // Settings Button
                    Button(action: { showSettings = true }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Configuration Settings")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .foregroundColor(.primary)
                    
                    // Front End Processing Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Front End Processing")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Button(action: {
                            imagePickerMode = .classification
                            selectedImages = []
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Front End Classification")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Select 1 image (ID front)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .foregroundColor(.primary)
                        
                        Button(action: {
                            imagePickerMode = .ocr
                            selectedImages = []
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "doc.text.viewfinder")
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("OCR Processing")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Select 2 images (ID front & back)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding()
            }
            
            // Action buttons at bottom
            VStack(spacing: 12) {
                Divider()
                
                Button(action: startSmartDocumentCapture) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("SDC with UI Component")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: { showCustomSession = true }) {
                    HStack {
                        Image(systemName: "camera.metering.center.weighted")
                        Text("SDC with Custom UI")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .overlay {
            if isLoading {
                LoadingView(message: "Updating modules...")
            }
        }
        .sheet(isPresented: $showUIComponent) {
            SmartDocumentCaptureUIWrapper(
                useLocalClassification: config.useLocalClassification,
                isFrontSide: config.isFrontSide,
                enableSuspiciousBehavior: config.enableSuspiciousBehavior,
                enableUpload: config.enableUpload,
                enableCaptureButton: config.enableCaptureButton,
                enableCloseButton: config.enableCloseButton,
                displayIntro: config.displayIntro,
                onDismiss: { showUIComponent = false }
            )
        }
        .fullScreenCover(isPresented: $showCustomSession) {
            SmartDocumentCaptureCustomSessionView(
                useLocalClassification: config.useLocalClassification,
                isFrontSide: config.isFrontSide,
                enableSuspiciousBehavior: config.enableSuspiciousBehavior,
                onDismiss: { showCustomSession = false }
            )
        }
        .sheet(isPresented: $showSettings) {
            SDCSettingsView(
                useLocalClassification: $config.useLocalClassification,
                isFrontSide: $config.isFrontSide,
                enableSuspiciousBehavior: $config.enableSuspiciousBehavior,
                enableUpload: $config.enableUpload,
                enableCaptureButton: $config.enableCaptureButton,
                enableCloseButton: $config.enableCloseButton,
                displayIntro: $config.displayIntro
            )
        }
        .sheet(isPresented: $showImagePicker) {
            SDCImagePicker(
                mode: imagePickerMode,
                selectedImages: $selectedImages,
                onComplete: { _ in
                    showImagePicker = false
                }
            )
        }
    }
    
    private func startSmartDocumentCapture() {
        if config.useLocalClassification {
            isLoading = true
            Au10tixSDKManager.shared.updateLocalModulesIfAvailable {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isLoading = false
                    showUIComponent = true
                }
            }
        } else {
            showUIComponent = true
        }
    }
}

// MARK: - SDC Image Picker
struct SDCImagePicker: View {
    let mode: SmartDocumentCaptureView.ImagePickerMode
    @Binding var selectedImages: [UIImage]
    let onComplete: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showPicker = false
    @State private var isProcessing = false
    @State private var resultMessage: String?
    #if canImport(Au10tixSmartDocumentCaptureKit)
    @State private var sdcSession: SDCSession?
    #endif
    
    var requiredImages: Int {
        mode == .classification ? 1 : 2
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                InfoBanner(
                    message: mode == .classification 
                        ? "Select 1 image of ID document (front side)"
                        : "Select 2 images of ID document (front then back)",
                    type: .info
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // Show image or placeholder for each required slot
                            ForEach(0..<requiredImages, id: \.self) { index in
                                if index < selectedImages.count {
                                    // Show selected image
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .cornerRadius(10)
                                        .overlay(
                                            Button(action: { selectedImages.remove(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.gray.opacity(0.8).clipShape(Circle()))
                                            }
                                            .padding(8),
                                            alignment: .topTrailing
                                        )
                                } else {
                                    // Show placeholder
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 150)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.gray.opacity(0.5))
                                                Text(index == 0 ? "ID Front" : "ID Back")
                                                    .font(.caption)
                                                    .foregroundColor(.gray.opacity(0.7))
                                            }
                                        )
                                }
                            }
                        }
                        
                        if let result = resultMessage {
                            InfoBanner(message: result, type: .success)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    if selectedImages.count < requiredImages {
                        Button(action: { showPicker = true }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                Text("Select Image \(selectedImages.count + 1) of \(requiredImages)")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.iOSBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                    }
                    
                    if selectedImages.count == requiredImages && !isProcessing && resultMessage == nil {
                        Button(action: processImages) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Process Images")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.iOSBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    if resultMessage != nil && !isProcessing {
                        Button(action: startOver) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                Text("Start Over")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.iOSBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    if isProcessing {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .iOSBlue))
                            Text("Processing...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle(mode == .classification ? "Classification" : "OCR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerViewController(selectedImages: $selectedImages)
        }
    }
    
    private func startOver() {
        selectedImages.removeAll()
        resultMessage = nil
        sdcSession = nil
    }
    
    private func processImages() {
        guard !selectedImages.isEmpty else { return }
        
        isProcessing = true
        resultMessage = nil
        
        switch mode {
        case .classification:
            if let image = selectedImages.first, let imageData = image.pngData() {
                processClassification(imageData: imageData)
            } else {
                isProcessing = false
                resultMessage = "❌ Failed to convert image to PNG data"
            }
        case .ocr:
            if selectedImages.count >= 2 {
                guard let frontData = selectedImages[0].pngData(),
                      let backData = selectedImages[1].pngData() else {
                    isProcessing = false
                    resultMessage = "❌ Failed to convert images to PNG data"
                    return
                }
                processOCR(frontData: frontData, backData: backData)
            } else {
                resultMessage = "⚠️ OCR requires 2 images (front & back)"
                isProcessing = false
            }
        }
    }
    
    private func processClassification(imageData: Data) {
        #if canImport(Au10tixSmartDocumentCaptureKit)
        // Retain session instance during async operation
        sdcSession = SDCSession()
        
        // Set timeout to prevent endless processing
        var hasCompleted = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if !hasCompleted {
                hasCompleted = true
                self.isProcessing = false
                self.resultMessage = "⚠️ Classification timed out after 30 seconds"
                self.sdcSession = nil
            }
        }
        
        sdcSession?.getClassification(image: imageData) { result in
            DispatchQueue.main.async {
                guard !hasCompleted else { return }
                hasCompleted = true
                self.isProcessing = false
                
                switch result {
                case .success(let data):
                    if let jsonString = String(data: data, encoding: .utf8) {
                        self.resultMessage = "✅ Classification Success:\n\n\(jsonString)"
                    } else {
                        self.resultMessage = "✅ Classification completed successfully"
                    }
                case .failure(let error):
                    self.resultMessage = "❌ Classification Error:\n\(error.localizedDescription)"
                }
                
                // Release session after completion
                self.sdcSession = nil
            }
        }
        #else
        isProcessing = false
        resultMessage = "❌ SmartDocumentCaptureKit not available"
        #endif
    }
    
    private func processOCR(frontData: Data, backData: Data) {
        #if canImport(Au10tixSmartDocumentCaptureKit)
        // Retain session instance during async operation
        sdcSession = SDCSession()
        
        // Set timeout to prevent endless processing
        var hasCompleted = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if !hasCompleted {
                hasCompleted = true
                self.isProcessing = false
                self.resultMessage = "⚠️ OCR timed out after 30 seconds"
                self.sdcSession = nil
            }
        }
        
        // Call the actual OCR API with both images
        sdcSession?.getOcr(images: [frontData, backData]) { result in
            DispatchQueue.main.async {
                guard !hasCompleted else { return }
                hasCompleted = true
                self.isProcessing = false
                
                switch result {
                case .success(let ocrConfirmation):
                    // Format the OCR response
                    var resultText = "✅ OCR Success:\n\n"
                    
                    if let ocr = ocrConfirmation.ocr {
                        resultText += "OCR Data:\n"
                        if let firstName = ocr.firstName?.value { resultText += "• First Name: \(firstName)\n" }
                        if let lastName = ocr.lastName?.value { resultText += "• Last Name: \(lastName)\n" }
                        if let docNumber = ocr.documentNumber?.value { resultText += "• Document Number: \(docNumber)\n" }
                        if let dob = ocr.dateOfBirth?.value { resultText += "• Date of Birth: \(dob)\n" }
                        if let expiry = ocr.dateOfExpiry?.value { resultText += "• Date of Expiry: \(expiry)\n" }
                    }
                    
                    if let classification = ocrConfirmation.classification {
                        resultText += "\nClassification:\n"
                        resultText += "• Country: \(classification.countryIso3 ?? "N/A")\n"
                        resultText += "• Document Type: \(classification.documentType ?? "N/A")\n"
                    }
                    
                    self.resultMessage = resultText
                    
                case .failure(let error):
                    self.resultMessage = "❌ OCR Error:\n\(error.localizedDescription)"
                }
                
                // Release session after completion
                self.sdcSession = nil
            }
        }
        #else
        isProcessing = false
        resultMessage = "❌ SmartDocumentCaptureKit not available"
        #endif
    }
}

// MARK: - Image Picker View Controller
struct ImagePickerViewController: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerViewController
        
        init(_ parent: ImagePickerViewController) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Smart Document Capture UI Wrapper
struct SmartDocumentCaptureUIWrapper: UIViewControllerRepresentable {
    let useLocalClassification: Bool
    let isFrontSide: Bool
    let enableSuspiciousBehavior: Bool
    let enableUpload: Bool
    let enableCaptureButton: Bool
    let enableCloseButton: Bool
    let displayIntro: Bool
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixBaseUI) && canImport(Au10tixSmartDocumentCaptureUI)
        let configs = UIComponentConfigs(
            showCloseButton: enableCloseButton,
            showPrimaryButton: enableCaptureButton,
            canUploadImage: enableUpload,
            shouldDisplayIntro: displayIntro,
            flowConfig: nil
        )
        let controller = SDCViewController(configs: configs, navigationDelegate: context.coordinator)
        
        controller.localClassification = useLocalClassification
        controller.isFrontSide = isFrontSide
        
        if enableSuspiciousBehavior {
            controller.suspiciousBehaviorConfig = SuspiciousBehaviorConfig()
        }
        
        // Set delegate last
        controller.sdcDelegate = context.coordinator
        
        return controller
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Smart Document Capture UI not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> SDCUICoordinator {
        SDCUICoordinator(onDismiss: onDismiss)
    }
}

// MARK: - SDC UI Coordinator
class SDCUICoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixBaseUI)
extension SDCUICoordinator: UIComponentViewControllerNavigationDelegate {
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
    
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
}
#endif

#if canImport(Au10tixSmartDocumentCaptureUI)
extension SDCUICoordinator: SDCSessionDelegate {
    func sdcSession(_ sdcSession: SDCSession, didFailWithError error: SDCSessionError) {
        debugPrint("❌ SDC Error: \(error)")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didProcess processingStatus: SDCProcessingStatus) {
        debugPrint("📊 SDC Processing - Valid: \(processingStatus.isValid), BadQuality: \(processingStatus.badQualityStatus != nil)")
    }

    func sdcSession(_ sdcSession: SDCSession, didCapture image: Au10Image, croppedImage: Au10Image?, with processingStatus: SDCProcessingStatus) {
        debugPrint("✅ SDC Captured image")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didTake image: Au10Image) {
        debugPrint("📸 SDC Image taken")
    }
}
#endif

// MARK: - PFL Configuration
class PFLConfiguration: ObservableObject {
    @Published var preventAutoCapture = false
    @Published var detectionDelay: Double = 0.5
    @Published var microphoneEnabled = false
    @Published var enableSuspiciousBehavior = true
    @Published var detectFaceInManualCapture = true
    @Published var checkLiveness = true
    @Published var enableCaptureButton = true
    @Published var enableCloseButton = true
    @Published var displayIntro = true
}

// MARK: - NFC Configuration
class NFCConfiguration: ObservableObject {
    @Published var useSdcScanner = true  // true = .sdc (auto-scan), false = .mrz (manual entry)
    @Published var enableCaptureButton = true
    @Published var enableCloseButton = true
    @Published var displayIntro = true
}

// MARK: - POA Configuration
class POAConfiguration: ObservableObject {
    @Published var useLocalClassification = false
    @Published var isFrontSide = true
    @Published var enableUpload = true
    @Published var enableCaptureButton = true
    @Published var enableCloseButton = true
    @Published var displayIntro = true
}

// MARK: - Passive Face Liveness View
struct PassiveFaceLivenessView: View {
    let onDismiss: () -> Void
    @StateObject private var config = PFLConfiguration()
    @State private var showUIComponent = false
    @State private var showCustomSession = false
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Verify that the selfie is from a live person, not a photo or video",
                        type: .info
                    )
                    
                    // Settings Button
                    Button(action: { showSettings = true }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Configuration Settings")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .foregroundColor(.primary)
                }
                .padding()
            }
            
            // Action buttons at bottom
            VStack(spacing: 12) {
                Divider()
                
                Button(action: { showUIComponent = true }) {
                    HStack {
                        Image(systemName: "face.smiling")
                        Text("PFL with UI Component")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: { showCustomSession = true }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                        Text("PFL with Custom UI")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showUIComponent) {
            PassiveFaceLivenessUIWrapper(
                detectionDelay: config.detectionDelay,
                enableSuspiciousBehavior: config.enableSuspiciousBehavior,
                onDismiss: { showUIComponent = false }
            )
        }
        .fullScreenCover(isPresented: $showCustomSession) {
            PassiveFaceLivenessCustomSessionView(
                onDismiss: { showCustomSession = false }
            )
        }
        .sheet(isPresented: $showSettings) {
            PFLSettingsView(
                preventAutoCapture: $config.preventAutoCapture,
                detectionDelay: $config.detectionDelay,
                microphoneEnabled: $config.microphoneEnabled,
                enableSuspiciousBehavior: $config.enableSuspiciousBehavior,
                detectFaceInManualCapture: $config.detectFaceInManualCapture,
                checkLiveness: $config.checkLiveness,
                enableCaptureButton: $config.enableCaptureButton,
                enableCloseButton: $config.enableCloseButton,
                displayIntro: $config.displayIntro
            )
        }
    }
}

// MARK: - Passive Face Liveness UI Wrapper
struct PassiveFaceLivenessUIWrapper: UIViewControllerRepresentable {
    let detectionDelay: Double
    let enableSuspiciousBehavior: Bool
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixBaseUI) && canImport(Au10tixPassiveFaceLivenessUI)
        let configs = UIComponentConfigs(
            showCloseButton: true,
            showPrimaryButton: true,
            canUploadImage: false,
            shouldDisplayIntro: true,
            flowConfig: [
                "pflDelayTime": detectionDelay,
                "isMicrophoneEnabled": false
            ]
        )
        let controller = PFLViewController(configs: configs, navigationDelegate: context.coordinator)
        
        // Set actual SDK properties
        controller.detectionDelay = detectionDelay
        
        if enableSuspiciousBehavior {
            controller.suspiciousBehaviorConfig = SuspiciousBehaviorConfig()
        }
        
        return controller
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Passive Face Liveness UI not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> PFLUICoordinator {
        PFLUICoordinator(onDismiss: onDismiss)
    }
}

// MARK: - PFL UI Coordinator
class PFLUICoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixBaseUI)
extension PFLUICoordinator: UIComponentViewControllerNavigationDelegate {
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
    
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
}
#endif

#if canImport(Au10tixPassiveFaceLivenessKit)
extension PFLUICoordinator: PFLSessionDelegate {
    func pflSession(_ pflSession: PFLSession, didCapture image: Data, qualityFeedback: QualityFaultOptions, faceBoundingBox: CGRect?) {
        debugPrint("📸 PFL Image captured")
    }
    
    func pflSession(_ pflSession: PFLSession, didRecieve qualityFeedback: QualityFaultOptions) {
        debugPrint("📊 PFL Quality feedback: \(qualityFeedback)")
    }
    
    func pflSession(_ pflSession: PFLSession, didConcludeWith result: PFLResponse, for image: Data) {
        debugPrint("✅ PFL Result - Score: \(result.score ?? 0), Quality: \(result.quality ?? 0)")
    }
    
    func pflSession(_ pflSession: PFLSession, didStartValidating image: Data) {
        debugPrint("🔄 PFL Validation started")
    }
    
    func pflSession(_ pflSession: PFLSession, didPassProbabilityThresholdFor image: Data) {
        debugPrint("✅ PFL Passed probability threshold")
    }
    
    func pflSession(_ pflSession: PFLSession, didFailWith error: PFLSessionError) {
        debugPrint("❌ PFL Error: \(error)")
    }
    
    func pflSession(_ pflSession: PFLSession, didCapture image: Data, qualityFeedback: QualityFaultOptions, faceBoundingBox: CGRect?, helmetResult: HelmetResult?, suspiciousBehaviorDetected: SuspiciousBehaviorDetection?) {
        debugPrint("📸 PFL Captured - Suspicious: \(suspiciousBehaviorDetected?.suspiciousBehavior ?? false)")
    }
}
#endif

// MARK: - Proof of Address View
struct ProofOfAddressView: View {
    let onDismiss: () -> Void
    @StateObject private var config = POAConfiguration()
    @State private var showUIComponent = false
    @State private var showCustomSession = false
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Capture utility bills or bank statements to verify address",
                        type: .info
                    )
                    
                    // Settings Button
                    Button(action: { showSettings = true }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Configuration Settings")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .foregroundColor(.primary)
                }
                .padding()
            }
            
            // Action buttons at bottom
            VStack(spacing: 12) {
                Divider()
                
                Button(action: { showUIComponent = true }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("POA with UI Component")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: { showCustomSession = true }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("POA with Custom UI")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showUIComponent) {
            ProofOfAddressUIWrapper(
                useLocalClassification: config.useLocalClassification,
                isFrontSide: config.isFrontSide,
                onDismiss: { showUIComponent = false }
            )
        }
        .fullScreenCover(isPresented: $showCustomSession) {
            ProofOfAddressCustomSessionView(onDismiss: { showCustomSession = false })
        }
        .sheet(isPresented: $showSettings) {
            POASettingsView(
                useLocalClassification: $config.useLocalClassification,
                isFrontSide: $config.isFrontSide,
                enableUpload: $config.enableUpload,
                enableCaptureButton: $config.enableCaptureButton,
                enableCloseButton: $config.enableCloseButton,
                displayIntro: $config.displayIntro
            )
        }
    }
}

// MARK: - Proof of Address UI Wrapper
struct ProofOfAddressUIWrapper: UIViewControllerRepresentable {
    let useLocalClassification: Bool
    let isFrontSide: Bool
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixBaseUI) && canImport(Au10tixProofOfAddressUI)
        let configs = UIComponentConfigs()
        let controller = POAViewController(configs: configs, navigationDelegate: context.coordinator)
        
        // Set properties before delegate
        controller.localClassification = useLocalClassification
        controller.isFrontSide = isFrontSide
        
        // Set delegate last
        controller.poaDelegate = context.coordinator
        return controller
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Proof of Address UI not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> POAUICoordinator {
        POAUICoordinator(onDismiss: onDismiss)
    }
}

// MARK: - POA UI Coordinator (uses SDCSession from Smart Document Capture Kit)
class POAUICoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixBaseUI)
extension POAUICoordinator: UIComponentViewControllerNavigationDelegate {
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
    
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
}
#endif

#if canImport(Au10tixSmartDocumentCaptureKit)
extension POAUICoordinator: SDCSessionDelegate {
    func sdcSession(_ sdcSession: SDCSession, didFailWithError error: SDCSessionError) {
        debugPrint("❌ POA Session Error: \(error)")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didProcess processingStatus: SDCProcessingStatus) {
        debugPrint("📸 POA Processing - Valid: \(processingStatus.isValid), BadQuality: \(processingStatus.badQualityStatus != nil)")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didCapture image: Au10Image, croppedImage: Au10Image?, with processingStatus: SDCProcessingStatus) {
        debugPrint("✅ POA Captured image")
        sdcSession.stop()
        DispatchQueue.main.async {
            self.onDismiss()
        }
    }
    
    func sdcSession(_ sdcSession: SDCSession, didTake image: Au10Image) {
        debugPrint("📷 POA Took image")
    }
}
#endif

// MARK: - POA Custom UI View (Using SDCSession)
struct ProofOfAddressCustomSessionView: UIViewControllerRepresentable {
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> POASessionViewController {
        let vc = POASessionViewController()
        vc.coordinator = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: POASessionViewController, context: Context) {}
    
    func makeCoordinator() -> POASessionCoordinator {
        POASessionCoordinator(onDismiss: onDismiss)
    }
}

// MARK: - POA Custom UI Coordinator (uses SDCSession from Smart Document Capture Kit)
class POASessionCoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixSmartDocumentCaptureKit)
extension POASessionCoordinator: SDCSessionDelegate {
    func sdcSession(_ sdcSession: SDCSession, didFailWithError error: SDCSessionError) {
        debugPrint("❌ POA Custom UI Error: \(error)")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didProcess processingStatus: SDCProcessingStatus) {
        debugPrint("📸 POA Custom Processing - Valid: \(processingStatus.isValid), BadQuality: \(processingStatus.badQualityStatus != nil)")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didCapture image: Au10Image, croppedImage: Au10Image?, with processingStatus: SDCProcessingStatus) {
        debugPrint("✅ POA Custom Captured image")
        sdcSession.stop()
        DispatchQueue.main.async {
            self.onDismiss()
        }
    }
    
    func sdcSession(_ sdcSession: SDCSession, didTake image: Au10Image) {
        debugPrint("📷 POA Custom Took image")
    }
}
#endif

class POASessionViewController: UIViewController {
    #if canImport(Au10tixSmartDocumentCaptureKit)
    private let poaSession = SDCSession()
    #endif
    private let cameraView = UIView()
    private let captureButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    var coordinator: POASessionCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if canImport(Au10tixSmartDocumentCaptureKit)
        poaSession.stop()
        #endif
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Camera view
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        statusLabel.numberOfLines = 0
        statusLabel.text = "Position document in frame"
        view.addSubview(statusLabel)
        
        // Capture button
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 25
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
        
        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            statusLabel.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func startSession() {
        #if canImport(Au10tixSmartDocumentCaptureKit)
        poaSession.flowType = .poa
        poaSession.delegate = coordinator
        poaSession.start(previewView: cameraView) { [weak self] result in
            switch result {
            case .success:
                self?.statusLabel.text = "Session started - Position document in frame"
            case .failure(let error):
                self?.statusLabel.text = "Error: \(error.localizedDescription)"
            }
        }
        #endif
    }
    
    @objc private func captureButtonTapped() {
        #if canImport(Au10tixSmartDocumentCaptureKit)
        poaSession.captureImage(.cameraCapture)
        statusLabel.text = "Capturing..."
        #endif
    }
    
    @objc private func closeButtonTapped() {
        coordinator?.onDismiss()
    }
}

// MARK: - SDC Custom UI Coordinator
class SDCSessionCoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixSmartDocumentCaptureKit)
extension SDCSessionCoordinator: SDCSessionDelegate {
    func sdcSession(_ sdcSession: SDCSession, didFailWithError error: SDCSessionError) {
        debugPrint("❌ SDC Session Error: \(error)")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didProcess processingStatus: SDCProcessingStatus) {
        debugPrint("📸 SDC Processing - Valid: \(processingStatus.isValid), BadQuality: \(processingStatus.badQualityStatus != nil)")
    }
    
    func sdcSession(_ sdcSession: SDCSession, didCapture image: Au10Image, croppedImage: Au10Image?, with processingStatus: SDCProcessingStatus) {
        debugPrint("✅ SDC Captured image")
        sdcSession.stop()
        DispatchQueue.main.async {
            self.onDismiss()
        }
    }
    
    func sdcSession(_ sdcSession: SDCSession, didTake image: Au10Image) {
        debugPrint("📷 SDC Took image")
    }
}
#endif

// MARK: - SDC Custom UI View
struct SmartDocumentCaptureCustomSessionView: UIViewControllerRepresentable {
    let useLocalClassification: Bool
    let isFrontSide: Bool
    let enableSuspiciousBehavior: Bool
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> SDCSessionViewController {
        let vc = SDCSessionViewController(
            useLocalClassification: useLocalClassification,
            isFrontSide: isFrontSide,
            enableSuspiciousBehavior: enableSuspiciousBehavior
        )
        vc.coordinator = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SDCSessionViewController, context: Context) {}
    
    func makeCoordinator() -> SDCSessionCoordinator {
        SDCSessionCoordinator(onDismiss: onDismiss)
    }
}

class SDCSessionViewController: UIViewController {
    #if canImport(Au10tixSmartDocumentCaptureKit)
    private let sdcSession = SDCSession()
    #endif
    private let cameraView = UIView()
    private let captureButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    private let useLocalClassification: Bool
    private let isFrontSide: Bool
    private let enableSuspiciousBehavior: Bool
    
    var coordinator: SDCSessionCoordinator?
    
    init(useLocalClassification: Bool = false, isFrontSide: Bool = true, enableSuspiciousBehavior: Bool = true) {
        self.useLocalClassification = useLocalClassification
        self.isFrontSide = isFrontSide
        self.enableSuspiciousBehavior = enableSuspiciousBehavior
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if canImport(Au10tixSmartDocumentCaptureKit)
        sdcSession.stop()
        #endif
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Camera view
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        statusLabel.numberOfLines = 0
        statusLabel.text = "Position document in frame"
        view.addSubview(statusLabel)
        
        // Capture button
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 25
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
        
        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            statusLabel.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func startSession() {
        #if canImport(Au10tixSmartDocumentCaptureKit)
        // Apply configurations
        sdcSession.flowType = .sdc
        sdcSession.localClassification = useLocalClassification
        sdcSession.isFrontSide = isFrontSide
        
        if enableSuspiciousBehavior {
            sdcSession.suspiciousBehaviorConfig = SuspiciousBehaviorConfig()
        }
        
        sdcSession.delegate = coordinator
        sdcSession.start(previewView: cameraView) { [weak self] result in
            switch result {
            case .success:
                self?.statusLabel.text = "Session started - Position document in frame"
            case .failure(let error):
                self?.statusLabel.text = "Error: \(error.localizedDescription)"
            }
        }
        #endif
    }
    
    @objc private func captureButtonTapped() {
        #if canImport(Au10tixSmartDocumentCaptureKit)
        sdcSession.captureImage(.cameraCapture)
        statusLabel.text = "Capturing..."
        #endif
    }
    
    @objc private func closeButtonTapped() {
        coordinator?.onDismiss()
    }
}

// MARK: - PFL Custom UI Coordinator
class PFLSessionCoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixPassiveFaceLivenessKit)
extension PFLSessionCoordinator: PFLSessionDelegate {
    func pflSession(_ pflSession: PFLSession, didFailWith error: PFLSessionError) {
        debugPrint("❌ PFL Session Error: \(error)")
    }
    
    func pflSession(_ pflSession: PFLSession, didRecieve qualityFeedback: QualityFaultOptions) {
        debugPrint("📸 PFL Quality: \(qualityFeedback)")
    }
    
    func pflSession(_ pflSession: PFLSession, didCapture image: Data, qualityFeedback: QualityFaultOptions, faceBoundingBox: CGRect?, helmetResult: HelmetResult?, suspiciousBehaviorDetected: SuspiciousBehaviorDetection?) {
        debugPrint("✅ PFL Captured image (suspicious: \(suspiciousBehaviorDetected?.suspiciousBehavior ?? false))")
        pflSession.validateImage(image)
    }
    
    func pflSession(_ pflSession: PFLSession, didConcludeWith result: PFLResponse, for image: Data) {
        debugPrint("✅ PFL Result: \(result)")
        pflSession.stop()
        DispatchQueue.main.async {
            self.onDismiss()
        }
    }
    
    func pflSession(_ pflSession: PFLSession, didStartValidating image: Data) {
        debugPrint("🔄 PFL Validating...")
    }
    
    func pflSession(_ pflSession: PFLSession, didPassProbabilityThresholdFor image: Data) {
        debugPrint("✅ PFL Passed threshold")
    }
}
#endif

// MARK: - PFL Custom UI View
struct PassiveFaceLivenessCustomSessionView: UIViewControllerRepresentable {
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> PFLSessionViewController {
        let vc = PFLSessionViewController()
        vc.coordinator = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PFLSessionViewController, context: Context) {}
    
    func makeCoordinator() -> PFLSessionCoordinator {
        PFLSessionCoordinator(onDismiss: onDismiss)
    }
}

class PFLSessionViewController: UIViewController {
    #if canImport(Au10tixPassiveFaceLivenessKit)
    private let pflSession = PFLSession()
    #endif
    private let cameraView = UIView()
    private let statusLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    var coordinator: PFLSessionCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if canImport(Au10tixPassiveFaceLivenessKit)
        pflSession.stop()
        #endif
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Camera view
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        statusLabel.numberOfLines = 0
        statusLabel.text = "Position your face in frame"
        view.addSubview(statusLabel)
        
        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func startSession() {
        #if canImport(Au10tixPassiveFaceLivenessKit)
        pflSession.delegate = coordinator
        pflSession.start(previewView: cameraView) { [weak self] result in
            switch result {
            case .success:
                self?.statusLabel.text = "Session started - Position your face in frame"
            case .failure(let error):
                self?.statusLabel.text = "Error: \(error.localizedDescription)"
            }
        }
        #endif
    }
    
    @objc private func closeButtonTapped() {
        coordinator?.onDismiss()
    }
}

// MARK: - NFC Passport View
struct NFCPassportView: View {
    let onDismiss: () -> Void
    @StateObject private var config = NFCConfiguration()
    @State private var showUIComponent = false
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Read passport data using NFC chip technology",
                        type: .info
                    )
                    
                    InfoBanner(
                        message: "Requires device with NFC capability and NFC entitlements",
                        type: .warning
                    )
                    
                    // Settings Button
                    Button(action: { showSettings = true }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Configuration Settings")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .foregroundColor(.primary)
                }
                .padding()
            }
            
            // Action button at bottom
            VStack(spacing: 0) {
                Divider()
                
                Button(action: { showUIComponent = true }) {
                    HStack {
                        Image(systemName: "wave.3.right")
                        Text("Start NFC Passport Scan")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showUIComponent) {
            NFCPassportUIWrapper(
                useSdcScanner: config.useSdcScanner,
                onDismiss: { showUIComponent = false }
            )
        }
        .sheet(isPresented: $showSettings) {
            NFCSettingsView(
                useSdcScanner: $config.useSdcScanner,
                enableCaptureButton: $config.enableCaptureButton,
                enableCloseButton: $config.enableCloseButton,
                displayIntro: $config.displayIntro
            )
        }
    }
}

// MARK: - NFC Passport UI Wrapper
struct NFCPassportUIWrapper: UIViewControllerRepresentable {
    let useSdcScanner: Bool
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixBaseUI) && canImport(Au10tixNFCPassportUI)
        let configs = UIComponentConfigs()
        let controller = NFCViewController(configs: configs, navigationDelegate: context.coordinator)
        
        // Set scanner type before delegate
        controller.nfcScannerType = useSdcScanner ? .sdc : .mrz
        
        // Set delegate last
        controller.nfcDelegate = context.coordinator
        controller.modalPresentationStyle = .fullScreen
        return controller
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "NFC Passport UI not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> NFCCoordinator {
        NFCCoordinator(onDismiss: onDismiss)
    }
}

// MARK: - NFC Coordinator
class NFCCoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixBaseUI)
extension NFCCoordinator: UIComponentViewControllerNavigationDelegate {
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
    
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
}
#endif

#if canImport(Au10tixNFCPassportKit)
extension NFCCoordinator: NFCPassportSessionDelegate {
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didScan passportMRZ: String, in frame: CIImage) {
        debugPrint("📱 NFC MRZ scanned: \(passportMRZ)")
    }
    
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didIndicate extractionProgress: String, of extractionPhase: String?) {
        debugPrint("🔄 NFC Progress: \(extractionProgress) - Phase: \(extractionPhase ?? "N/A")")
    }
    
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didExtract nfcInfo: PassportInformation) {
        debugPrint("✅ NFC Passport extracted")
    }
    
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didFailWith error: NFCPassportSessionError) {
        debugPrint("❌ NFC Error: \(error)")
    }
    
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didIndicate dataGroupsFound: [String]) {
        debugPrint("📊 NFC Data groups: \(dataGroupsFound)")
    }
}
#endif

// MARK: - Voice Consent View
struct VoiceConsentView: View {
    let onDismiss: () -> Void
    @State private var showUIComponent = false
    @State private var consentText = "Say each word out loud"
    @State private var sessionTime: Double = 5
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Record voice consent for verification purposes",
                        type: .info
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Consent Text")
                            .font(.headline)
                        TextField("Enter consent text", text: $consentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Session Duration: \(Int(sessionTime)) seconds")
                            .font(.headline)
                        Slider(value: $sessionTime, in: 3...10, step: 1)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
            
            // Action button at bottom
            VStack(spacing: 0) {
                Divider()
                
                Button(action: { showUIComponent = true }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Start Voice Consent")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showUIComponent) {
            VoiceConsentUIWrapper(
                consentText: consentText,
                sessionTime: Int(sessionTime),
                onDismiss: { showUIComponent = false }
            )
        }
    }
}

// MARK: - Voice Consent UI Wrapper
struct VoiceConsentUIWrapper: UIViewControllerRepresentable {
    let consentText: String
    let sessionTime: Int
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixBaseUI) && canImport(Au10tixVoiceConsentUI)
        let configs = UIComponentConfigs()
        let controller = VCViewController(configs: configs, navigationDelegate: context.coordinator)
        
        // Set properties before delegate
        controller.consentText = consentText
        controller.vcSessionTime = TimeInterval(sessionTime)
        
        // Set delegate last
        controller.vcDelegate = context.coordinator
        return controller
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Voice Consent UI not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> VCCoordinator {
        VCCoordinator(onDismiss: onDismiss)
    }
}

// MARK: - VC Coordinator
class VCCoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixBaseUI)
extension VCCoordinator: UIComponentViewControllerNavigationDelegate {
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
    
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
}
#endif

#if canImport(Au10tixVoiceConsentUI)
extension VCCoordinator: VCSessionDelegate {
    func vcSession(_ vcSession: VCSession, didFailWith error: VCSessionError) {
        debugPrint("❌ VC Error: \(error)")
    }
    
    func vcSession(_ vcSession: VCSession, didCapture videoUrl: URL) {
        debugPrint("✅ VC Video captured: \(videoUrl)")
    }
}
#endif

// MARK: - Video Session View
struct VideoSessionView: View {
    let onDismiss: () -> Void
    @State private var showUIComponent = false
    @State private var consentText = "Say each word out loud"
    @State private var vcSessionTime: Double = 7
    @State private var idSessionTime: Double = 5
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Combined video and voice session for comprehensive verification",
                        type: .info
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Consent Text")
                            .font(.headline)
                        TextField("Enter consent text", text: $consentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Voice Consent Duration: \(Int(vcSessionTime)) seconds")
                            .font(.headline)
                        Slider(value: $vcSessionTime, in: 3...10, step: 1)
                        
                        Text("ID Session Duration: \(Int(idSessionTime)) seconds")
                            .font(.headline)
                        Slider(value: $idSessionTime, in: 3...10, step: 1)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
            
            // Action button at bottom
            VStack(spacing: 0) {
                Divider()
                
                Button(action: { showUIComponent = true }) {
                    HStack {
                        Image(systemName: "video.fill")
                        Text("Start Video Session")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showUIComponent) {
            VideoSessionUIWrapper(
                consentText: consentText,
                vcSessionTime: Int(vcSessionTime),
                idSessionTime: Int(idSessionTime),
                onDismiss: { showUIComponent = false }
            )
        }
    }
}

// MARK: - Video Session UI Wrapper
struct VideoSessionUIWrapper: UIViewControllerRepresentable {
    let consentText: String
    let vcSessionTime: Int
    let idSessionTime: Int
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixBaseUI) && canImport(Au10tixVoiceConsentUI)
        let configs = UIComponentConfigs()
        let controller = VSViewController(configs: configs, navigationDelegate: context.coordinator)
        
        // Set properties before delegate
        controller.consentText = consentText
        controller.vcSessionTime = TimeInterval(vcSessionTime)
        controller.idSessionTime = TimeInterval(idSessionTime)
        
        // Set delegate last
        controller.vcDelegate = context.coordinator
        return controller
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Video Session UI not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> VSCoordinator {
        VSCoordinator(onDismiss: onDismiss)
    }
}

// MARK: - VS Coordinator
class VSCoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixBaseUI)
extension VSCoordinator: UIComponentViewControllerNavigationDelegate {
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
    
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
}
#endif

#if canImport(Au10tixVoiceConsentUI)
extension VSCoordinator: VCSessionDelegate {
    func vcSession(_ vcSession: VCSession, didFailWith error: VCSessionError) {
        debugPrint("❌ VS Error: \(error)")
    }
    
    func vcSession(_ vcSession: VCSession, didCapture videoUrl: URL) {
        debugPrint("✅ VS Video captured: \(videoUrl)")
    }
}
#endif

// MARK: - ID Thickness View
struct IDThicknessView: View {
    let onDismiss: () -> Void
    @State private var showUIComponent = false
    @State private var frontTime: Double = 8
    @State private var tiltedTime: Double = 8
    @State private var backTime: Double = 8
    @State private var instructionsDuration: Double = 3
    @State private var showConsent = true
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Multi-angle ID document verification for liveness detection",
                        type: .info
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Show Consent", isOn: $showConsent)
                        
                        Text("Front Capture: \(Int(frontTime)) seconds")
                            .font(.headline)
                        Slider(value: $frontTime, in: 5...15, step: 1)
                        
                        Text("Tilted Capture: \(Int(tiltedTime)) seconds")
                            .font(.headline)
                        Slider(value: $tiltedTime, in: 5...15, step: 1)
                        
                        Text("Back Capture: \(Int(backTime)) seconds")
                            .font(.headline)
                        Slider(value: $backTime, in: 5...15, step: 1)
                        
                        Text("Instructions Duration: \(Int(instructionsDuration)) seconds")
                            .font(.headline)
                        Slider(value: $instructionsDuration, in: 2...10, step: 1)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
            
            // Action button at bottom
            VStack(spacing: 0) {
                Divider()
                
                Button(action: { showUIComponent = true }) {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                        Text("Start ID Thickness Check")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showUIComponent) {
            IDThicknessUIWrapper(
                frontTime: Int(frontTime),
                tiltedTime: Int(tiltedTime),
                backTime: Int(backTime),
                instructionsDuration: Int(instructionsDuration),
                showConsent: showConsent,
                onDismiss: { showUIComponent = false }
            )
        }
    }
}

// MARK: - ID Thickness UI Wrapper
struct IDThicknessUIWrapper: UIViewControllerRepresentable {
    let frontTime: Int
    let tiltedTime: Int
    let backTime: Int
    let instructionsDuration: Int
    let showConsent: Bool
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixBaseUI) && canImport(Au10tixVoiceConsentUI)
        let configs = UIComponentConfigs()
        let controller = IDLivenessViewController(configs: configs, navigationDelegate: context.coordinator)
        
        // Set properties before delegate
        controller.frontTime = TimeInterval(frontTime)
        controller.tiltedTime = TimeInterval(tiltedTime)
        controller.backTime = TimeInterval(backTime)
        controller.instructionsDuration = TimeInterval(instructionsDuration)
        controller.showConsent = showConsent
        
        // Set delegate last
        controller.vcDelegate = context.coordinator
        return controller
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "ID Thickness UI not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> IDLCoordinator {
        IDLCoordinator(onDismiss: onDismiss)
    }
}

// MARK: - IDL Coordinator
class IDLCoordinator: NSObject {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
}

#if canImport(Au10tixBaseUI)
extension IDLCoordinator: UIComponentViewControllerNavigationDelegate {
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
    
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true) {
            self.onDismiss()
        }
    }
}
#endif

#if canImport(Au10tixVoiceConsentUI)
extension IDLCoordinator: VCSessionDelegate {
    func vcSession(_ vcSession: VCSession, didFailWith error: VCSessionError) {
        debugPrint("❌ IDL Error: \(error)")
    }
    
    func vcSession(_ vcSession: VCSession, didCapture videoUrl: URL) {
        debugPrint("✅ IDL Video captured: \(videoUrl)")
    }
}
#endif

// MARK: - SecureMe View
struct SecureMeView: View {
    let onDismiss: () -> Void
    @State private var showUIComponent = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    InfoBanner(
                        message: "Complete identity verification flow with multiple steps",
                        type: .info
                    )
                    
                    InfoBanner(
                        message: "SecureMe combines multiple features into one seamless flow. No configuration needed - the flow is pre-configured by OCS.",
                        type: .success
                    )
                    
                    if let error = errorMessage {
                        InfoBanner(message: error, type: .error)
                    }
                }
                .padding()
            }
            
            // Action button at bottom
            VStack(spacing: 0) {
                Divider()
                
                Button(action: startSecureMe) {
                    HStack {
                        Image(systemName: "shield.checkered")
                        Text("Start SecureMe Flow")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.iOSBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
        }
        .overlay {
            if isLoading {
                LoadingView(message: "Preparing SecureMe...")
            }
        }
        .sheet(isPresented: $showUIComponent) {
            SecureMeUIWrapper(
                onDismiss: { 
                    showUIComponent = false
                    errorMessage = nil
                },
                onError: { error in
                    errorMessage = error
                    showUIComponent = false
                }
            )
        }
    }
    
    private func startSecureMe() {
        errorMessage = nil
        isLoading = true
        
        // Simulate preparation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            showUIComponent = true
        }
    }
}

// MARK: - SecureMe UI Wrapper
struct SecureMeUIWrapper: UIViewControllerRepresentable {
    let onDismiss: () -> Void
    let onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        #if canImport(Au10tixSecureMeKit)
        let coordinator = context.coordinator
        coordinator.onDismiss = onDismiss
        coordinator.onError = onError
        
        // Use default pre-configured flows
        let flowConfig = SecureMeFlowConfig(
            showIntro: true,
            enableFileUpload: true,
            sendFeatureResult: true,
            localClassification: false,
            suspiciousBehaviorConfig: nil
        )
        
        // Default SecureMe flow includes all standard features
        let flows: [SecureMeFlow] = [
            .sdcFront(flowConfig),
            .sdcBack(flowConfig),
            .pfl(flowConfig)
        ]
        
        let featuresConfig = SecureMeFeaturesConfig(
            pflDetectionDelayEnabled: false,
            pflDelay: 0.0,
            sendResults: true
        )
        
        let secureMeConfig = SecureMeConfig(
            flows: flows,
            smConfig: featuresConfig
        )
        
        // Prepare SecureMeKit
        coordinator.secureMeKit.prepare { error in
            if let error = error {
                debugPrint("❌ SecureMe Prepare Error: \(error)")
                DispatchQueue.main.async {
                    coordinator.onError?("Preparation failed: \(error.localizedDescription)")
                }
                return
            }
            
            // Create UI after successful preparation
            do {
                let viewController = try coordinator.secureMeKit.createUI(
                    config: secureMeConfig,
                    delegate: coordinator
                )
                coordinator.viewController = viewController
                
                // Present the view controller
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        var topVC = rootVC
                        while let presented = topVC.presentedViewController {
                            topVC = presented
                        }
                        topVC.present(viewController, animated: true)
                    }
                }
            } catch {
                debugPrint("❌ SecureMe Create UI Error: \(error)")
                DispatchQueue.main.async {
                    coordinator.onError?("Failed to create UI: \(error.localizedDescription)")
                }
            }
        }
        
        // Return a temporary container
        let container = UIViewController()
        container.view.backgroundColor = .clear
        return container
        #else
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "SecureMe Kit not available"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> SecureMeCoordinator {
        SecureMeCoordinator()
    }
}

// MARK: - SecureMe Coordinator
class SecureMeCoordinator: NSObject {
    #if canImport(Au10tixSecureMeKit)
    let secureMeKit = SecureMeKit()
    weak var viewController: UIViewController?
    #endif
    
    var onDismiss: (() -> Void)?
    var onError: ((String) -> Void)?
}

#if canImport(Au10tixSecureMeKit)
extension SecureMeCoordinator: SecureMeKitDelegate {
    func secureMeKit(_ kit: SecureMeKit, hasUpdate update: SecureMeKitUpdate) {
        debugPrint("📊 SecureMe Update: \(update)")
    }
    
    func secureMeKit(_ kit: SecureMeKit, didCompleteWith result: SecureMeKitResult) {
        debugPrint("✅ SecureMe Completed - Request ID: \(result.requestId)")
        viewController?.dismiss(animated: true) {
            self.onDismiss?()
        }
    }
    
    func secureMeKit(_ kit: SecureMeKit, didFailWith error: SecureMeKitError) {
        debugPrint("❌ SecureMe Error: \(error)")
        viewController?.dismiss(animated: true) {
            self.onError?("SecureMe failed: \(error.localizedDescription)")
        }
    }
    
    func secureMeKit(_ kit: SecureMeKit, didClose viewController: UIViewController) {
        debugPrint("🚪 SecureMe Closed")
        viewController.dismiss(animated: true) {
            self.onDismiss?()
        }
    }
}
#endif

// MARK: - SDC Settings View
struct SDCSettingsView: View {
    @Binding var useLocalClassification: Bool
    @Binding var isFrontSide: Bool
    @Binding var enableSuspiciousBehavior: Bool
    @Binding var enableUpload: Bool
    @Binding var enableCaptureButton: Bool
    @Binding var enableCloseButton: Bool
    @Binding var displayIntro: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Local Classification", isOn: $useLocalClassification)
                    Toggle("Front Side", isOn: $isFrontSide)
                    Toggle("Suspicious Behavior Detection", isOn: $enableSuspiciousBehavior)
                } header: {
                    Text("Kit Configuration")
                } footer: {
                    Text("Local Classification processes documents on-device. Front Side captures the front of the document. Suspicious Behavior detects presentation attacks.")
                }
                
                Section {
                    Toggle("Enable Upload", isOn: $enableUpload)
                    Toggle("Enable Capture Button", isOn: $enableCaptureButton)
                    Toggle("Enable Close Button", isOn: $enableCloseButton)
                    Toggle("Display Intro", isOn: $displayIntro)
                } header: {
                    Text("UI Configuration")
                }
            }
            .navigationTitle("SDC Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - POA Settings View
struct POASettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var useLocalClassification: Bool
    @Binding var isFrontSide: Bool
    @Binding var enableUpload: Bool
    @Binding var enableCaptureButton: Bool
    @Binding var enableCloseButton: Bool
    @Binding var displayIntro: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Use Local Classification", isOn: $useLocalClassification)
                    Toggle("Front Side", isOn: $isFrontSide)
                } header: {
                    Text("Kit Configuration")
                } footer: {
                    Text("Local Classification processes document locally without server. Front Side determines whether scanning the front or back of document.")
                }
                
                Section {
                    Toggle("Enable Upload", isOn: $enableUpload)
                    Toggle("Enable Capture Button", isOn: $enableCaptureButton)
                    Toggle("Enable Close Button", isOn: $enableCloseButton)
                    Toggle("Display Introduction", isOn: $displayIntro)
                } header: {
                    Text("UI Configuration")
                }
            }
            .navigationTitle("POA Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - NFC Settings View
struct NFCSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var useSdcScanner: Bool
    @Binding var enableCaptureButton: Bool
    @Binding var enableCloseButton: Bool
    @Binding var displayIntro: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Use SDC Scanner (Auto-Scan)", isOn: $useSdcScanner)
                } header: {
                    Text("Scanner Configuration")
                } footer: {
                    Text(useSdcScanner ? "Automatically scan passport MRZ using camera" : "Manual MRZ text entry")
                }
                
                Section {
                    Toggle("Enable Capture Button", isOn: $enableCaptureButton)
                    Toggle("Enable Close Button", isOn: $enableCloseButton)
                    Toggle("Display Introduction", isOn: $displayIntro)
                } header: {
                    Text("UI Configuration")
                }
            }
            .navigationTitle("NFC Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - PFL Settings View
struct PFLSettingsView: View {
    @Binding var preventAutoCapture: Bool
    @Binding var detectionDelay: Double
    @Binding var microphoneEnabled: Bool
    @Binding var enableSuspiciousBehavior: Bool
    @Binding var detectFaceInManualCapture: Bool
    @Binding var checkLiveness: Bool
    @Binding var enableCaptureButton: Bool
    @Binding var enableCloseButton: Bool
    @Binding var displayIntro: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Prevent Auto Capture", isOn: $preventAutoCapture)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Detection Delay")
                            Spacer()
                            Text(String(format: "%.1fs", detectionDelay))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $detectionDelay, in: 0...3, step: 0.1)
                    }
                    
                    Toggle("Microphone Enabled", isOn: $microphoneEnabled)
                    Toggle("Suspicious Behavior Detection", isOn: $enableSuspiciousBehavior)
                    Toggle("Detect Face in Manual Capture", isOn: $detectFaceInManualCapture)
                } header: {
                    Text("Kit Configuration")
                } footer: {
                    Text("Detection Delay sets the time before face detection starts. Suspicious Behavior Detection identifies presentation attacks. Detect Face in Manual Capture ensures face is detected even when manually triggering capture.")
                }
                
                Section {
                    Toggle("Check Liveness", isOn: $checkLiveness)
                    Toggle("Enable Capture Button", isOn: $enableCaptureButton)
                    Toggle("Enable Close Button", isOn: $enableCloseButton)
                    Toggle("Display Intro", isOn: $displayIntro)
                } header: {
                    Text("UI Configuration")
                } footer: {
                    Text("Check Liveness verifies the selfie is from a live person, not a photo or video.")
                }
            }
            .navigationTitle("PFL Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
