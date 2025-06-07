//
//  ProductSearchViewController.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

class ProductSearchViewController: UIViewController, ProductSearchViewProtocol {
    var presenter: ProductSearchPresenterProtocol?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Buscar productos..."
        controller.searchBar.delegate = self
        controller.searchResultsUpdater = self // Nuevo
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        collection.backgroundColor = .systemBackground
        collection.delegate = self
        collection.dataSource = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageLoadingQueue = DispatchQueue(label: "com.ecommerce.imageLoading", qos: .userInitiated)
    private var imageLoadingOperations: [IndexPath: Operation] = [:]
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var products: [Product] = []
    private var searchHistory: [String] = []
    private var isLoadingMore = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.loadSearchHistory()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.prefetchDataSource = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Buscar Productos"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    
    // MARK: - ProductSearchViewProtocol
    
    func showProducts(_ products: [Product]) {
        self.products = products
        collectionView.reloadData()
        
        if products.isEmpty {
            showEmptyState(message: "No encontramos productos con tu búsqueda. Intenta con otro término.")
        } else {
            hideEmptyState()
        }
        
    }
    
    
    
    func showError(_ message: String) {
        showEmptyState(message: "Ocurrió un error: \(message)")
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showEmptyState(message: String) {
        emptyStateLabel.text = message
        emptyStateLabel.isHidden = false
        collectionView.isHidden = true
    }

    private func hideEmptyState() {
        emptyStateLabel.isHidden = true
        collectionView.isHidden = false
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        hideEmptyState()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    
}

extension ProductSearchViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.item >= products.count - 2 {
                presenter?.loadMoreProducts()
                break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let operation = imageLoadingOperations[indexPath] {
                operation.cancel()
                imageLoadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}

// Mejoras en el data source
extension ProductSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as? ProductCell else {
            return UICollectionViewCell()
        }
        
        let product = products[indexPath.item]
        cell.configure(with: product)
        
        loadImage(for: product, at: indexPath, in: collectionView)
        
        return cell
    }
    
    private func loadImage(for product: Product, at indexPath: IndexPath, in collectionView: UICollectionView) {
        DispatchQueue.main.async {
            if let cell = collectionView.cellForItem(at: indexPath) as? ProductCell {
                cell.setImage(UIImage(named: "EmptyProduct"))
            }
        }
        
        
        
        if let cachedImage = imageCache.object(forKey: (product.image ?? String()) as NSString) {
            DispatchQueue.main.async {
                if let cell = collectionView.cellForItem(at: indexPath) as? ProductCell {
                    cell.setImage(cachedImage)
                }
            }
        } else {
            let operation = BlockOperation()
            operation.addExecutionBlock { [weak self, weak operation] in
                guard let self = self,
                      let operation = operation,
                      !operation.isCancelled else { return }
                
                // Verificar nuevamente la URL
                guard let url = URL(string: product.image ?? String()) else {
                    self.setDefaultImage(at: indexPath, in: collectionView)
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard !operation.isCancelled,
                          error == nil,
                          let data = data,
                          let image = UIImage(data: data) else {
                        self.setDefaultImage(at: indexPath, in: collectionView)
                        return
                    }
                    
                    self.imageCache.setObject(image, forKey: (product.image ?? String()) as NSString)
                    
                    DispatchQueue.main.async {
                        if collectionView.indexPathsForVisibleItems.contains(indexPath),
                           let cell = collectionView.cellForItem(at: indexPath) as? ProductCell {
                            cell.setImage(image)
                        }
                    }
                }.resume()
            }
            
            imageLoadingOperations[indexPath]?.cancel()
            imageLoadingOperations[indexPath] = operation
            imageLoadingQueue.async {
                operation.start()
            }
        }
    }
    
    private func setDefaultImage(at indexPath: IndexPath, in collectionView: UICollectionView) {
        DispatchQueue.main.async {
            if collectionView.indexPathsForVisibleItems.contains(indexPath),
               let cell = collectionView.cellForItem(at: indexPath) as? ProductCell {
                cell.setImage(UIImage(named: "EmptyProduct"))
            }
        }
    }
}

extension ProductSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        imageLoadingOperations[indexPath]?.cancel()
    }
}

extension ProductSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewWidth = collectionView.frame.width - (padding * 2)
        let width = (collectionViewWidth - 8) / 2
        return CGSize(width: width, height: width * 1.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        presenter?.searchProducts(with: text)
    }
}

extension ProductSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2 {
            presenter?.loadMoreProducts()
        }
    }
}

extension ProductSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
            // historial
        }
    
    func updateSearchHistory(_ history: [String]) {
        searchHistory = history
    }
}


extension ProductSearchViewController: SearchHistoryManagerProtocol {
    func saveSearchTerm(_ term: String) {
        guard !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        SearchHistoryManager.shared.saveSearchTerm(term)
        
        searchHistory = SearchHistoryManager.shared.getSearchHistory()
       
    }
    
    func getSearchHistory() -> [String] {
        let history = SearchHistoryManager.shared.getSearchHistory()
        self.searchHistory = history
        return history
    }
    
    func clearSearchHistory() {
        SearchHistoryManager.shared.clearSearchHistory()
        
        searchHistory = []
        
        let alert = UIAlertController(
            title: "Historial borrado",
            message: "Se han eliminado todas las búsquedas anteriores",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ProductSearchViewController: UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectProduct(at: indexPath.row)
    }
}
