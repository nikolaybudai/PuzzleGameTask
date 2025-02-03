//
//  ImageLoader.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import UIKit

//MARK: - Protocol
protocol ImageLoaderProtocol {
    func loadImage(from url: String, defaultImageName: String) async -> UIImage?
}

//MARK: - ImageLoader

/// Handles the logic of loading the image
final class ImageLoader: ImageLoaderProtocol {
    
    private let networkMonitor: NetworkMonitorProtocol
    
    //MARK: Init
    init(networkMonitor: NetworkMonitorProtocol) {
        self.networkMonitor = networkMonitor
    }
    
    //MARK: Methods
    
    /** Loads an image from the given URL asynchronously
     - Parameters:
       - url: The url to load the image
       - defaultImageName: The name of the image to return if there is no network connection
     - Returns: loaded image or the default image if the network connection failed
     */
    func loadImage(from url: String, defaultImageName: String) async -> UIImage? {
        guard let imageURL = URL(string: url),
              networkMonitor.isConnectionAvailable() else {
            return UIImage(named: defaultImageName)
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let image = UIImage(data: data) {
                return image
            } else {
                return UIImage(named: defaultImageName)
            }
        } catch {
            return UIImage(named: defaultImageName)
        }
    }
    
}
