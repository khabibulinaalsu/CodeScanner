import AVFoundation
import SwiftUI

struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(session: viewModel.captureSession, size: geometry.size)
                    .overlay(ScannerOverlayView(viewModel: viewModel))
                    .ignoresSafeArea()
                
                    .onAppear {
                        viewModel.startScanning()
                    }
                    .onDisappear {
                        viewModel.stopScanning()
                    }
                    .alert("Scan Result", isPresented: $viewModel.showingAlert) {
                        Button("OK") {
                            dismiss()
                        }
                    } message: {
                        Text(viewModel.alertMessage)
                    }
                    .alert(isPresented: .constant(viewModel.error != nil)) {
                        if viewModel.error == .permissionDenied {
                            return Alert(
                                title: Text("Необходим доступ к камере"),
                                primaryButton: .cancel(Text("Отмена")),
                                secondaryButton: .default(Text("Настройки")) {
                                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                                    
                                    if UIApplication.shared.canOpenURL(settingsURL) {
                                        UIApplication.shared.open(settingsURL)
                                    }
                                }
                            )
                        } else {
                            return Alert(
                                title: Text("Ошибка"),
                                message: Text(viewModel.error?.localizedDescription ?? "Неизвестная ошибка"),
                                dismissButton: .default(Text("OK")) {
                                    viewModel.error = nil
                                    dismiss()
                                }
                            )
                        }
                    }
            }
            .onAppear {
                Task {
                    await viewModel.setupCaptureSession()
                }
            }
        }
    }
}


struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession?
    let size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        guard let session = session else { return view }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let session = session else { return }
        
        if let preview = context.coordinator.previewLayer {
            preview.frame = CGRect(origin: .zero, size: size)
        } else {
            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            uiView.layer.addSublayer(preview)
            preview.frame = CGRect(origin: .zero, size: size)
            context.coordinator.previewLayer = preview
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
    
}
