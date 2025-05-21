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

extension Array {
    mutating func insertFirst(_ element: Element) {
        self.insert(element, at: 0)
    }
}


struct MainView: View {
    @EnvironmentObject var lastfm: LastFM
    
    @State private var songs: [Song] = []
    @State private var nowPlaying: Song?
    @State private var isScrobbled: ScrobbleStatus = .noAttempt
    //@State private var songArtwork: UIImage = UIImage()
    @State private var isFavorite: Bool = false
    @State var playback: Double = 0.0;
    
    //TODO: Optimize for battery
    private let songDataTimer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    init() {
        
    }
    
    
    var body: some View {
        ScrollView {
            //Now Playing Track
            if let currentSong = songs.first {
                SongView(song: currentSong)
            } else if songs.count == 0 {
                ZStack {
                    Spacer()
                        .containerRelativeFrame([.horizontal, .vertical])
                    
                    VStack {
                        Text("No songs played yet")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            
            //Tracks not scrobbled
            ForEach(songs.dropFirst()) { song in
                SongView(song: song)
            }
        }
        .onReceive(songDataTimer) { _ in
            guard lastfm.isInitialized else {
                print("not initialized")
                return
            }
            updatePlaybackInfo()
        }
        .onAppear() {
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
                }
                
                if songs.first == nil {
                    songs.insertFirst(Song(nowPlaying: nowPlayingItem))
                }
                
                //Check if new track is playing
                if nowPlaying != nil && nowPlayingItem.title != nowPlaying!.title {
                    //TODO: REMOVE THIS IS DEBUG
                    print("new song playing")
                    shouldScrobble()
                }
                
                //Check if track has been restarted
                if playback > (systemMP.currentPlaybackTime / nowPlayingItem.playbackDuration) {
                    print("Track restarted")
                    shouldScrobble()
                }
                
                playback = systemMP.currentPlaybackTime / nowPlayingItem.playbackDuration
                
                //checkIfTrackIsLoved()
                
                lastfm.updateNowPlaying(song: nowPlayingItem)
            }
        }
    }
    
    func shouldScrobble() {
        if playback >= 0.5 {
            var song = songs.first!
            song.scrobbled = .pending
            songs.insert(song, at: 0)
        }
        
        scrobble()
    }
    
    func scrobble() {
        let toScrobble = songs.filter({ $0.scrobbled == .pending || $0.scrobbled == .failed })
        if toScrobble.count > 50 {
            //TODO: Chunk array
        } else {
            Task {
                let result = try await lastfm.scrobbleTracks(songs: toScrobble)
                
                print(result)
                
                if result == true {
                    print("track scrobbled")
                    for track in toScrobble {
                        print("updating status")
                        songs = songs.map { song in
                            print("Comparing song \(song.id) to track \(track.id)")
                            if song.id == track.id {
                                var modifiedSong = song
                                modifiedSong.scrobbled = .done
                                return modifiedSong
                            } else {
                                return song
                            }
                        }
                    }
                } else {
                    for song in songs {
                        //song.scrobbled = .failed
                    }
                }
            }
            
        }
    }
}
