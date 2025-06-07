//
//  APIErrorResponse.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import Foundation

struct APIErrorResponse: Decodable {
    let message: String
    let code: Int?
}
