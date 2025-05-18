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
    @StateObject var lastfm: LastFM = LastFM()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Home", systemImage: "house") {
                    MainView()
                }
                Tab("Settings", systemImage: "gear") {
                    SettingsView()
                }
            }.environmentObject(lastfm)
                .onAppear(perform: {
                    _ = lastfm.initManager()
                })
        }
    }
    
    
}
