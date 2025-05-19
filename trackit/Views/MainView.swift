//
//  MainView.swift
//  trackit
//
//  Created by Samuel Valencia on 5/2/25.
//

import SwiftUI
import MusicKit
import MediaPlayer
import ScrobbleKit
import Foundation

enum ScrobbleStatus {
    case done, pending, failed, noAttempt
}

class Song: Identifiable, Equatable {
    var artist: String = ""
    var title: String = ""
    var album: String = ""
    var scrobbled: ScrobbleStatus = .noAttempt
    var timestamp: Date = Date()
    var favorite: Bool = false
    public var id: String = UUID().uuidString
    
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
}


struct MainView: View {
    @EnvironmentObject var lastfm: LastFM
    
    @State private var songs: [Song] = []
    @State private var nowPlaying: Song?
    @State private var isScrobbled: ScrobbleStatus = .noAttempt
    //@State private var songArtwork: UIImage = UIImage()
    @State private var isFavorite: Bool = false
    
    //TODO: Optimize for battery
    private let songDataTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init() {
        
    }
    
    
    var body: some View {
        ScrollView {
            //Now Playing Track
            if nowPlaying != nil {
                SongView(song: nowPlaying!)
            } else if songs.count == 0 {
                ZStack {
                    Spacer().containerRelativeFrame([.horizontal, .vertical])
                    VStack {
                        Text("No songs played yet").foregroundStyle(Color.gray)
                    }
                }
            }
            
            //Tracks not scrobbled
            ForEach(songs) { song in
                SongView(song: song)
            }
        }.onReceive(songDataTimer) { _ in
            guard lastfm.isInitialized else {
                print("not initialized")
                return
            }
            updatePlaybackInfo()
        }.onAppear() {
            _ = lastfm.initManager()
            guard lastfm.isInitialized else {
                print("not initialized")
                return
            }
            updatePlaybackInfo()
        }
    }
    
    
    func updatePlaybackInfo() {
        print("Updating playback info")
        
        let systemMP = MPMusicPlayerController.systemMusicPlayer
        if systemMP.playbackState == .playing {
            if let nowPlayingItem = systemMP.nowPlayingItem {
                if (nowPlayingItem.title == nil) {
                    return
                }
                
                //TODO: REMOVE THIS IS DEBUG
                if nowPlaying != nil && nowPlayingItem.title != nowPlaying!.title {
                    songs.insert(nowPlaying!, at: 0)
                }
                
                nowPlaying = Song(nowPlaying: nowPlayingItem)
                
                //checkIfTrackIsLoved()
                
                lastfm.updateNowPlaying(song: nowPlayingItem)
            }
        }
    }
    
}
