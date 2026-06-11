//
//  Au10tixUIComponents.swift
//  IOSIntegrationSample
//
//  Created by Mohammad Kittany on 03/12/2025.
//

import SwiftUI

#if canImport(Au10tixCore)
import Au10tixCore
#endif

// MARK: - Color Extension
extension Color {
    static let iOSBlue = Color(hex: "0A84FF")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Camera Preview Wrapper
/// UIViewRepresentable wrapper for displaying camera preview
struct CameraPreviewView: UIViewRepresentable {
    let previewView: UIView
    
    func makeUIView(context: Context) -> UIView {
        return previewView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Feature Button
/// Reusable button for Au10tix features
struct FeatureButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Result Display View
/// View to display capture results
struct ResultDisplayView: View {
    let image: UIImage?
    let resultText: String?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Result")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            
            if let resultText = resultText, !resultText.isEmpty {
                ScrollView {
                    Text(resultText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Loading Indicator
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.9))
    }
}

// MARK: - Alert Extension
extension View {
    func errorAlert(error: Binding<String?>) -> some View {
        alert("Error", isPresented: .constant(error.wrappedValue != nil)) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let errorMessage = error.wrappedValue {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Info Banner
struct InfoBanner: View {
    let message: String
    let type: BannerType
    
    enum BannerType {
        case info, warning, success, error
        
        var color: Color {
            switch self {
            case .info: return .secondary
            case .warning: return .secondary
            case .success: return .secondary
            case .error: return .secondary
            }
        }
        
        var icon: String {
            switch self {
            case .info: return "info.circle"
            case .warning: return "info.circle"
            case .success: return "checkmark.circle"
            case .error: return "exclamationmark.circle"
            }
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.caption)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
