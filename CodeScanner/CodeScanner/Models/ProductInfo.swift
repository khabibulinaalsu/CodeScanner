import Foundation

struct ProductInfo: Codable {
    let productName: String?
    let brands: String?
    let ingredientsText: String?
    let nutriscoreGrade: String?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case ingredientsText = "ingredients_text"
        case nutriscoreGrade = "nutriscore_grade"
    }
}

