    //
//  Settings View.swift
//  trackit
//
//  Created by Samuel Valencia on 5/5/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var lastFMSession: Session
    var body: some View {
        VStack {
            ZStack {
                Text("Hello World")
                
                if (lastFMSession.username == "") {
                    Button("Sign In") {
                        lastFMSession.username = "test"
                    }
                } else {
                    Text(lastFMSession.username)
                }
                
            }
        }
    }
}
