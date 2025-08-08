//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Георгий on 26.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        guard let window = window else { return }
        
        //        UserDefaults.standard.removeObject(forKey: "onboardingComplete")
        
        let onboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
        
        if onboardingComplete {
            window.rootViewController = TabBarController()
        } else {
            window.rootViewController = OnboardingViewController()
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        }
        
        window.makeKeyAndVisible()
    }
}

