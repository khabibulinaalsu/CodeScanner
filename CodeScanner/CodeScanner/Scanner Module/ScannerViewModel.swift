import AVFoundation
import Combine
import SwiftUI

@MainActor
class ScannerViewModel: NSObject, ObservableObject {
    @Published var scannedCode: String?
    @Published var error: ScannerError?
    @Published var cameraPermissionGranted = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var captureSession: AVCaptureSession?
    @Published var isTorchOn: Bool? = nil
    
    private var isScanningEnabled = true
    private let persistence = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    private var captureDevice: AVCaptureDevice?
    
    enum ScannerError: LocalizedError {
        case cameraUnavailable
        case permissionDenied
        case scanningFailed
        
        var errorDescription: String? {
            switch self {
            case .cameraUnavailable:
                return "Камера недоступна"
            case .permissionDenied:
                return "Доступ к камере не разрешен"
            case .scanningFailed:
                return "Не удалось отсканировать код"
            }
        }
    }
    
    func toggleTorch() {
        guard let device = captureDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = (isTorchOn ?? false) ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            cameraPermissionGranted = await AVCaptureDevice.requestAccess(for: .video)
        default:
            cameraPermissionGranted = false
            error = .permissionDenied
            showPermissionDeniedAlert()
        }
    }
    
    func setupCaptureSession() async {
        let session = AVCaptureSession()
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            error = .cameraUnavailable
            return 
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [
                    .qr,
                    .ean8,
                    .ean13,
                    .pdf417
                ]
            } else {
                return
            }
            
            captureDevice = videoCaptureDevice
            if videoCaptureDevice.hasTorch {
                isTorchOn = false
            }
            captureSession = session
            
        } catch {
            self.error = .cameraUnavailable
        }
    }
    
    func startScanning() {
        isScanningEnabled = true
        
        Task {
            await requestCameraPermission()
            
            if cameraPermissionGranted {
                Task.detached {
                    await self.captureSession?.startRunning()
                }
            }
        }
    }
    
    func stopScanning() {
        Task.detached {
            await self.captureSession?.stopRunning()
        }
    }
    
    private func handleScannedCode(_ code: String, type: AVMetadataObject.ObjectType) {
        if isScanningEnabled {
            Task {
                scannedCode = code
                
                let codeType: CodeType
                
                if type == .qr {
                    codeType = .qr
                } else {
                    codeType = .barcode(nil)
                }
                
                let historyItem = HistoryItem(
                    id: UUID(),
                    title: codeType.displayName,
                    content: code,
                    codeType: codeType,
                    timestamp: Date()
                )
                if await persistence.isExisting(historyItem) {
                    showAlreadyExisted()
                } else {
                    await saveHistoryItem(historyItem)
                    showSuccessAlert(for: codeType)
                }
            }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        isScanningEnabled = false
    }
    
    private func saveHistoryItem(_ item: HistoryItem) async {
        await persistence.save(code: item)
    }
    
    private func showSuccessAlert(for codeType: CodeType) {
        alertMessage = "\(codeType.displayName) scanned successfully!"
        showingAlert = true
    }
    
    private func showAlreadyExisted() {
        alertMessage = "Данный код уже был отсканирован"
        showingAlert = true
    }
    
    private func showPermissionDeniedAlert() {
        showingAlert = true
    }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        Task { @MainActor in
            handleScannedCode(stringValue, type: readableObject.type)
            stopScanning()
        }
    }
}

