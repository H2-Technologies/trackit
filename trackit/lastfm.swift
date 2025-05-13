//
//  lastfm.swift
//  trackit
//
//  Created by Samuel Valencia on 5/9/25.
//

import Foundation
import ScrobbleKit

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
        Task {
            try await getUsername()
        }
    }
    
    func getUsername() async throws {
        print("lastfm - Attempting to fetch username")
        let result = try await manager.getInfo(forUser: "")
        print("lastfm - \(result)")
    }
    
    func getAuthUrl() -> URL {
        return URL(string: "https://last.fm/api/auth?api_key=\(self.apiKey)&cb=trackit://callback")!
    }
    
}
