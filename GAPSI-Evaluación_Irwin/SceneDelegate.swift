//
//  SceneDelegate.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let productSearchVC = ProductSearchRouter.createModule()
        let navController = UINavigationController(rootViewController: productSearchVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}


