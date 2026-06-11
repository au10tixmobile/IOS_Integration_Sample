//
//  ContentView.swift
//  IOSIntegrationSample
//
//  Created by Mohammad Kittany on 03/12/2025.
//
//  All-in-One Au10tix SDK Integration Sample
//  Features: Smart Document Capture, Passive Face Liveness, Proof of Address,
//            NFC Passport, Voice Consent, Video Session, ID Thickness
//
//  Requirements:
//  - iOS 13.0+
//  - SwiftUI
//  - Au10tix SDK frameworks
//  - Camera, Microphone, NFC permissions (see Info.plist)
//

import SwiftUI
import AVFoundation

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

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var sdkManager = Au10tixSDKManager.shared
    @State private var showInitializationAlert = false
    @State private var selectedFeature: Au10tixFeature?
    @State private var hasRequestedCameraPermission = false
    @State private var isProcessing = false
    @State private var processingResult: String?
    @State private var scrollOffset: CGFloat = 0
    @State private var isInitializing = false
    @State private var workflowToken = ""
    @State private var showCopiedAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .onAppear {
                        let appearance = UINavigationBarAppearance()
                        appearance.configureWithTransparentBackground()
                        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
                        UINavigationBar.appearance().standardAppearance = appearance
                        UINavigationBar.appearance().scrollEdgeAppearance = appearance
                    }
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Navigation Bar Background with Rounded Corners
                            GeometryReader { geo in
                                if scrollOffset < -10 {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color(uiColor: .systemBackground).opacity(0.85))
                                        .frame(height: geo.safeAreaInsets.top + 44)
                                        .offset(y: -geo.safeAreaInsets.top)
                                        .padding(.horizontal, 16)
                                        .ignoresSafeArea(edges: .top)
                                }
                            }
                            .frame(height: 0)
                            .zIndex(1)
                            
                            // Compact Header with Scroll Effect
                            GeometryReader { geometry in
                                let offset = geometry.frame(in: .named("scroll")).minY
                                let headerProgress = min(max(offset / 100, 0), 1)
                                
                                compactHeaderView(progress: headerProgress)
                                    .onChange(of: offset) { newValue in
                                        scrollOffset = newValue
                                    }
                            }
                            .frame(height: max(80, 120 - scrollOffset * 0.4))
                            
                            VStack(spacing: 20) {
                                // Initialize Button Content (not the button itself)
                                if !sdkManager.isInitialized {
                                    initializeButtonContent
                                }
                                
                                // Features Grid
                                if sdkManager.isInitialized {
                                    featuresSection
                                }
                            }
                            .padding()
                            .padding(.bottom, 80) // Space for fixed button
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    
                    // Fixed button at bottom
                    if !sdkManager.isInitialized {
                        initializeButtonFixed
                    } else {
                        beginProcessingButton
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: requestCameraPermission)
            .errorAlert(error: $sdkManager.errorMessage)
            .sheet(item: $selectedFeature) { feature in
                FeatureView(feature: feature, onDismiss: {
                    selectedFeature = nil
                })
            }
        }
    }
    
    // MARK: - Compact Header View
    private func compactHeaderView(progress: CGFloat) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.badge.shield.checkmark.fill")
                .font(.system(size: 36 + progress * 24))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Au10tix Integration Sample")
                    .font(.title3)
                    .bold()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(sdkManager.isInitialized ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text(sdkManager.isInitialized ? "SDK Ready" : "Not Initialized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let sessionID = sdkManager.sessionID {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 4, height: 4)
                        
                        Button(action: {
                            UIPasteboard.general.string = sessionID
                            showCopiedAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedAlert = false
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("\(sessionID.suffix(20))...")
                                    .font(.caption2)
                                    .lineLimit(1)
                                Image(systemName: showCopiedAlert ? "checkmark" : "doc.on.doc")
                                    .font(.caption2)
                            }
                            .foregroundColor(showCopiedAlert ? .green : .blue)
                        }
                    }
                }
                
                // Workflow Information
                if sdkManager.isInitialized {
                    HStack(spacing: 8) {
                        if let orgId = sdkManager.organizationId {
                            HStack(spacing: 4) {
                                Text("Organization ID:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(orgId)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if let environment = sdkManager.environment {
                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 4, height: 4)
                            
                            HStack(spacing: 4) {
                                Text("Environment:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(environment)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .opacity(0.95)
    }
    
    // MARK: - Initialize Button Content
    private var initializeButtonContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Workflow Token")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    Task {
                        if let clipboardString = await getClipboardContent() {
                            workflowToken = clipboardString
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.caption)
                        Text("Paste")
                            .font(.caption)
                    }
                    .foregroundColor(.iOSBlue)
                }
            }
            
            TextEditor(text: $workflowToken)
                .font(.system(.caption, design: .monospaced))
                .frame(height: 350)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            if workflowToken.isEmpty {
                Text("Paste your workflow response JSON here")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    // MARK: - Initialize Button Fixed
    private var initializeButtonFixed: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: initializeSDK) {
                HStack {
                    if isInitializing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "power")
                    }
                    Text(isInitializing ? "Initializing..." : "Initialize Au10tix SDK")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isInitializing || workflowToken.isEmpty ? Color.iOSBlue.opacity(0.5) : Color.iOSBlue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isInitializing || workflowToken.isEmpty)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Begin Processing Button
    private var beginProcessingButton: some View {
        VStack(spacing: 0) {
            if let result = processingResult {
                VStack {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(result.contains("Success") ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            }
            
            Divider()
            
            Button(action: beginProcessing) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.seal.fill")
                    }
                    Text(isProcessing ? "Uploading..." : "Upload Media")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isProcessing ? Color.gray : Color.iOSBlue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Features")
                .font(.title3)
                .bold()
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(Au10tixFeature.allCases, id: \.self) { feature in
                    FeatureCard(
                        title: feature.title,
                        description: feature.description,
                        systemImage: feature.icon,
                        color: feature.color
                    ) {
                        selectedFeature = feature
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    private func requestCameraPermission() {
        guard !hasRequestedCameraPermission else { return }
        hasRequestedCameraPermission = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        case .denied, .restricted:
            DispatchQueue.main.async {
                sdkManager.errorMessage = "Camera permission is required for identity verification features"
            }
        @unknown default:
            break
        }
    }
    
    private func initializeSDK() {
        isInitializing = true
        Task {
            let result = await sdkManager.initializeSDK(
                workflowResponse: workflowToken.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            await MainActor.run {
                isInitializing = false
                switch result {
                case .success:
                    showInitializationAlert = true
                case .failure:
                    break // Error already set in sdkManager
                }
            }
        }
    }
    
    private func getClipboardContent() async -> String? {
        return await MainActor.run {
            UIPasteboard.general.string
        }
    }
    
    private func beginProcessing() {
        #if canImport(Au10tixCore)
        isProcessing = true
        processingResult = nil
        
        Au10tixBackendKit.shared.beginProcessing { [self] result in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                switch result {
                case .success(let requestID):
                    self.processingResult = "Success! Request ID: \(requestID.prefix(16))..."
                    debugPrint("✅ Begin Processing Success - Request ID: \(requestID)")
                case .failure(let error):
                    self.processingResult = "Error: \(error.localizedDescription)"
                    debugPrint("❌ Begin Processing Failed: \(error)")
                }
            }
        }
        #else
        processingResult = "Error: Au10tixCore not available"
        #endif
    }
}

// MARK: - Au10tix Feature Enum
enum Au10tixFeature: String, CaseIterable, Identifiable {
    case smartDocumentCapture
    case passiveFaceLiveness
    case proofOfAddress
    case nfcPassport
    case voiceConsent
    case videoSession
    case idThickness
    case secureMe
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .smartDocumentCapture: return "Smart Doc Capture"
        case .passiveFaceLiveness: return "Face Liveness"
        case .proofOfAddress: return "Proof of Address"
        case .nfcPassport: return "NFC Passport"
        case .voiceConsent: return "Voice Consent"
        case .videoSession: return "Video Session"
        case .idThickness: return "ID Thickness"
        case .secureMe: return "SecureMe"
        }
    }
    
    var description: String {
        switch self {
        case .smartDocumentCapture: return "Capture ID documents"
        case .passiveFaceLiveness: return "Verify live selfie"
        case .proofOfAddress: return "Verify address documents"
        case .nfcPassport: return "NFC chip reading"
        case .voiceConsent: return "Voice verification"
        case .videoSession: return "Video-based verification"
        case .idThickness: return "ID document thickness"
        case .secureMe: return "Flow Orchestrator"
        }
    }
    
    var icon: String {
        switch self {
        case .smartDocumentCapture: return "doc.text.viewfinder"
        case .passiveFaceLiveness: return "faceid"
        case .proofOfAddress: return "house.fill"
        case .nfcPassport: return "wave.3.right"
        case .voiceConsent: return "mic.fill"
        case .videoSession: return "video.fill"
        case .idThickness: return "person.text.rectangle"
        case .secureMe: return "shield.checkered"
        }
    }
    
    var color: Color {
        switch self {
        case .smartDocumentCapture: return .blue
        case .passiveFaceLiveness: return .green
        case .proofOfAddress: return .purple
        case .nfcPassport: return .orange
        case .voiceConsent: return .pink
        case .videoSession: return .red
        case .idThickness: return .indigo
        case .secureMe: return .yellow
        }
    }
}

// MARK: - Feature View
struct FeatureView: View {
    let feature: Au10tixFeature
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            Group {
                switch feature {
                case .smartDocumentCapture:
                    SmartDocumentCaptureView(onDismiss: onDismiss)
                case .passiveFaceLiveness:
                    PassiveFaceLivenessView(onDismiss: onDismiss)
                case .proofOfAddress:
                    ProofOfAddressView(onDismiss: onDismiss)
                case .nfcPassport:
                    NFCPassportView(onDismiss: onDismiss)
                case .voiceConsent:
                    VoiceConsentView(onDismiss: onDismiss)
                case .videoSession:
                    VideoSessionView(onDismiss: onDismiss)
                case .idThickness:
                    IDThicknessView(onDismiss: onDismiss)
                case .secureMe:
                    SecureMeView(onDismiss: onDismiss)
                }
            }
            .navigationTitle(feature.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onDismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
