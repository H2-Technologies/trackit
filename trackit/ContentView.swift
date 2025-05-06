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
    @StateObject var lastFMSession: Session = Session()
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                MainView().environmentObject(lastFMSession)
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView().environmentObject(lastFMSession)
            }
        }
    }
}



#Preview {
    ContentView()
}
