//
//  UIView+Extensions.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
