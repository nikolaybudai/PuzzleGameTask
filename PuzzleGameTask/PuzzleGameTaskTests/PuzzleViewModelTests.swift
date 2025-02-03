//
//  PuzzleGameTaskTests.swift
//  PuzzleGameTaskTests
//
//  Created by Nikolay Budai on 31/01/25.
//

import XCTest
@testable import PuzzleGameTask

final class PuzzleViewModelTests: XCTestCase {
    
    var viewModel: PuzzleViewModel!
    var mockImageLoader: ImageLoaderMock!
    
    override func setUp() {
        super.setUp()
        mockImageLoader = ImageLoaderMock()
        viewModel = PuzzleViewModel(imageLoader: mockImageLoader)
    }
    
    override func tearDown() {
        viewModel = nil
        mockImageLoader = nil
        super.tearDown()
    }

    func testLoadImageCalled() async {
        await viewModel.loadImage()
        
        XCTAssertTrue(mockImageLoader.loadImageCalled,
                      "Loading image method was not called")
    }
    
    func testSplitImageIntoTiles() {
        let testImage = UIImage(named: Constants.defaultImageName)!
        
        viewModel.splitImageIntoTiles(image: testImage, rows: 3, columns: 3)
        
        XCTAssertEqual(viewModel.puzzleTiles.count, 9,
                       "The image is not divided correctly into tiles")
    }
    
    func testSwapTiles() {
        let testImage = UIImage(named: Constants.defaultImageName)!
        viewModel.splitImageIntoTiles(image: testImage, rows: 3, columns: 3)
        
        let firstIndex = 0
        let secondIndex = 4
        
        let firstTileBefore = viewModel.puzzleTiles[firstIndex]
        let secondTileBefore = viewModel.puzzleTiles[secondIndex]
        
        viewModel.swapTiles(at: firstIndex, with: secondIndex)
        
        XCTAssertEqual(viewModel.puzzleTiles[firstIndex].id,
                       secondTileBefore.id,
                       "Tiles are not swapped")
        XCTAssertEqual(viewModel.puzzleTiles[secondIndex].id,
                       firstTileBefore.id,
                       "Tiles are not swapped")
    }
    
    func testSwapFixedTiles() {
        let testImage = UIImage(named: Constants.defaultImageName)!
        viewModel.splitImageIntoTiles(image: testImage, rows: 3, columns: 3)
        
        viewModel.puzzleTiles[0].isFixed = true
        
        let firstTileBefore = viewModel.puzzleTiles[0]
        let secondTileBefore = viewModel.puzzleTiles[1]
        
        viewModel.swapTiles(at: 0, with: 1)
        
        XCTAssertEqual(viewModel.puzzleTiles[0].id,
                       firstTileBefore.id,
                       "Fixed tiles should not be swapped")
        XCTAssertEqual(viewModel.puzzleTiles[1].id,
                       secondTileBefore.id,
                       "Fixed tiles should not be swapped")
    }
    
    func testSwapTilesWithEqualIndices() {
        let testImage = UIImage(named: Constants.defaultImageName)!
        viewModel.splitImageIntoTiles(image: testImage, rows: 3, columns: 3)
        
        let index = 0
        let tileBeforeSwap = viewModel.puzzleTiles[index]
        
        viewModel.swapTiles(at: 0, with: 0)
        
        let tileAfterSwap = viewModel.puzzleTiles[index]
        
        XCTAssertEqual(viewModel.puzzleTiles[index].id,
                       viewModel.puzzleTiles[index].id,
                       "The tiles with the same index should not change")
    }
    
    func testIsTileAtCorrectPositionTrue() {
        let image = UIImage(named: Constants.defaultImageName)!
        viewModel.splitImageIntoTiles(image: image, rows: 3, columns: 3)
        
        let correctTile = viewModel.correctOrderTiles[0]
        viewModel.puzzleTiles[0] = correctTile
        let index = 0
        
        let isAtCorrectPosition = viewModel.isAtCorrectPosition(at: index)
        
        XCTAssertTrue(isAtCorrectPosition,
                      "The tile should be on the correct position")
    }
    
    func testPuzzleCompletedTrue() {
        let testImage = UIImage(named: Constants.defaultImageName)!
        viewModel.splitImageIntoTiles(image: testImage, rows: 3, columns: 3)
        
        for i in 0..<viewModel.puzzleTiles.count {
            viewModel.puzzleTiles[i].isFixed = true
        }
        
        XCTAssertTrue(viewModel.isPuzzleComplete(),
                      "Puzzle should be completed if all tiles are fixed")
    }
    
    func testIsPuzzleCompleteFalse() {
        let testImage = UIImage(named: Constants.defaultImageName)!
        viewModel.splitImageIntoTiles(image: testImage, rows: 3, columns: 3)
        
        viewModel.puzzleTiles[0].isFixed = false
        
        XCTAssertFalse(viewModel.isPuzzleComplete(),
                       "Puzzle should not be completed if at least one tile is not fixed")
    }

}
