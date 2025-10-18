import Foundation

enum CodeType {
    case qr
    case barcode(ProductInfo?)
    
    var rawValue: String {
        switch self {
        case .qr:
            return "qr"
        case .barcode:
            return "barcode"
        }
    }
    
    var displayName: String {
        switch self {
        case .qr:
            return "QR код"
        case .barcode:
            return "Штрихкод"
        }
    }
    
    var iconName: String {
        switch self {
        case .qr:
            return "qrcode"
        case .barcode:
            return "barcode"
        }
    }
    
    static func fromRawValue(_ raw: String) -> CodeType {
        switch raw {
        case "qr":
            return .qr
        default:
            return .barcode(nil)
        }
    }
}
