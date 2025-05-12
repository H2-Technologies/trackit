//
//  trackitApp.swift
//  trackit
//
//  Created by Samuel Valencia on 5/2/25.
//

import SwiftUI
import UIKit



@main
struct trackitApp: App {
    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
    }
    
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sendingAppID = options[.sourceApplication]
        print("Source Application: \(sendingAppID ?? "Unknown"))")
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let path = components.path,
              let params = components.queryItems else {
                  print("Invalid URL")
                 return false
        }
        
        return true
    }
}
