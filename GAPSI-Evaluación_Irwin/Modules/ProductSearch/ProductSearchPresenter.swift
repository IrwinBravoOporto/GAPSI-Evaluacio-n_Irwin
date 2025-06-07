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
    
    private let historyManager: SearchHistoryManagerProtocol

    init(interactor: ProductSearchInteractorInputProtocol,
         router: ProductSearchRouterProtocol,
         historyManager: SearchHistoryManagerProtocol = SearchHistoryManager.shared) {
        self.interactor = interactor
        self.router = router
        self.historyManager = historyManager
    }
    
    
    func didSelectProduct(at index: Int) {
        guard let product = product(at: index) else { return }
        
        router?.navigateToProductDetail(from: view , product: product)
    }
    
    func product(at index: Int) -> Product? {
        guard index < products.count else { return nil }
        return products[index]
    }
    
    func searchProducts(with keyword: String) {
        let trimmedTerm = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                
        guard !trimmedTerm.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.showError("El término de búsqueda no puede estar vacío")
                self?.view?.showProducts([])
            }
            return
        }
        
        currentKeyword = keyword
        currentPage = 1
        canLoadMore = true
        
        view?.showLoading()
        historyManager.saveSearchTerm(keyword)
        
        interactor?.fetchProducts(keyword: keyword, page: currentPage)
    }
    
    func validateSearchTerm(_ term: String) -> Bool {
            let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmedTerm.isEmpty
        }
    
    func loadSearchHistory() {
        let history = SearchHistoryManager.shared.getSearchHistory()
        currentKeyword = history.first ?? ""
        
        DispatchQueue.main.async { [weak self] in
            if history.isEmpty {
                self?.view?.updateSearchHistory([])
            } else {
                self?.view?.updateSearchHistory(history)
                self?.loadMoreProducts()
            }
        }
    }
    
    func loadMoreProducts() {
        isLoadingMore = true
        currentPage += 1
        // 3. Validar el keyword
        if currentKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            debugPrint("🚫 No se puede cargar más - keyword inválido: \(currentKeyword)")
        } else {
            debugPrint("🔍 Cargando más productos para: '\(currentKeyword)', página: \(currentPage)")
            interactor?.fetchProducts(keyword: currentKeyword, page: currentPage)
        }
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
            self.canLoadMore = !products.isEmpty
            
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
