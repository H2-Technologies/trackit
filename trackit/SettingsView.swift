//
//  Settings View.swift
//  trackit
//
//  Created by Samuel Valencia on 5/5/25.
//

import SwiftUI
import OAuthSwift
import SafariServices
import Foundation
import CryptoKit
import AsyncObjects

struct Wrapper: Codable {
    let token: String
}

struct SettingsView: View {
    @EnvironmentObject var lastFM: LastFm
    
    @State private var requestToken: String?
    @State private var showSafari = false
    @State private var authorizationURL: URL = URL(string: "https://example.com")!;
    @State private var sessionKey: String?
    @State private var sessionusername: String?
    @State private var authError: String?
    
    init() {
        
    }
    
    var body: some View {
        VStack {
            ZStack {
                //TODO: Convert to just a Button
                if (lastFM.username == "") {
                    Color(Color.orange)
                    Button("Sign In") {
                        Task {
                            authorizationURL = lastFM.getAuthUrl()
                            print(authorizationURL.string ?? "URL is nil")
                            showSafari = true
                        }
                       
                    }
                    .foregroundStyle(Color.white)
                    .sheet(isPresented: $showSafari, content: {
                        SafariView(url: authorizationURL, onDismiss: {
                            //TODO: Make this work
                            print("Safarai view dismissed")
                        })
                    })
                } else {
                    Text(lastFM.username)
                }
            }.frame(width: 375, height: 60)
            
            Spacer()
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: (() -> Void)

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        let viewController = SFSafariViewController(url: url, configuration: config)
        return viewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView

        init(_ parent: SafariView) {
            self.parent = parent
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.onDismiss()
        }
    }
}
