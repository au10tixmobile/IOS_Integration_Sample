//
//  Au10tixSDKManager.swift
//  IOSIntegrationSample
//
//  Created by Mohammad Kittany on 03/12/2025.
//

import Foundation
import SwiftUI

#if canImport(Au10tixCore)
import Au10tixCore
#endif

#if canImport(Au10tixSmartDocumentCaptureKit)
import Au10tixSmartDocumentCaptureKit
#endif

#if canImport(Au10tixPassiveFaceLivenessKit)
import Au10tixPassiveFaceLivenessKit
#endif

#if canImport(Au10tixProofOfAddressKit)
import Au10tixProofOfAddressKit
#endif

#if canImport(Au10tixNFCPassportKit)
import Au10tixNFCPassportKit
#endif

#if canImport(Au10tixLocalDataInferenceKit)
import Au10tixLocalDataInferenceKit
#endif

/// Manages Au10tix SDK initialization and workflow
class Au10tixSDKManager: ObservableObject {
    static let shared = Au10tixSDKManager()
    
    @Published var isInitialized = false
    @Published var sessionID: String?
    @Published var errorMessage: String?
    @Published var isLocalClassificationEnabled = false
    
    // Workflow information
    @Published var organizationId: String?
    @Published var environment: String?
    
    private init() {}
    
    /// Extract environment from API URL
    private func extractEnvironment(from apiUrl: String?) -> String? {
        guard let apiUrl = apiUrl else { return nil }
        
        if apiUrl.contains("qa") || apiUrl.contains("servicesqa") {
            return "QA"
        } else if apiUrl.contains("staging") || apiUrl.contains("stg") {
            return "Staging"
        } else if apiUrl.contains("dev") {
            return "Development"
        } else {
            return "Production"
        }
    }
    
    /// Update workflow information from Au10tixCore
    private func updateWorkflowInfo() {
        #if canImport(Au10tixCore)
        if let workflowWrapper = Au10tix.shared.workflowWrapper {
            organizationId = workflowWrapper.accessToken?.clientOrganizationID
            environment = extractEnvironment(from: workflowWrapper.accessToken?.apiURL)
        }
        #endif
    }
    
    /// Initialize Au10tix SDK with workflow response
    /// - Parameter workflowResponse: JWT token response from create workflow API
    /// - Returns: Success or failure with error message
    func initializeSDK(workflowResponse: String) async -> Result<String, Error> {
        #if canImport(Au10tixCore)
        guard let data = workflowResponse.data(using: .utf8),
              let responseDecoded = try? JSONDecoder().decode(Au10tixWorkflow.self, from: data) else {
            let error = NSError(domain: "Au10tixSDKManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode workflow response"])
            await MainActor.run {
                self.errorMessage = "Failed to decode workflow response"
            }
            return .failure(error)
        }
        
        Au10tix.shared.updateWorkflowWrapper(responseDecoded)
        
        // Extract session ID from the decoded workflow response
        let extractedSessionID = responseDecoded.sessionId
        
        return await withCheckedContinuation { continuation in
            Au10tix.shared.prepare { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success:
                        self?.isInitialized = true
                        // Use the session ID from the decoded response, fallback to workflowWrapper
                        self?.sessionID = extractedSessionID ?? Au10tix.shared.workflowWrapper?.sessionToken?.sessionId
                        self?.errorMessage = nil
                        self?.updateWorkflowInfo()
                        debugPrint("✅ Au10tix SDK initialized - SessionID: \(self?.sessionID ?? "N/A")")
                        continuation.resume(returning: .success(self?.sessionID ?? "N/A"))
                    case .failure(let error):
                        self?.isInitialized = false
                        self?.errorMessage = error.localizedDescription
                        debugPrint("❌ Au10tix SDK initialization failed: \(error)")
                        continuation.resume(returning: .failure(error))
                    }
                }
            }
        }
        #else
        let error = NSError(domain: "Au10tixSDKManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Au10tixCore not available"])
        await MainActor.run {
            self.errorMessage = "Au10tixCore framework not available"
        }
        return .failure(error)
        #endif
    }
    
    /// Check if local data inference modules need updating
    func updateLocalModulesIfAvailable(completion: @escaping () -> Void) {
        #if canImport(Au10tixLocalDataInferenceKit)
        Au10tixLocalDataInferenceManager.downloadModules { [weak self] result in
            debugPrint("Au10tixLocalDataInferenceKit updateModules result: \(result)")
            DispatchQueue.main.async {
                switch result {
                case .success:
                    debugPrint("✅ Local modules updated successfully")
                case .failure(let error):
                    debugPrint("⚠️ Local modules update failed: \(error)")
                    self?.errorMessage = "Failed to update local modules: \(error.localizedDescription)"
                }
                completion()
            }
        }
        #else
        completion()
        #endif
    }
    
    /// Reset SDK state
    func reset() {
        isInitialized = false
        sessionID = nil
        errorMessage = nil
        organizationId = nil
        environment = nil
    }
}

// MARK: - Sample Workflow Response
extension Au10tixSDKManager {
    /// Sample workflow response - Replace with actual JWT from your backend
    /// WARNING: This is a placeholder. Use the JWT retrieved from your backend's 'create workflow' API
    static let sampleWorkflowResponse = ""
}
