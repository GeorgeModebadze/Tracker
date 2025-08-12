//
//  AppDelegate.swift
//  Tracker
//
//  Created by Георгий on 26.07.2025.
//
import CoreData
import UIKit
//import AppMetricaCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        if let configuration = AppMetricaConfiguration(apiKey: "Your_API_Key") {
//            AppMetrica.activate(with: configuration)
//        }
        
        DaysValueTransformer.register()
        print("CoreData is setup")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let store = TrackerStore()
            store.printAllTrackersInDatabase()
        }
        return true
    }
    
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

