//
//  Song.swift
//  trackit
//
//  Created by Samuel Valencia on 5/20/25.
//

import Foundation
import ScrobbleKit
import MediaPlayer

enum ScrobbleStatus: Codable, CaseIterable {
    case done, pending, failed, noAttempt
}

class Song: Identifiable, Equatable, ObservableObject, Hashable {
    var artist: String = ""
    var title: String = ""
    var album: String = ""
    var timestamp: Date = Date()
    var favorite: Bool = false
   
    public var id: String = UUID().uuidString
    
    @Published var scrobbled: ScrobbleStatus = .noAttempt
    
    init(title: String, artist: String, album: String, favorite: Bool) {
        self.artist = artist
        self.title = title
        self.album = album
        self.favorite = favorite
    }
    
    init(scrobble: SBKTrackToScrobble) {
        self.artist = scrobble.artist
        self.title = scrobble.track
        self.album = scrobble.album!
        self.timestamp = scrobble.timestamp
    }
    
    init(nowPlaying: MPMediaItem!) {
        self.artist = nowPlaying.artist!
        self.title = nowPlaying.title!
        self.album = nowPlaying.albumTitle!
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.title == rhs.title &&
               lhs.artist == rhs.artist &&
               lhs.album == rhs.album
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
