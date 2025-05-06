//
//  ContentView.swift
//  trackit
//
//  Created by Samuel Valencia on 5/2/25.
//

import SwiftUI

struct ContentView: View {
    
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                MainView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
    }
}



#Preview {
    ContentView()
}
