//
//  ProductDetailContracts.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

// MARK: - View Protocol
protocol ProductDetailViewProtocol: AnyObject {
    func showProductDetail(_ product: Product)
    func showError(_ message: String)
}

// MARK: - Presenter Protocol
protocol ProductDetailPresenterProtocol {
    var view: ProductDetailViewProtocol? { get set }
    var product: Product { get }
    func viewDidLoad()
}

// MARK: - Interactor Protocol
protocol ProductDetailInteractorInputProtocol {
    var presenter: ProductDetailInteractorOutputProtocol? { get set }
}

protocol ProductDetailInteractorOutputProtocol: AnyObject {
    // Puedes añadir métodos si necesitas procesamiento de datos
}

// MARK: - Router Protocol
protocol ProductDetailRouterProtocol {
    static func createModule(with product: Product) -> UIViewController
}
