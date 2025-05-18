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
        artist = scrobble.artist
        title = scrobble.track
        album = scrobble.album!
        timestamp = scrobble.timestamp
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
    @State private var songTitle: String = ""
    @State private var songArtist: String = ""
    @State private var songAlbum: String = ""
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
            if songTitle != "" {
                ZStack {
                    Color(red: 0.13, green: 0.13, blue: 0.13)
                    VStack(alignment: .leading) {
                        Text(songTitle).font(.headline).multilineTextAlignment(.trailing)
                        HStack {
                            Text("\(songArtist) - \(songAlbum)")
                        }.font(.caption)
                        HStack {
                            Circle().fill(Color.gray).frame(width: 10, height: 10)
                            Text("Now Playing").font(.caption).foregroundStyle(Color.gray)
                            //Image(systemName: isFavorite ? "star.filled" : "star").frame(width: 5, height: 5).padding(.trailing, 5)
                        }
                    }
                }
                .frame(width: 375, height: 100)
                .cornerRadius(20)
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
                ZStack {
                    Color(red: 0.13, green: 0.13, blue: 0.13)
                    VStack(alignment: .leading) {
                        Text(song.title).font(.headline).multilineTextAlignment(.trailing)
                        HStack {
                            Text("\(song.artist) - \(song.album)")
                        }.font(.caption)
                        HStack {
                            Circle().fill(
                                song.scrobbled == .done ? Color.green : song.scrobbled == .pending ? Color.yellow : song.scrobbled == .failed ? Color.red : Color.gray
                            ).frame(width: 10, height: 10)
                            Text(RelativeDateTimeFormatter().localizedString(for: song.timestamp, relativeTo: Date())).font(.caption).foregroundStyle(Color.gray)
                            //Image(systemName: isFavorite ? "star.filled" : "star").frame(width: 5, height: 5).padding(.trailing, 5)
                            
                        }
                    }
                }
                .frame(width: 375, height: 100)
                .cornerRadius(20)
                
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
        let systemMP = MPMusicPlayerController.systemMusicPlayer
        if systemMP.playbackState == .playing {
            if let nowPlayingItem = systemMP.nowPlayingItem {
                if (nowPlayingItem.title == nil) {
                    return
                } else {
                    
                }
                
                songTitle = nowPlayingItem.title!
                songArtist = nowPlayingItem.artist!
                songAlbum = nowPlayingItem.albumTitle!
                
                //checkIfTrackIsLoved()
                
                lastfm.updateNowPlaying(song: nowPlayingItem)
            }
        }
    }
    
}
