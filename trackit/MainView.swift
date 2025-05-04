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
    @State private var toScrobble: [Song] = []
    @State private var songTitle: String = ""
    @State private var songArtist: String = ""
    @State private var songAlbum: String = ""
    @State private var isScrobbled: Bool = false
    @State private var songProgress: TimeInterval = 0.0
    @State private var songArtwork: UIImage = UIImage()
    @State private var songDuration: TimeInterval = 0.0
    
    private let songDataTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init() {
        updatePlaybackInfo()
    }
    
    var body: some View {
        VStack {
            //Now Playing Track
            ZStack {
                Color(red: 0.13, green: 0.13, blue: 0.13)
                HStack {
                    Image(uiImage: songArtwork).resizable().frame(width: 75, height: 75)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(songTitle).font(.headline)
                        HStack {
                            Text(songArtist).font(.caption)
                        }
                    }
                }.padding(.horizontal)
            }
            .frame(width: 350, height: 100)
            .cornerRadius(20)
            
            //Tracks not scrobbled
            ForEach(toScrobble) { song in
                ZStack {
                    Color(red: 0.13, green: 0.13, blue: 0.13)
                    HStack {
                        Image(uiImage: songArtwork).resizable().frame(width: 75, height: 75)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(songTitle).font(.headline)
                            HStack {
                                Text(songArtist).font(.caption)
                            }
                        }
                    }.padding(.horizontal)
                }
                .frame(width: 350, height: 100)
                .cornerRadius(20)
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
                    checkScrobbleStatus()
                    isScrobbled = false
                    print("New track is playing, reset scrobble status")
                } else if (systemMP.currentPlaybackTime < songProgress && systemMP.currentPlaybackTime < 1) {
                    checkScrobbleStatus()
                    isScrobbled = false
                    print("Track Restarted, reset status")
                }
                
                songTitle = nowPlayingItem.title ?? "Unknown Track"
                songArtist = nowPlayingItem.artist ?? "Unknown Artist"
                songAlbum = nowPlayingItem.albumTitle ?? "Unknown Artist"
                
                songProgress = systemMP.currentPlaybackTime
                songDuration = nowPlayingItem.playbackDuration
                
                if let artwork = nowPlayingItem.artwork  {
                    if artwork.image != nil {
                        songArtwork = artwork.image(at: CGSize(width: 1024, height: 1024)) ?? UIImage()
                   }
                }
                
            }
        }
    }
    
    func checkScrobbleStatus() {
        if (!isScrobbled && songProgress > (songDuration/2)) {
            print("scrobbling track")
            toScrobble.append(Song(
                title: songTitle,
                artist: songArtist,
                album: songAlbum,
                artwork: songArtwork,
                timestamp: Date()
                
            ))
            isScrobbled = true
        }
    }
    
    func scrobble() {
        if toScrobble.count < 1 {
            return;
        }
        
        
    }
    
}



class Song {
    var artist: String
    var title: String
    var album: String
    var scrobbled: Bool
    var artwork: UIImage
    var timestamp: Date
    
    init() {
        artist = ""
        title = ""
        album = ""
        scrobbled = false
        artwork = UIImage()
        timestamp = Date()
    }
    
    init(title: String, artist: String, album: String, artwork: UIImage, timestamp: Date) {
        self.artist = artist
        self.title = title
        self.album = album
        scrobbled = false
        self.artwork = artwork
        self.timestamp = timestamp
    }
    
    init(scrobble: SBKTrackToScrobble) {
        artist = scrobble.artist
        title = scrobble.track
        album = scrobble.album!
        scrobbled = false
        self.artwork = UIImage()
        timestamp = scrobble.timestamp
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
