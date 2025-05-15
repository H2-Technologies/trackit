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
    @State private var sessionUsername: String = ""
    @State private var authError: String?
    
    private var customGray = Color(red: 38 / 255, green: 38 / 255, blue: 48 / 255)
    
    var body: some View {
        VStack {
            //TODO: Convert to just a Button
            if (sessionUsername == "") {
                Button("Sign In") {
                    showSafari = true
                }
                .frame(width: 375, height: 60)
                .background(.orange)
                .foregroundStyle(.white)
                .sheet(isPresented: $showSafari, onDismiss: {}, content: {
                    SafariView(url: lastFM.getAuthUrl())
                })
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .font(.headline)
            } else {
                ZStack {
                    HStack {
                        Text(sessionUsername)
                            .font(.headline)
                            .frame(width: 200)
                        
                        //Add for style
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(.black)
                        
                        Button("Log Out") {
                            KeychainInterface.clearInfo()
                            sessionUsername = ""
                        }
                        .font(.headline)
                        .padding(.leading)
                    }
                    .frame(width: 375, height: 60)
                    .background(customGray)
                    .foregroundStyle(.orange)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 375, height: 60)
            }
            
            /*
            Text("Extras").font(.caption).padding()
            
            Button("Rate App") {}
            Button("Contact Developer") {}
             
             */
            
            Spacer()
        }
        .onOpenURL(perform: { url in
            showSafari = false
            Task {
                sessionUsername = try await lastFM.initManager(token: String(url.absoluteString.split(separator: "=")[1]))
            }
        })
        .onAppear(perform: {
            let initResult = lastFM.initManager()
            if initResult == nil {
                sessionUsername = ""
            } else {
                sessionUsername = initResult!
            }
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
