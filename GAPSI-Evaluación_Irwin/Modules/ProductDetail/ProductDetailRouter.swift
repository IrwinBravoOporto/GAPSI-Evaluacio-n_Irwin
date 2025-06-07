//
//  ProductDetailRouter.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

class ProductDetailRouter: ProductDetailRouterProtocol {
    static func createModule(with product: Product) -> UIViewController {
        let view = ProductDetailViewController()
        let presenter = ProductDetailPresenter(product: product)
         
        
        view.presenter = presenter
        presenter.view = view
        
        
        return view
    }
}
