//
//  PuzzlePiece.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import UIKit

/**
 A struct for a single puzzle tile.
 Holds information about a puzzle tile, including its unique identifier and the image,
 and whether it is in its correct fixed position or not.
 - Properties:
    - `id`: A unique identifier for the tile.
    - `image`: The image of the tile.
    - `isFixed`: A flag indicating whether the tile is in the correct fixed position.
*/
struct PuzzleTile {
    let id: UUID
    var image: UIImage
    var isFixed: Bool
}
