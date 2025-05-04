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
                    HStack {
                        Image(uiImage: songArtwork).resizable().frame(width: 75, height: 75).cornerRadius(10)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(songTitle).font(.headline).multilineTextAlignment(.trailing)
                            HStack {
                                Text(songArtist)
                                Text("-")
                                Text(songAlbum)
                            }.font(.caption)
                            HStack {
                                //Image(systemName: isFavorite ? "star.filled" : "star").frame(width: 5, height: 5).padding(.trailing, 5)
                                Circle().fill(Color.gray).frame(width: 20, height: 20)
                            }
                        }
                    }.padding(.horizontal)
                }
                .frame(width: 375, height: 100)
                .cornerRadius(20)
            }
            
            
            //Tracks not scrobbled
            ForEach(songs.reversed()) { song in
                ZStack {
                    Color(red: 0.13, green: 0.13, blue: 0.13)
                    HStack {
                        Image(uiImage: song.artwork).resizable().frame(width: 75, height: 75).cornerRadius(10)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(song.title).font(.headline).multilineTextAlignment(.trailing)
                            HStack {
                                Text(song.artist)
                                Text("-")
                                Text(song.album)
                            }.font(.caption)
                            HStack {
                                //Image(systemName: isFavorite ? "star.filled" : "star").frame(width: 5, height: 5).padding(.trailing, 5)
                                Circle().fill(song.scrobbled ? Color.green : Color.yellow).frame(width: 20, height: 20)
                            }
                        }
                    }.padding(.horizontal)
                }
                .frame(width: 375, height: 100)
                .cornerRadius(20)
                
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
                    if songTitle != "" {
                        songs.append(Song(
                            title: songTitle,
                            artist: songArtist,
                            album: songAlbum,
                            artwork: songArtwork,
                            timestamp: Date(),
                            favorite: isFavorite
                        ))
                    }
                    
                } else if (systemMP.currentPlaybackTime < songProgress && systemMP.currentPlaybackTime < 1) {
                    checkScrobbleStatus()
                    isScrobbled = false
                    print("Track Restarted, reset status")
                    
                }
                
                songTitle = nowPlayingItem.title ?? "Unknown Track"
                songArtist = nowPlayingItem.artist ?? "Unknown Artist"
                songAlbum = nowPlayingItem.albumTitle ?? "Unknown Artist"
                
                //checkIfTrackIsLoved()
                
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
    
    /*
    func checkIfTrackIsLoved() {
        let query = MusicKit.
    }
    */
    
    func checkScrobbleStatus() {
        if (!isScrobbled && songProgress > (songDuration/2)) {
            print("scrobbling track")
            toScrobble.append(Song(
                title: songTitle,
                artist: songArtist,
                album: songAlbum,
                artwork: songArtwork,
                timestamp: Date(),
                favorite: isFavorite
            ))
            isScrobbled = true
        }
        
        scrobble()
    }
    
    func scrobble() {
        if toScrobble.count < 1 {
            return;
        }
        
        let chunks = chunkArray(array: toScrobble, chunkSize: 50)
        for chunk in chunks {
            //Scrobble tracks
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
    var favorite: Bool
    
    init() {
        artist = ""
        title = ""
        album = ""
        scrobbled = false
        artwork = UIImage()
        timestamp = Date()
        favorite = false
    }
    
    init(title: String, artist: String, album: String, artwork: UIImage, timestamp: Date, favorite: Bool) {
        self.artist = artist
        self.title = title
        self.album = album
        scrobbled = false
        self.artwork = artwork
        self.timestamp = timestamp
        self.favorite = favorite
    }
    
    init(scrobble: SBKTrackToScrobble) {
        artist = scrobble.artist
        title = scrobble.track
        album = scrobble.album!
        scrobbled = false
        artwork = UIImage()
        timestamp = scrobble.timestamp
        favorite = false
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
