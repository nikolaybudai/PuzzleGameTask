//
//  SceneDelegate.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let networkMonitor = NetworkMonitor()
        let imageLoader = ImageLoader(networkMonitor: networkMonitor)
        let viewModel = PuzzleViewModel(imageLoader: imageLoader)
        let viewController = PuzzleViewController(viewModel: viewModel)
        
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()
    }

}

