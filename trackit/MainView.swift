//
//  MainView.swift
//  trackit
//
//  Created by Samuel Valencia on 5/2/25.
//

import SwiftUI
import MediaPlayer
import ScrobbleKit

struct MainView: View {
    @State private var songs: [Song] = []
    @State private var toScrobble: [SBKTrackToScrobble] = []
    @State private var songTitle: String = ""
    @State private var songArtist: String = ""
    @State private var songAlbum: String = ""
    @State private var isScrobbled: Bool = false
    @State private var songProgress: TimeInterval = 0.0
    @State private var songArtwork: UIImage = UIImage()
    
    private let songDataTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init() {
        updatePlaybackInfo()
    }
    
    var body: some View {
        VStack {
            //Now Playing Track
            ZStack {
                HStack {
                    Image(uiImage: songArtwork).resizable().frame(width: 100, height: 100)
                    VStack(alignment: .trailing) {
                        Text(songTitle).font(.headline)
                        HStack {
                            Text(songArtist).font(.caption)
                        }
                    }
                }
            }
            .padding(.bottom)
            
            Divider() //* Temporary
            
            //Tracks not scrobbled
            ForEach(toScrobble) { song in
                HStack {
                    Image("")
                    VStack {
                        
                    }
                }
            }
            
            Divider()  //* Temporary
            
            //Previously played songs scrobbled
            ForEach(songs) { song in
                HStack {
                    Image(uiImage: song.artwork).resizable().frame(width: 100, height: 100)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(song.title).font(.headline)
                        HStack {
                            Text(song.artist).font(.caption)
                        }
                    }
                }.padding(.bottom)
            }
        }.onReceive(songDataTimer) { _ in
            updatePlaybackInfo()
        }
    }
    
    func updatePlaybackInfo() {
        let systemMP = MPMusicPlayerController.systemMusicPlayer
        if systemMP.playbackState == .playing {
            if let nowPlayingItem = systemMP.nowPlayingItem {
                if (nowPlayingItem.title != songTitle) {
                    isScrobbled = false
                    print("New track is playing, reset scrobble status")
                    
                    //TODO: Remove - This line just tests the previous songs segment. Songs should only display there if they are scrobbled
                    songs.append(Song(title: songTitle, artist: songArtist, album: songAlbum, artwork: songArtwork))
                } else if (systemMP.currentPlaybackTime < songProgress && systemMP.currentPlaybackTime < 1) {
                    isScrobbled = false
                    print("Track Restarted, reset status")
                }
                
                songTitle = nowPlayingItem.title ?? "Unknown Track"
                songArtist = nowPlayingItem.artist ?? "Unknown Artist"
                songAlbum = nowPlayingItem.albumTitle ?? "Unknown Artist"
                
                songProgress = systemMP.currentPlaybackTime
                
                if let artwork = nowPlayingItem.artwork  {
                    if artwork.image != nil {
                        songArtwork = artwork.image(at: CGSize(width: 1024, height: 1024)) ?? UIImage()
                   }
                }
                
            }
        }
    }
    
}



class Song {
    var artist: String
    var title: String
    var album: String
    var scrobbled: Bool
    var artwork: UIImage
    
    init() {
        artist = ""
        title = ""
        album = ""
        scrobbled = false
        artwork = UIImage()
    }
    
    init(title: String, artist: String, album: String, artwork: UIImage) {
        self.artist = artist
        self.title = title
        self.album = album
        scrobbled = false
        self.artwork = artwork
    }
    
    init(scrobble: SBKTrackToScrobble) {
        artist = scrobble.artist
        title = scrobble.track
        album = scrobble.album!
        scrobbled = false
        self.artwork = UIImage()
    }
}

extension Song : Identifiable {
    public var id: String {
        self.artist + self.title + DateFormatter().string(from: Date.now)
    }
}

extension SBKTrackToScrobble : Identifiable {
    public var id: String {
        self.artist + self.track + DateFormatter().string(from: Date.now)
    }
}
