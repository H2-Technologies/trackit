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
    public var username: String = ""
    private var apiKey: String = Secrets.API_KEY
    private var apiSecret: String = Secrets.API_SECRET
    private var apiToken: String = ""
    @Published public var manager: SBKManager = SBKManager(apiKey: Secrets.API_KEY, secret: Secrets.API_SECRET)
    
    init() {
        
    }
    
    func initManager() -> String? {
        let (username, token) = KeychainInterface.fetchUserInfo()
        
        if username == nil || token == nil {
            return nil
        } else {
            manager.setSessionKey(token!)
            return username!
        }
    }
    
    func initManager(token: String) async throws -> String {
        apiToken = token
        try await getSession()
        print("lastfm:initManager - \(username)")
        return username
    }
    
    func getSession() async throws {
        let sig = Insecure.MD5.hash(data: "api_key\(apiKey)methodauth.getSessiontoken\(apiToken)\(apiSecret)".data(using: .utf8)!).map {
                String(format: "%02x", $0)
            }.joined()
        
        let url = URL(string: "https://ws.audioscrobbler.com/2.0/?method=auth.getSession&token=\(apiToken)&api_key=\(apiKey)&api_sig=\(sig)&format=json")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let dataStr = try JSONDecoder().decode(SessionResponse.self, from: data)
        
        username = dataStr.session.name
        
        manager.setSessionKey(dataStr.session.key)
        
        KeychainInterface.saveUserInfo(username: username, token: dataStr.session.key)
        
        print("lastfm:getSession - \(username)")
    }
    
    func getAuthUrl() -> URL {
        return URL(string: "https://last.fm/api/auth?api_key=\(self.apiKey)&cb=trackit://callback")!
    }
    
    
    struct SessionResponse: Codable {
        var session: SessionResponseSession
    }
    
    struct SessionResponseSession: Codable {
        var name: String
        var key: String
        var subscriber: Int
    }
}
