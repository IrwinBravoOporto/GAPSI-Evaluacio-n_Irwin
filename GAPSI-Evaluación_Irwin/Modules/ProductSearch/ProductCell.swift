//
//  ProductCell.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//
import UIKit

class ProductCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCell"
    
    // MARK: - UI Components
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let stockStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        [imageView, titleLabel, priceLabel, ratingStack, stockStatusLabel, favoriteButton].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            ratingStack.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            ratingStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            stockStatusLabel.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 4),
            stockStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stockStatusLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    // MARK: - Configuration
    func configure(with product: Product) {
        titleLabel.text = product.name
        priceLabel.text = product.formattedPrice
        
        imageView.image = nil
        
        setupRatingStars(rating: product.starRating)
        
        stockStatusLabel.text = product.isOutOfStock ?? false ? "Agotado" : "Disponible"
        stockStatusLabel.textColor = product.isOutOfStock ?? false ? .systemRed : .systemGreen
        
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    }
    
    private func setupRatingStars(rating: Int) {
        ratingStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.image = UIImage(systemName: i <= rating ? "star.fill" : "star")
            starImageView.tintColor = .systemYellow
            starImageView.contentMode = .scaleAspectFit
            starImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            ratingStack.addArrangedSubview(starImageView)
        }
    }
    
    func setImage(_ image: UIImage?) {
        // Usar sistema de prioridad de imágenes
        if let image = image {
            imageView.image = image
        } else {
            // Imagen por defecto con animación de transición
            UIView.transition(with: imageView,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.imageView.image = UIImage(named: "EmptyProduct")
                              },
                              completion: nil)
        }
        
        // Mejorar la visualización de imágenes con bordes redondeados
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    @objc private func toggleFavorite() {
        let isFavorite = favoriteButton.tintColor == .systemRed
        favoriteButton.setImage(UIImage(systemName: isFavorite ? "heart" : "heart.fill"), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemGray : .systemRed
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
        ratingStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stockStatusLabel.text = nil
    }
}
