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
    case category(StoreCategory)
    
    var app: App? {
        if case .app(let app) = self {
            return app
        } else {
            return nil
        }
    }
    
    var category: StoreCategory? {
        if case .category(let category) = self {
            return category
        } else {
            return nil
        }
    }
    
    static let promotedApps: [Item] = [
        .app(App(promotedHeadline: "Now Trending", title: "Game Title", viewCount: "Game Description", price: 3.99)),
//        .app(App(promotedHeadline: "Limited Time", title: "Game Title", subtitle: "Game Description", price: nil)),
//        .app(App(promotedHeadline: "New Update", title: "Game Title", subtitle: "Game Description", price: nil)),
//        .app(App(promotedHeadline: "Just Released", title: "Game Title", subtitle: "Game Description", price: nil))
    ]
    
    static let landscapePlaylist: [Item] = [
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: nil)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: 2.99)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: nil)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: 9.99)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: nil)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: nil)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: 6.99)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: nil)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: nil)),
        .app(App(promotedHeadline: nil, title: "Game Title1", viewCount: "Game Description", price: nil)),
    ]
    
    static let squarePlaylist: [Item] = [
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 0.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: nil)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 3.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 0.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 4.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 0.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 0.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 0.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 0.99)),
        .app(App(promotedHeadline: nil, title: "Game Title2", viewCount: "Game Description", price: 0.99)),
    ]

}


