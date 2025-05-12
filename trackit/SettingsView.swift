//
//  Settings View.swift
//  trackit
//
//  Created by Samuel Valencia on 5/5/25.
//

import SwiftUI
import SafariServices
import Foundation
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
    
    
    var body: some View {
        VStack {
            //TODO: Convert to just a Button
            if (lastFM.username == "") {
                Button("Sign In") {
                    showSafari = true
                }
                .foregroundStyle(Color.white)
                .backgroundStyle(Color.orange)
                .frame(width: 375, height: 60)
                .sheet(isPresented: $showSafari, onDismiss: {
                    print("Safari view dismissed")
                }, content: {
                    SafariView(url: lastFM.getAuthUrl())
                })
            } else {
                Text(lastFM.username)
            }
        }
        .onOpenURL(perform: { url in
            print(url)
        })
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: (() -> Void)? = nil
    
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
