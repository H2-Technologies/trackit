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
    /// Inserts a new element at the beginning of the array.
    /// - Parameter newElement: The element to insert.
    mutating func insertFirst(_ newElement: Element) {
        self.insert(newElement, at: 0)
    }
}

struct MainView: View {
    @EnvironmentObject var lastfm: LastFM
    
    // @State private var songs: [Song] = [] // Stores songs that have become scrobble-eligible (50% played)
    // When Song is a class, the array holds references to Song objects.
    @State private var songs: [Song] = []
    
    // nowPlaying will hold a reference to the current live Song object
    @State private var nowPlaying: Song?
    
    @State private var lastKnownMPMediaItemPersistentID: MPMediaEntityPersistentID?
    // These variables will hold the playback time and duration from the *previous* timer tick.
    // They are crucial for correctly evaluating the song that just finished or restarted.
    @State private var previousTickPlaybackTime: TimeInterval = 0.0
    @State private var previousTickPlaybackDuration: TimeInterval = 0.0
    
    @State var playback: Double = 0.0; // Your original playback percentage variable (derived from current live data)
    
    private let songDataTimer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    init() {}
    
    var body: some View {
        ScrollView {
            // Now Playing Track
            // SongView will observe changes to the 'nowPlaying' object directly
            if let currentNowPlaying = nowPlaying {
                // Pass the current live playback percentage to the SongView
                // as the Song object itself doesn't store this.
                SongView(song: currentNowPlaying)
            } else if songs.isEmpty { // Use .isEmpty for clarity
                ZStack {
                    Spacer()
                        .containerRelativeFrame([.horizontal, .vertical])
                    
                    VStack {
                        Text("No songs played yet")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            
            // Tracks that are eligible for scrobble (50% played or more)
            // ForEach will correctly identify and update only the SongView for the changed Song object
            ForEach(songs) { song in
                // For historical songs in the list, their playback percentage is fixed
                // at the point they became eligible, or can be 0 if not needed.
                SongView(song: song) // Or a stored eligible percentage if you add it to Song
            }
        }
        .onReceive(songDataTimer) { _ in
            guard lastfm.isInitialized else {
                print("LastFM not initialized, skipping playback info update.")
                return
            }
            updatePlaybackInfo()
        }
        .onAppear() {
            _ = lastfm.initManager()
            guard lastfm.isInitialized else {
                print("LastFM not initialized onAppear, cannot update playback info.")
                return
            }
            updatePlaybackInfo()
        }
    }
    
    /// Periodically checks the system music player for current track info and playback state.
    /// Manages `nowPlaying` and triggers eligibility checks for scrobbling.
    func updatePlaybackInfo() {
        let systemMP = MPMusicPlayerController.systemMusicPlayer
        
        // Capture LIVE data from MPMusicPlayerController at the very start of the tick
        let liveNowPlayingItem = systemMP.nowPlayingItem
        let livePlaybackTime = systemMP.currentPlaybackTime
        let livePlaybackDuration = liveNowPlayingItem?.playbackDuration ?? 0.0
        
        let currentMPMediaItemPersistentID = liveNowPlayingItem?.persistentID
        
        // Determine if this is a new song (different persistent ID)
        let isNewSongPlaying = currentMPMediaItemPersistentID != lastKnownMPMediaItemPersistentID
        
        // Determine if the track has restarted (same persistent ID, but time jumped back significantly)
        // This checks if the current live time is significantly less than the previous recorded time
        // for the *same* song. A threshold of 5 seconds is used to avoid minor fluctuations.
        let hasTrackRestarted: Bool
        if let currentID = currentMPMediaItemPersistentID,
           let lastID = lastKnownMPMediaItemPersistentID,
           currentID == lastID { // It's the same song
            hasTrackRestarted = livePlaybackTime < (previousTickPlaybackTime - 5.0) && livePlaybackTime > 0.0
        } else {
            hasTrackRestarted = false
        }
        
        // Handle cases where playback stops or essential info is missing
        guard systemMP.playbackState == .playing,
              let nowPlayingItem = liveNowPlayingItem,
              let title = nowPlayingItem.title, // Ensure title exists
              let artist = nowPlayingItem.artist, // Ensure artist exists
              let album = nowPlayingItem.albumTitle, // Ensure album exists
              nowPlayingItem.playbackDuration > 0 else {
            
            // If no song playing or essential info is missing:
            // 1. Process the song that just ended/stopped (if any) for scrobble eligibility.
            if let endedSong = nowPlaying {
                print("Song ended or stopped: '\(endedSong.title)' (ID: \(endedSong.id))")
                // Use the *last recorded* playback time and duration for the song that just ended.
                processEligibleSong(song: endedSong, playbackTime: previousTickPlaybackTime, playbackDuration: previousTickPlaybackDuration)
            }
            
            // 2. Reset playback state variables.
            nowPlaying = nil // Clear the live playing song
            lastKnownMPMediaItemPersistentID = nil
            previousTickPlaybackTime = 0.0
            previousTickPlaybackDuration = 0.0
            playback = 0.0 // Reset your original playback variable
            print("No song playing or insufficient info detected. State reset.")
            return
        }
        
        // Process song changes or restarts
        if isNewSongPlaying || hasTrackRestarted {
            print("--- (Change Detected: \(isNewSongPlaying ? "New Song" : "Restart")) ---")
            
            // 1. Process the *previous* live song (if any) for scrobble eligibility.
            //    This is crucial to scrobble the song that just finished/changed.
            if let previousLiveSong = nowPlaying {
                print("Processing previous song for scrobble: '\(previousLiveSong.title)' (ID: \(previousLiveSong.id))")
                // Pass the song instance and its *final* playback time/duration from the *previous tick*
                // before the new song started or the restart was detected.
                processEligibleSong(song: previousLiveSong, playbackTime: previousTickPlaybackTime, playbackDuration: previousTickPlaybackDuration)
            }
            
            // 2. Create a NEW `Song` instance for the newly detected live playback.
            //    This new instance gets its own unique UUID, as per your requirement for repeats.
            let newLiveSongInstance = Song(nowPlaying: nowPlayingItem)
            nowPlaying = newLiveSongInstance // Update the live playing song state
            print("LIVE Song updated to: '\(newLiveSongInstance.title)' (ID: \(newLiveSongInstance.id))")
            
            // 3. Update persistent ID to track the new song.
            lastKnownMPMediaItemPersistentID = currentMPMediaItemPersistentID
            
        } else {
            // Same song is still playing, no change or restart detected.
            // `nowPlaying` already holds the correct instance.
            // No need to update `nowPlaying`'s properties as it doesn't store playback time/duration.
            // The `playback` @State variable already handles this.
        }
        
        // Update playback tracking for the *current* live song for the *next* tick.
        // These values represent the state *at the end of this current tick*.
        previousTickPlaybackTime = livePlaybackTime
        previousTickPlaybackDuration = livePlaybackDuration
        playback = livePlaybackTime / (livePlaybackDuration > 0 ? livePlaybackDuration : 1.0) // Update your original playback variable
        
        // Always update LastFM about the currently playing track (for "Now Playing" feature)
        lastfm.updateNowPlaying(song: nowPlayingItem)
    }
    
    /// Decides if a song should be added to the `songs` array (meaning it's eligible for scrobble).
    /// It's called for songs that have just finished, changed, or restarted.
    func processEligibleSong(song: Song, playbackTime: TimeInterval, playbackDuration: TimeInterval) {
        // Guard against zero duration to prevent division by zero
        guard playbackDuration > 0 else { return }
        
        // Check if this exact playback instance (by ID) is already processed or pending in `songs` array.
        // This prevents adding the same instance multiple times.
        if songs.contains(where: { $0.id == song.id && ($0.scrobbled == .done || $0.scrobbled == .pending) }) {
            print("Song '\(song.title)' (ID: \(song.id)) already processed or pending in `songs` array. Skipping.")
            return
        }
        
        // Corrected playbackPercentage calculation
        let playbackPercentage = playbackTime / playbackDuration
        print("Evaluating eligibility for '\(song.title)' (ID: \(song.id)): \(String(format: "%.2f", playbackPercentage * 100))%")
        
        // Last.fm's rule: 50% of track or 4 minutes (240 seconds), whichever comes first.
        if playbackPercentage >= 0.5 || playbackTime >= 240 {
            print("Song '\(song.title)' (ID: \(song.id)) is ELIGIBLE for scrobble! Marking pending and adding to list.")
            
            // Since Song is now a class, 'song' is a reference.
            // We directly modify its properties.
            song.scrobbled = .pending // Mark as pending
            song.timestamp = Date() // Update timestamp to when it became eligible
            
            // If the song is already in the array (e.g., it was the nowPlaying song
            // that just finished and is being added to the list),
            // its properties are already updated via the reference.
            // If it's not in the 'songs' array yet, add it.
            if !songs.contains(where: { $0.id == song.id }) {
                songs.insert(song, at: 0) // Add as a new eligible song to the array
            }
            
            scrobble() // Trigger scrobble attempt immediately
        } else {
            print("Song '\(song.title)' (ID: \(song.id)) NOT eligible for scrobble yet (Progress: \(String(format: "%.2f", playbackPercentage * 100))%).")
        }
    }
    
    func scrobble() {
        // Filter for songs in the `songs` array that are pending or failed.
        let toScrobble = songs.filter { song in
            song.scrobbled == .pending || song.scrobbled == .failed
        }
        
        guard !toScrobble.isEmpty else {
            print("No pending/failed tracks to scrobble.")
            return
        }
        
        Task {
            print("Attempting to scrobble \(toScrobble.count) tracks...")
            do {
                let result = try await lastfm.scrobbleTracks(songs: toScrobble)
                
                await MainActor.run {
                    print("Scrobble API result: \(result)")
                    
                    if result == true {
                        print("Track(s) scrobbled successfully. Updating statuses to .done")
                        // Iterate through the songs that were attempted to scrobble
                        // and update their status in the 'songs' array directly.
                        for scrobbledSong in toScrobble {
                            if let index = songs.firstIndex(where: { $0.id == scrobbledSong.id }) {
                                songs[index].scrobbled = .done // Update the specific instance
                                print("    (UI Update) Song '\(songs[index].title)' (ID: \(songs[index].id)) status set to .done")
                            }
                        }
                    } else {
                        print("Scrobble API returned false. Updating statuses to .failed")
                        for failedSong in toScrobble {
                            if let index = songs.firstIndex(where: { $0.id == failedSong.id }) {
                                songs[index].scrobbled = .failed // Update the specific instance
                                print("    (UI Update) Song '\(songs[index].title)' (ID: \(songs[index].id)) status set to .failed")
                            }
                        }
                    }
                    
                    // The `nowPlaying` object's status will automatically reflect changes
                    // if it's the same object that was modified in the loop above,
                    // because `nowPlaying` holds a reference to an `ObservableObject`.
                    // No explicit update to `nowPlaying` is needed here.
                }
            } catch {
                await MainActor.run {
                    print("Error scrobbling tracks: \(error.localizedDescription)")
                    for errorSong in toScrobble {
                        if let index = songs.firstIndex(where: { $0.id == errorSong.id }) {
                            songs[index].scrobbled = .failed // Update the specific instance
                            print("    (UI Update) Song '\(songs[index].title)' (ID: \(songs[index].id)) status set to .failed due to error")
                        }
                    }
                    // Same as above, `nowPlaying` will update automatically if it was affected.
                }
            }
        }
    }
}

// You will need to define your SongView struct.
// It should take @ObservedObject var song: Song
// and potentially a currentPlaybackPercentage for the now playing track.
/*
struct SongView: View {
    @ObservedObject var song: Song
    var currentPlaybackPercentage: Double // Use this for the now playing song's progress bar

    var body: some View {
        VStack(alignment: .leading) {
            Text(song.title)
                .font(.headline)
            Text(song.artist)
                .font(.subheadline)
            Text(song.album)
                .font(.caption)
            Text("Status: \(song.scrobbled.rawValue)")
                .font(.caption2)
                .foregroundColor({
                    switch song.scrobbled {
                    case .pending: return .orange
                    case .done: return .green
                    case .failed: return .red
                    case .noAttempt: return .gray
                    }
                }())

            // Example of a simple progress bar for the now playing song
            if song.id == nowPlaying?.id { // You'd need to pass nowPlaying or its ID for this check
                ProgressView(value: currentPlaybackPercentage)
                    .progressViewStyle(.linear)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
*/
