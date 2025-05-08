    //
//  Settings View.swift
//  trackit
//
//  Created by Samuel Valencia on 5/5/25.
//

import SwiftUI
import OAuthSwift

struct SettingsView: View {
    @EnvironmentObject var lastFMSession: Session
    
    let apiKey = "";
    let secret = "";
    
    @State private var requestToken: String?
    @State private var showSafari = false
    @State private var 
    
    var body: some View {
        VStack {
            ZStack {
                if (lastFMSession.username == "") {
                    Color(Color.orange)
                    Button("Sign In") {
                       
                    }.foregroundStyle(Color.white)
                } else {
                    Text(lastFMSession.username)
                }
            }.frame(width: 375, height: 60) //TODO: Round border
            
            Spacer()
        }
    }
}
