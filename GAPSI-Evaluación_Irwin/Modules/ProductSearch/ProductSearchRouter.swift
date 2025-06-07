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
        let interactor = ProductSearchInteractor(apiClient: APIClient())
        let router = ProductSearchRouter()
        
        // Inicializar el presenter con los parámetros requeridos
        let presenter = ProductSearchPresenter(
            interactor: interactor,
            router: router,
            historyManager: SearchHistoryManager.shared
        )
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        return view
    }
    
    func navigateToProductDetail(from view: ProductSearchViewProtocol?, product: Product) {
        // Implementar navegación a detalle de producto
        guard let viewController = view as? UIViewController else { return }
        
        let detailVC = ProductDetailRouter.createModule(with: product)
        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
}
