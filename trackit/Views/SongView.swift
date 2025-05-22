//
//  SongView.swift
//  trackit
//
//  Created by Samuel Valencia on 5/19/25.
//

import SwiftUI
import Foundation // Ensure Foundation is imported for Date and TimeInterval

extension Date {
    func seconds(from date: Date) -> TimeInterval {
        return abs(self.timeIntervalSince(date))
    }
}

struct SongView: View {
    @ObservedObject var song: Song
    
    // Add a state variable to trigger periodic updates for the time display
    @State private var now: Date = Date()
    
    private var nowPlaying: Bool = false
    
    // A timer to update the 'now' state variable every second
    private let timer = Timer.publish(every: 60, on: .main, in: .common)
        .autoconnect()
    
    init(_ song: Song) {
        self.song = song
    }
    
    init(_ song: Song, nowPlaying: Bool) {
        self.song = song
        self.nowPlaying = nowPlaying
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.13, blue: 0.13)
            HStack() {
                Image(uiImage: song.artwork!).resizable().frame(width: 75, height: 75, alignment: .leading).cornerRadius(10)
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("\(song.artist) - \(song.album)")
                    }
                    .font(.caption)
                    
                    HStack {
                        Circle()
                            .fill(getScrobbleStatus(status: song.scrobbled))
                            .frame(width: 10, height: 10)
                        // The getTime function now uses the 'now' state variable,
                        // which is updated by the timer.
                        Text(nowPlaying ? "Now Playing" : getTime(input: song.timestamp, currentTime: now))
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        //Image(systemName: isFavorite ? "star.filled" : "star").frame(width: 5, height: 5).padding(.trailing, 5)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 375, height: 100)
        .cornerRadius(20)
        // Add the onReceive modifier to update the 'now' state variable
        .onReceive(timer) { newDate in
            self.now = newDate // Update 'now' every second to trigger re-render
        }
    }
    
    func getScrobbleStatus(status: ScrobbleStatus) -> Color {
        switch status {
            case .noAttempt: return Color.gray
            case .done: return Color.green
            case .pending: return Color.yellow
            case .failed: return Color.red
        }
    }
    
    // Modified getTime function to accept a currentTime parameter
    func getTime(input: Date, currentTime: Date) -> String {
        // Use currentTime instead of Date() directly to ensure reactivity
        if input.seconds(from: currentTime) <= 1.0 {
            return "A Few Moments Ago"
        } else {
            return RelativeDateTimeFormatter().localizedString(for: input, relativeTo: currentTime)
        }
    }
}
