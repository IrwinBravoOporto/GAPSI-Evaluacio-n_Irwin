//
//  ProductSearchEntity.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import Foundation

struct ProductResponse: Decodable {
    let responseStatus: String
    let responseMessage: String
    let keyword: String
    let item: Item
    
    struct Item: Decodable {
        let query: Query
        let props: Props
        
        struct Query: Decodable {
            let query: String
            let sort: String
            let page: String
        }
        
        struct Props: Decodable {
            let pageProps: PageProps
            
            struct PageProps: Decodable {
                let initialData: InitialData
                
                struct InitialData: Decodable {
                    let searchResult: SearchResult
                    
                    struct SearchResult: Decodable {
                        let itemStacks: [ItemStack]
                        
                        struct ItemStack: Decodable {
                            let items: [Product]
                        }
                    }
                }
            }
        }
    }
}

struct Product: Decodable {
    let name: String?
    let price: Double?
    let image: String?
    let isOutOfStock: Bool?
    let rating: Rating?
    let description: String?
    let availabilityStatus: String?
    let canonicalUrl: String?
    
    struct Rating: Decodable {
        let averageRating: Double
        let numberOfReviews: Int?
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: NSNumber(value: price ?? 0)) ?? "$\(String(format: "%.2f", price ?? 0))"
    }
    
    var starRating: Int {
        return Int(round(rating?.averageRating ?? 0))
    }
    
    enum CodingKeys: String, CodingKey {
        case name, price, image, isOutOfStock
        case rating, description, availabilityStatus, canonicalUrl
    }
}
