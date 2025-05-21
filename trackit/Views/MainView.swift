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
    
    var body: some View {
        ScrollView {
            //Now Playing Track
            if nowPlaying != nil {
                SongView(song: nowPlaying!)
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
            ForEach(songs) { song in
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
                
                nowPlaying = Song(nowPlaying: nowPlayingItem)
                
                //checkIfTrackIsLoved()
                
                lastfm.updateNowPlaying(song: nowPlayingItem)
            }
        }
    }
    
    func shouldScrobble() {
        if playback >= 0.5 {
            var song = nowPlaying!
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
                
                await MainActor.run {
                    if result == true {
                        print("track scrobbled")
                        songs = songs.map { songInArray in
                            if toScrobble.contains(where: { $0.id == songInArray.id }) {
                                var modifiedSong = songInArray
                                modifiedSong.scrobbled = .done
                                return modifiedSong
                            } else {
                                return songInArray
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
}
