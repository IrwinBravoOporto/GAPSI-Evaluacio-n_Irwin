//
//  String + Extensions.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
