//
//  ProductSearchRouter.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

class ProductSearchRouter: ProductSearchRouterProtocol {
    static func createModule() -> UIViewController {
        let view = ProductSearchViewController()
        let presenter = ProductSearchPresenter()
        let interactor = ProductSearchInteractor(
            apiClient: APIClient())
        let router = ProductSearchRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        return view
    }
    
    func navigateToProductDetail(from view: ProductSearchViewProtocol?, product: Product) {
        // Implementar navegación a detalle de producto
    }
}
