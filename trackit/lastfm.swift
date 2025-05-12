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
    
    func loadToken() async throws {
        let url = URL(string: "https://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=\(self.apiKey)&cb=trackit:callback&format=json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
        
        self.apiToken = wrapper.token
    }
    
    func getAuthUrl() -> URL {
        return URL(string: "https://last.fm/api/auth?api_key=\(self.apiKey)&token=\(self.apiToken)")!
    }
    
}
