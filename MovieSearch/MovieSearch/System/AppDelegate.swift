//
//  AppDelegate.swift
//  MovieSearch
//
//  Created by Bishow Gurung on 6/4/2024.
//

import DesignSystem
import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        appSetup()
        return true
    }
    
    private func appSetup() {
        DesignSystem.Font.register()
    }
}
