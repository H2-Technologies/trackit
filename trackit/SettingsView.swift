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

struct SettingsView: View {
    @EnvironmentObject var lastFMSession: Session
    
    @State private var requestToken: String?
    @State private var showSafari = false
    @State private var authorizationURL = URL(string: "https://last.fm/api/auth?api_key=\(API_KEY)&token=\(API_SECRET)")
    @State private var sessionKey: String?
    @State private var sessionusername: String?
    @State private var authError: String?
    
    init() {
        print(authorizationURL?.string ?? "URL is nil")
        print(API_SECRET)
    }
    
    var body: some View {
        VStack {
            ZStack {
                if (lastFMSession.username == "") {
                    Color(Color.orange)
                    Button("Sign In") {
                       showSafari = true
                    }
                    .foregroundStyle(Color.white)
                    .sheet(isPresented: $showSafari, content: {
                        if let url = authorizationURL {
                            SafariView(url: url, onDismiss: {
                                //TODO: Make this work
                                print("Safarai view dismissed")
                                print(url)
                            })
                        }
                    })
                } else {
                    Text(lastFMSession.username)
                }
            }.frame(width: 375, height: 60) //TODO: Round border
            
            Spacer()
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: (() -> Void)?

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
            parent.onDismiss?()
        }
    }
}
