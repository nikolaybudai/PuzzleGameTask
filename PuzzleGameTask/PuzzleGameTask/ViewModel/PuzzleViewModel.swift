//
//  PuzzleViewModel.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import UIKit

//MARK: - Protocol
protocol PuzzleViewModelProtocol {
    var onPuzzleUpdated: (() -> Void)? { get set }
    var puzzleTiles: [PuzzleTile] { get set }
    var correctOrderTiles: [PuzzleTile] { get }
    
    func loadImage() async
    func splitImageIntoTiles(image: UIImage, rows: Int, columns: Int)
    func swapTiles(at firstIndex: Int, with secondIndex: Int)
    func isAtCorrectPosition(at index: Int) -> Bool
    func isPuzzleComplete() -> Bool
}

//MARK: - PuzzleViewModel

/// Handles the logic of the puzzle game
final class PuzzleViewModel: PuzzleViewModelProtocol {
    
    private let imageLoader: ImageLoaderProtocol
    
    private var puzzleImage: UIImage = UIImage()
    var correctOrderTiles: [PuzzleTile] = []
    
    var puzzleTiles: [PuzzleTile] = [] {
        didSet {
            onPuzzleUpdated?()
        }
    }
    
    var onPuzzleUpdated: (() -> Void)?
    
    //MARK: Init
    init(imageLoader: ImageLoaderProtocol) {
        self.imageLoader = imageLoader
    }
    
    //MARK: Methods
    
    
    /**
     Loads an image asynchronously using the ImageLoader, assigns it to `puzzleImage` property,
     calls the method to split the image into tiles.
    */
    func loadImage() async {
        let image = await imageLoader.loadImage(from: Constants.imageURL,
                                                defaultImageName: Constants.defaultImageName)
        DispatchQueue.main.async { [weak self] in
            guard let image = image,
                  let self = self else { return }
            self.puzzleImage = image
            
            self.splitImageIntoTiles(image: puzzleImage)
        }
    }
    
    
    /**
     Splits the provided image into tiles. The image is divided into the specified number of rows and columns.
     The splitted tiles are stored into `puzzleTiles`.
     After splitting, the tiles are shuffled, and their correct order is saved for later comparison.
     - Parameters:
       - image: The image to split into tiles.
       - rows: The number of rows to split the image into (default is 3).
       - columns: The number of columns to split the image into (default is 3).
     - Note: The image is divided based on the width and height of the original image.
     */
    func splitImageIntoTiles(image: UIImage, rows: Int = 3, columns: Int = 3) {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        var tiles: [PuzzleTile] = []
        var correctOrder: [PuzzleTile] = []
        
        let tileWidth = imageWidth / CGFloat(columns)
        let tileHeight = imageHeight / CGFloat(rows)
        
        for row in 0..<rows {
            for col in 0..<columns {
                let x = CGFloat(col) * tileWidth
                let y = CGFloat(row) * tileHeight
                let cropRect = CGRect(x: x, y: y, width: tileWidth, height: tileHeight)
                
                if let cgImage = image.cgImage?.cropping(to: cropRect) {
                    let croppedImage = UIImage(cgImage: cgImage)
                    let tile = PuzzleTile(id: UUID(),
                                          image: croppedImage,
                                          isFixed: false)
                    tiles.append(tile)
                    correctOrder.append(tile)
                }
            }
        }
        
        puzzleTiles = tiles
        correctOrderTiles = correctOrder
        
        puzzleTiles.shuffle()
        updateFixedTiles()
    }
    
    /**
     Swaps two tiles in the puzzle at the specified indices if they are not already in their correct position.
     - Parameters:
       - firstIndex: The index of the first tile to swap.
       - secondIndex: The index of the second tile to swap.
     - Note: After swapping the tiles, `onPuzzleUpdated` closure is triggered to notify about the change.
     */
    func swapTiles(at firstIndex: Int, with secondIndex: Int) {
        guard firstIndex != secondIndex,
             puzzleTiles.indices.contains(firstIndex),
             puzzleTiles.indices.contains(secondIndex) else {
            return
        }

        let firstTile = puzzleTiles[firstIndex]
        let secondTile = puzzleTiles[secondIndex]

        guard !firstTile.isFixed, !secondTile.isFixed else {
            return
        }
 
        puzzleTiles.swapAt(firstIndex, secondIndex)
 
        updateFixedTiles()
 
        onPuzzleUpdated?()
    }
    
    /**
     Checks if the tile at the specified index is in its correct position.
     - Parameters:
       - index: The index of the tile to check in the puzzle.
     - Returns:
       - `true` if the tile at the given index is in its correct position.
       - `false` otherwise.
     - Note: The correct position is determined by the tile's ID matching the ID in the correct order of tiles.
     */
    func isAtCorrectPosition(at index: Int) -> Bool {
        let tile = puzzleTiles[index]
        let correctTile = correctOrderTiles[index]
        
        return tile.id == correctTile.id
    }
    
    /**
     Checks if the puzzle is complete by verifying if all tiles are in their correct positions.
     Iterates through the `puzzleTiles` array.
     - Returns:
       - `true` if all tiles are in their correct position and the puzzle is complete.
       - `false` if there is at least one tile that is not in its correct position(is not fixed).
     - Note: A tile is  fixed if its position matches the correct order of tiles.
     */
    func isPuzzleComplete() -> Bool {
        puzzleTiles.allSatisfy { $0.isFixed }
    }
    
    //MARK: Private Helper Methods
    
    /// Updates the `isFixed` property of each tile in the puzzle based on its position relative to the correct order.
    private func updateFixedTiles() {
        for (index, tile) in puzzleTiles.enumerated() {
            if tile.id == correctOrderTiles[index].id {
                puzzleTiles[index].isFixed = true
            } else {
                puzzleTiles[index].isFixed = false
            }
        }
    }
}
