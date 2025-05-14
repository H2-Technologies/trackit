//
//  lastfm.swift
//  trackit
//
//  Created by Samuel Valencia on 5/9/25.
//

import Foundation
import ScrobbleKit
import CryptoKit

class LastFm : ObservableObject {
    @Published public var username: String = ""
    private var apiKey: String = Secrets.API_KEY
    private var apiSecret: String = Secrets.API_SECRET
    private var apiToken: String = ""
    @Published public var manager: SBKManager = SBKManager(apiKey: Secrets.API_KEY, secret: Secrets.API_SECRET)
    
    init() {
        
    }
    
    func initManager(token: String) {
        print(token)
        manager.setSessionKey(token)
        apiToken = token
        Task {
            try await getSession()
        }
    }
    
    func getSession() async throws {
        let sig = Insecure.MD5.hash(data: "api_key\(apiKey)methodauth.getSessiontoken\(apiToken)\(apiSecret)".data(using: .utf8)!)
        
        print(sig.description.split(separator: ": ")[1])
        
        let url = URL(string: "https://ws.audioscrobbler.com/2.0/?method=auth.getsession&token=\(apiToken)&api_key=\(apiKey)&api_sig=\(sig.description.split(separator: ": ")[1])")!
        
        print(url)
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        print(XMLParser(data: data).parse())
    }
    
    func getAuthUrl() -> URL {
        return URL(string: "https://last.fm/api/auth?api_key=\(self.apiKey)&cb=trackit://callback")!
    }
    
}
