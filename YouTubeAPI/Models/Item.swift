//
//  Item.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import Foundation

enum Item: Hashable {
    case channel(ChannelModel)
    case playlist(PlaylistItemsVideoModel)
    case app(App)
    
    var app: App? {
        if case .app(let app) = self {
            return app
        } else {
            return nil
        }
    }
    
    static let promotedApps: [Item] = [
        .app(App(promotedHeadline: "Now Trending", title: "Playlist Title", viewCount: "Count")),
    ]
    
    static let landscapePlaylist: [Item] = [
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1")),
        .app(App(promotedHeadline: nil, title: "Playlist Title1", viewCount: "Count1"))
    ]
    
    static let squarePlaylist: [Item] = [
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2")),
        .app(App(promotedHeadline: nil, title: "Playlist Title2", viewCount: "Count2"))
    ]
}


