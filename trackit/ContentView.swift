//
//  ContentView.swift
//  trackit
//
//  Created by Samuel Valencia on 5/2/25.
//

import SwiftUI

class Session: ObservableObject {
    @Published var token: String = ""
    var username: String = ""
}

struct ContentView: View {
    @StateObject var lastFM: LastFm = LastFm()
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                MainView().environmentObject(lastFM)
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView().environmentObject(lastFM)
            }
        }
    }
}



#Preview {
    ContentView()
}
