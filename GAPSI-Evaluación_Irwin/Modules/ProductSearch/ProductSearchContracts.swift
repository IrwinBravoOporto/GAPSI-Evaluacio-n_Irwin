//
//  ProductSearchContracts.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

protocol ProductSearchViewProtocol: AnyObject {
    var presenter: ProductSearchPresenterProtocol? { get set }
    
    func showProducts(_ products: [Product])
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    func showEmptyState(message: String)
}

protocol ProductSearchPresenterProtocol: AnyObject {
    var view: ProductSearchViewProtocol? { get set }
    var interactor: ProductSearchInteractorInputProtocol? { get set }
    var router: ProductSearchRouterProtocol? { get set }
    
    func searchProducts(with keyword: String)
    func loadMoreProducts()
    func didSelectProduct(_ product: Product)
}

protocol ProductSearchInteractorInputProtocol: AnyObject {
    var presenter: ProductSearchInteractorOutputProtocol? { get set }
    var apiClient: APIClientProtocol { get set }
 
    func fetchProducts(keyword: String, page: Int)
    
}

protocol ProductSearchInteractorOutputProtocol: AnyObject {
    func productsFetched(_ products: [Product])
    func productsFetchFailed(_ error: String)
 }

protocol ProductSearchRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func navigateToProductDetail(from view: ProductSearchViewProtocol?, product: Product)
}

 
