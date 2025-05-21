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
    @State private var lastKnownMPMediaItemPersistentID: MPMediaEntityPersistentID?
    @State private var internalCurrentPlaybackTime: TimeInterval = 0.0
    @State private var internalCurrnetPlaybackDuration: TimeInterval = 0.0
    
    //@State private var songArtwork: UIImage = UIImage()
    @State private var isFavorite: Bool = false
    @State var playbackPercentage: Double = 0.0;
    
    //TODO: Optimize for battery
    private let songDataTimer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        ScrollView {
            //Now Playing Track
            if nowPlaying != nil {
                SongView(song: nowPlaying!)
            } else if songs.isEmpty {
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
        guard systemMP.playbackState == .playing,
              let nowPlayingItem = systemMP.nowPlayingItem,
              nowPlayingItem.title != nil else {
            return //Not playing or invalid track
        }
        
        let currentPlaybackTime = systemMP.currentPlaybackTime
        let playbackDuration = nowPlayingItem.playbackDuration
        
        let newPlaybackProgress = currentPlaybackTime / playbackDuration
        
        let isNewSong = nowPlaying == nil || nowPlayingItem.title != nowPlaying!.title
        let hasTrackRestarted = newPlaybackProgress < playbackPercentage && nowPlaying != nil && nowPlayingItem.title == nowPlaying!.title
        
        if isNewSong || hasTrackRestarted {
            if let previouslyPlayingSong = nowPlaying {
                if playbackPercentage >= 0.5 {
                    previouslyPlayingSong.scrobbled = .pending
                    
                    if !songs.contains(where: { $0.id == previouslyPlayingSong.id }) {
                        songs.insert(previouslyPlayingSong, at: 0)
                    }
                }
            }
            nowPlaying = Song(nowPlaying: nowPlayingItem)
        }
        
        playbackPercentage = newPlaybackProgress
        
        scrobble()
        
        lastfm.updateNowPlaying(song: nowPlayingItem)
        
        
    }
    
    func processEligibleSong(song: Song) {
        
    }
    
    func scrobble() {
        let toScrobble = songs.filter({ $0.scrobbled == .pending || $0.scrobbled == .failed })
        
        guard !toScrobble.isEmpty else { return } //Nothing to scrobble
        
        //TODO: Implement chunking, keeping it simple for now
        
        Task {
            let result = try await lastfm.scrobbleTracks(songs: toScrobble)
            
            await MainActor.run {
                if result {
                    print("Successfully updated")
                    for songInArray in songs {
                        if toScrobble.contains(where: { $0.id == songInArray.id }) {
                            songInArray.scrobbled = .done
                        }
                    }
                } else {
                    print("Scrobble failed")
                    for songInArray in songs {
                        if toScrobble.contains(where: { $0.id == songInArray.id }) {
                            songInArray.scrobbled = .failed
                        }
                    }
                }
            }
        }
    }
}
