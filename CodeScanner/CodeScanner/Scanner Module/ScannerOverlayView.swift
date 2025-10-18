import SwiftUI

struct ScannerOverlayView: View {
    
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let scanAreaSize = min(geometry.size.width, geometry.size.height) * 0.8
            
            ZStack(alignment: .bottom) {
                dimmedBackground(geometry: geometry, scanAreaSize: scanAreaSize)
                
                scanFrame(size: scanAreaSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                if let isTorchOn = viewModel.isTorchOn {
                    Button {
                        viewModel.toggleTorch()
                    } label: {
                        Image(systemName: isTorchOn ? "flashlight.on.circle.fill" : "flashlight.off.circle")
                            .font(.system(size: 54))
                            .padding(54)
                    }
                }
            }
        }
    }
    
    private func dimmedBackground(geometry: GeometryProxy, scanAreaSize: CGFloat) -> some View {
        Path { path in
            path.addRect(CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height))
            path.addRoundedRect(
                in: CGRect(
                    x: (geometry.size.width - scanAreaSize) / 2,
                    y: (geometry.size.height - scanAreaSize) / 2,
                    width: scanAreaSize,
                    height: scanAreaSize
                ),
                cornerSize: CGSize(width: 16, height: 16)
            )
        }
        .fill(style: FillStyle(eoFill: true))
        .foregroundColor(Color.black.opacity(0.6))
    }
    
    private func scanFrame(size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .frame(width: size, height: size)
            
        }
    }
    
}
