//
//  ProductSearchPresenter.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import Foundation

class ProductSearchPresenter: ProductSearchPresenterProtocol {
    weak var view: ProductSearchViewProtocol?
    var interactor: ProductSearchInteractorInputProtocol?
    var router: ProductSearchRouterProtocol?
    
    private var products: [Product] = []
    private var currentKeyword: String = ""
    private var currentPage: Int = 1
    private var isLoadingMore = false
    private var canLoadMore = true
    
    func searchProducts(with keyword: String) {
        guard !keyword.isEmpty else { return }
        
        currentKeyword = keyword
        currentPage = 1
        canLoadMore = true
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.showLoading()
        }
        
        interactor?.fetchProducts(keyword: keyword, page: currentPage)
    }
    
    func loadMoreProducts() {
        guard !isLoadingMore, canLoadMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        interactor?.fetchProducts(keyword: currentKeyword, page: currentPage)
    }
    
    func didSelectProduct(_ product: Product) {
        router?.navigateToProductDetail(from: view, product: product)
    }
    
  
}

extension ProductSearchPresenter: ProductSearchInteractorOutputProtocol {
    func productsFetched(_ products: [Product]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.view?.hideLoading()
            
            if self.currentPage == 1 {
                self.products = products
            } else {
                self.products.append(contentsOf: products)
            }
            
            self.isLoadingMore = false
            self.canLoadMore = !products.isEmpty // Solo cargar más si hay resultados
            
            // Actualizar vista
            if self.currentPage == 1 && products.isEmpty {
                self.view?.showEmptyState(message: "No encontramos productos con tu búsqueda.")
            } else {
                self.view?.showProducts(self.products)
            }
        }
    }
    
    func productsFetchFailed(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.hideLoading()
            self?.isLoadingMore = false
            self?.view?.showError(error)
        }
    }
}
