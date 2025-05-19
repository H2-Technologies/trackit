//
//  SongView.swift
//  trackit
//
//  Created by Samuel Valencia on 5/19/25.
//

import SwiftUI

struct SongView: View {
    private var song: Song
    
    init(song: Song) {
        self.song = song
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.13, blue: 0.13)
            VStack(alignment: .leading) {
                Text(song.title).font(.headline).multilineTextAlignment(.trailing)
                HStack {
                    Text("\(song.artist) - \(song.album)")
                }.font(.caption)
                HStack {
                    Circle().fill(Color.gray).frame(width: 10, height: 10)
                    Text(RelativeDateTimeFormatter().localizedString(for: song.timestamp, relativeTo: Date())).font(.caption).foregroundStyle(Color.gray)
                    //Image(systemName: isFavorite ? "star.filled" : "star").frame(width: 5, height: 5).padding(.trailing, 5)
                }
            }
        }
        .frame(width: 375, height: 100)
        .cornerRadius(20)
    }
}
