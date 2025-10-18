import SwiftUI

struct DetailView: View {
    
    @StateObject var viewModel: DetailViewModel
    @State var title: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    TextField("Название", text: $title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(viewModel.item.codeType.displayName)
                        Text(viewModel.item.timestamp.formattedDate)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Divider()
                
                if case let .barcode(productInfo) = viewModel.item.codeType,
                   let productInfo {
                    ProductInfoView(productInfo: productInfo)
                    
                }
                QRCodeContentView(code: viewModel.item.content)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: shareContent) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    private var shareContent: String {
        if case let .barcode(productInfo) = viewModel.item.codeType,
           let productInfo {
                return """
                Информация о продукте:
                Название: \(productInfo.productName ?? "Неизвестно")
                Бренд: \(productInfo.brands ?? "Неизвестно")
                Ингредиенты: \(productInfo.ingredientsText ?? "Не указаны")
                Nutri-Score: \(productInfo.nutriscoreGrade?.uppercased() ?? "Не указан")
                Код: \(viewModel.item.content)
                """
        } else {
            return "\(viewModel.item.codeType.displayName): \(viewModel.item.content)"
        }
    }
}

struct ProductInfoView: View {
    let productInfo: ProductInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let productName = productInfo.productName {
                InfoRow(title: "Название", value: productName)
            }
            
            if let brands = productInfo.brands {
                InfoRow(title: "Бренд", value: brands)
            }
            
            if let ingredients = productInfo.ingredientsText {
                InfoRow(title: "Ингредиенты", value: ingredients)
            }
            
            if let nutriScore = productInfo.nutriscoreGrade {
                InfoRow(title: "Nutri-Score", value: nutriScore.uppercased())
            }
        }
    }
}

struct QRCodeContentView: View {
    let code: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Содержимое:")
                .font(.headline)
            Text(code)
                .font(.body)
                .textSelection(.enabled)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            if let url = URL(string: code), UIApplication.shared.canOpenURL(url) {
                Button("Открыть ссылку") {
                    UIApplication.shared.open(url)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

