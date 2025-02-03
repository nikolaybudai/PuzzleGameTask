//
//  ImageLoaderMock.swift
//  PuzzleGameTaskTests
//
//  Created by Nikolay Budai on 02/02/25.
//

import UIKit

@testable import protocol PuzzleGameTask.ImageLoaderProtocol
@testable import enum PuzzleGameTask.Constants

final class ImageLoaderMock: ImageLoaderProtocol {
    
    var loadImageCalled = false
    
    func loadImage(from url: String, defaultImageName: String) async -> UIImage? {
        loadImageCalled = true
        return UIImage(named: defaultImageName)
    }
}
