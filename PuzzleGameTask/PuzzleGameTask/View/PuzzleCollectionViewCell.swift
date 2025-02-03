//
//  PuzzleCollectionViewCell.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import UIKit

final class PuzzleCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PuzzleCollectionViewCell"
        
    private let imageView = UIImageView()
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Methods
    
    /// Configures the cell with the puzzle tile
    func configure(with tile: PuzzleTile) {
        imageView.image = tile.image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentView.alpha = 1.0
    }
}
