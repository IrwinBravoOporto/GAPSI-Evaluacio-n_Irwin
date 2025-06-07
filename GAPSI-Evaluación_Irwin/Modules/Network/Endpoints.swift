//
//  Endpoints.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import Foundation

enum Endpoint {
    case productSearch(keyword: String, page: Int)
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "axesso-walmart-data-service.p.rapidapi.com"
    }
    
    var path: String {
        switch self {
        case .productSearch:
            return "/wlm/walmart-search-by-keyword"
        }
    }
    
    var method: String {
        return "GET"
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .productSearch(let keyword, let page):
            return [
                URLQueryItem(name: "keyword", value: keyword),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "sortBy", value: "best_match")
            ]
        }
    }
}
