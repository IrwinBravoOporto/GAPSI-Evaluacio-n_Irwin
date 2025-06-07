//
//  ProductDetailPresenter.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import Foundation

class ProductDetailPresenter: ProductDetailPresenterProtocol {
    weak var view: ProductDetailViewProtocol?
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    func viewDidLoad() {
        view?.showProductDetail(product)
    }
}
