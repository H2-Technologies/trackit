//
//  SongView.swift
//  trackit
//
//  Created by Samuel Valencia on 5/19/25.
//

import SwiftUI

extension Date {
    func seconds(from date: Date) -> TimeInterval {
        return abs(self.timeIntervalSince(date))
    }
}

struct SongView: View {
    @ObservedObject var song: Song
    
    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.13, blue: 0.13)
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
                    Text(getTime(input: song.timestamp))
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    //Image(systemName: isFavorite ? "star.filled" : "star").frame(width: 5, height: 5).padding(.trailing, 5)
                }
            }
        }
        .frame(width: 375, height: 100)
        .cornerRadius(20)
    }
    
    func getScrobbleStatus(status: ScrobbleStatus) -> Color {
        switch status {
            case .noAttempt: return Color.gray
            case .done: return Color.green
            case .pending: return Color.yellow
            case .failed: return Color.red
        }
    }
    
    func getTime(input: Date) -> String {
        if input.seconds(from: Date()) <= 1.0 {
            return "Now Playing"
        } else {
            return RelativeDateTimeFormatter().localizedString(for: input, relativeTo: Date())
        }
    }
}
