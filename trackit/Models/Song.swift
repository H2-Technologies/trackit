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
    @Published var timestamp: Date = Date() // @Published to allow SongView to react to timestamp changes
    var favorite: Bool = false
    
    public var id: String = UUID().uuidString //Public so it can be accessed without a getter method
    
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
        // IMPORTANT: Set the timestamp here so SongView can correctly identify "Now Playing"
        self.timestamp = Date()
    }
    
    // Adhere to Equatable: Now compares by the unique instance ID
    // This ensures that each distinct playback session (identified by its UUID) is treated as unique.
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Adhere to Hashable: Hash by the unique instance ID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
