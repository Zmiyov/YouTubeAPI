//
//  Item.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import Foundation

enum Item: Hashable {
    
    case channel(Channel)
    case playlist(PlaylistVideosModel)
    
    var channel: Channel? {
        if case .channel(let channel) = self {
            return channel
        } else {
            return nil
        }
    }
    
    var playlist: PlaylistVideosModel? {
        if case .playlist(let playlist) = self {
            return playlist
        } else {
            return nil
        }
    }
    
    static let promotedApps: [Item] = [
        .channel(Channel(title: "Playlist Title", viewCount: "Count"))
    ]
    
    static let landscapePlaylist: [Item] = [
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1")),
        .playlist(PlaylistVideosModel(title: "Playlist Title1", viewCount: "Count1"))
    ]
    
    static let squarePlaylist: [Item] = [
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2")),
        .playlist(PlaylistVideosModel(title: "Playlist Title2", viewCount: "Count2"))
    ]
}


