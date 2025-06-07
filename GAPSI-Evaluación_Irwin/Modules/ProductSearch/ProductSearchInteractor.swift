//
//  ProductSearchInteractor.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import Foundation

class ProductSearchInteractor: ProductSearchInteractorInputProtocol {
    weak var presenter: ProductSearchInteractorOutputProtocol?
    var apiClient: APIClientProtocol
    
    private var currentKeyword: String = ""
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var isLoading: Bool = false
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchProducts(keyword: String, page: Int) {
        guard !isLoading else { return }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.apiClient.request(endpoint: .productSearch(keyword: keyword, page: page)) { (result: Result<ProductResponse, NetworkError>) in
                self?.isLoading = false
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        let products = response.item.props.pageProps.initialData.searchResult.itemStacks.first?.items ?? []
                        self?.presenter?.productsFetched(products)
                        print(products)
                    case .failure(let error):
                        self?.presenter?.productsFetchFailed(error.localizedDescription)
                        print(error)
                    }
                }
            }
        }
    }
    
     
}
