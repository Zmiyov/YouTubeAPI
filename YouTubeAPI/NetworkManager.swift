//
//  NetworkManager.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation
import UIKit
import SwiftyJSON

class NetworkManager {
    
    enum YouTubeItemError: Error, LocalizedError {
        case playlistItemNotFound
        case videoItemNotFound
        case channelItemNotFound
        case imageNotFound
        case searchError
    }
    
    func getPlaylistTitle(playlistId: String) async throws -> String  {
        
        let apiVideoUrl = "https://youtube.googleapis.com/youtube/v3/playlists?part=snippet&id=\(playlistId)&maxResults=10&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiVideoUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw YouTubeItemError.videoItemNotFound
        }
        
//        let json = try JSON(data: data)
//        print(json)
        
        let decoder = JSONDecoder()
        let playlistResponse = try decoder.decode(ResponsePlaylistists.self, from: data)
        return playlistResponse.items![0].playlistTitle!
        
    }
    
    func getPlaylistVideos(playlistId: String) async throws -> ResponsePlaylististItem {
        
        let apiListUrl = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=10&playlistId=\(playlistId)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiListUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw YouTubeItemError.playlistItemNotFound
        }
//        let json = try JSON(data: data)
//        print(json)
        
        let decoder = JSONDecoder()
        let playlistResponse = try decoder.decode(ResponsePlaylististItem.self, from: data)
        return playlistResponse
    }
    
    func getViewCountVideos(videoId: String) async throws -> String {
        
        let apiVideoUrl = "https://youtube.googleapis.com/youtube/v3/videos?part=statistics&part=snippet&id=\(videoId)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiVideoUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw YouTubeItemError.videoItemNotFound
        }
        
//        let json = try JSON(data: data)
//        print(json)
        
        let decoder = JSONDecoder()
        let videoResponse = try decoder.decode(ResponseVideoItem.self, from: data)

        return videoResponse.items![0].viewCount!
    }
    
    func getTitleOfVideo(videoId: String) async throws -> String {
        
        let apiVideoUrl = "https://youtube.googleapis.com/youtube/v3/videos?part=statistics&part=snippet&id=\(videoId)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiVideoUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw YouTubeItemError.videoItemNotFound
        }
        
//        let json = try JSON(data: data)
//        print(json)
        
        let decoder = JSONDecoder()
        let videoResponse = try decoder.decode(ResponseVideoItem.self, from: data)

        return videoResponse.items![0].title!
    }
    
    func getChannels(channelId: String) async throws -> ChannelModel {
        
        let apiChannelUrl = "https://youtube.googleapis.com/youtube/v3/channels?part=contentDetails&part=statistics&id=\(channelId)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiChannelUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw YouTubeItemError.channelItemNotFound
        }
        
//        let json = try JSON(data: data)
//        print(json)
        
        let decoder = JSONDecoder()
        let channelResponse = try decoder.decode(ResponseChannelItem.self, from: data)
        
        return channelResponse.items![0] 
    }
    
    func getSearchResponse(query: String) async throws -> ResponseSearchItem {
        
        let apiSearchUrl = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&maxResults=4&q=\(query)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiSearchUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw YouTubeItemError.searchError
        }
        
//        let json = try JSON(data: data)
//        print(json)
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(ResponseSearchItem.self, from: data)
        
        return searchResponse
        
    }
    
    func fetchImage(url: String) async throws -> UIImage {
        
        let urlComponents = URLComponents(string: url)!
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw YouTubeItemError.imageNotFound
        }
        
        guard let image = UIImage(data: data) else {
            throw YouTubeItemError.imageNotFound
        }
        
        return image
    }
}
