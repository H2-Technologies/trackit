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

class Song: Identifiable {
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
}


struct MainView: View {
    @State private var songs: [Song] = []
    @State private var songTitle: String = ""
    @State private var songArtist: String = ""
    @State private var songAlbum: String = ""
    @State private var isScrobbled: ScrobbleStatus = .noAttempt
    @State private var songProgress: TimeInterval = 0.0
    @State private var songArtwork: UIImage = UIImage()
    @State private var songDuration: TimeInterval = 0.0
    @State private var isFavorite: Bool = false
    
    
    private let songDataTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init() {
        updatePlaybackInfo()
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
            updatePlaybackInfo()
        }.onAppear() {
            updatePlaybackInfo()
        }
    }
    
    
    func updatePlaybackInfo() {
        let systemMP = MPMusicPlayerController.systemMusicPlayer
        if systemMP.playbackState == .playing {
            if let nowPlayingItem = systemMP.nowPlayingItem {
                if (nowPlayingItem.title == nil) { return }
                if (nowPlayingItem.title != songTitle) {
                    checkScrobbleStatus()
                    isScrobbled = .noAttempt
                    print("New track is playing, reset scrobble status")
                    
                } else if (systemMP.currentPlaybackTime < songProgress && systemMP.currentPlaybackTime < 1) {
                    checkScrobbleStatus()
                    isScrobbled = .noAttempt
                    print("Track Restarted, reset status")
                    
                }
                
                songTitle = nowPlayingItem.title ?? "Unknown Track"
                songArtist = nowPlayingItem.artist ?? "Unknown Artist"
                songAlbum = nowPlayingItem.albumTitle ?? "Unknown Artist"
                
                //checkIfTrackIsLoved()
                
                songProgress = systemMP.currentPlaybackTime
                songDuration = nowPlayingItem.playbackDuration
                
                
            }
        }
    }
    
    /*
    func checkIfTrackIsLoved() {
        let query = MusicKit.
    }
    */
    
    func checkScrobbleStatus() {
        if (isScrobbled == .noAttempt && songProgress > (songDuration/2)) {
            print("scrobbling track")
            songs.append(Song(
                title: songTitle,
                artist: songArtist,
                album: songAlbum,
                favorite: isFavorite
            ))
            isScrobbled = .pending
        }
        
        scrobble()
    }
    
    func scrobble() {
        var toScrobble: [Song] = []
        for track in songs {
            if track.scrobbled == .pending {
                toScrobble.append(track)
            }
        }
        
        
        if toScrobble.count < 1 {
            return;
        }
        
        let chunks = chunkArray(array: toScrobble, chunkSize: 50)
        for chunk in chunks {
            //TODO: Scrobble tracks
            
            //TODO: If successful
            for track in chunk {
                //TODO: Set track status as .done
                
            }
        }
        
    }
    
}
