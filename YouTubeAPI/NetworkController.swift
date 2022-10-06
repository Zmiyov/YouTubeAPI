//
//  NetworkController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation
import UIKit

class NetworkController {
    
    enum VideoItemError: Error, LocalizedError {
        case playlistItemNotFound
        case videoItemNotFound
        case channelItemNotFound
        case imageNotFound
    }
    
    func getPlaylistVideos(playlistId: String) async throws -> ResponsePlaylististItem {
        
        let apiListUrl = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=10&playlistId=\(playlistId)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiListUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VideoItemError.playlistItemNotFound
        }
        
        let decoder = JSONDecoder()
        let playlistResponse = try decoder.decode(ResponsePlaylististItem.self, from: data)
        return playlistResponse
    }
    
    func getViewCountVideos(videoId: String) async throws -> String {
        
        let apiVideoUrl = "https://youtube.googleapis.com/youtube/v3/videos?part=statistics&id=\(videoId)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiVideoUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VideoItemError.videoItemNotFound
        }
        
        let decoder = JSONDecoder()
        let videoResponse = try decoder.decode(ResponseVideoItem.self, from: data)
        return videoResponse.items![0].viewCount
    }
    
    func getChannels(channelName: String) async throws -> ChannelModel {
        
        let apiChannelUrl = "https://youtube.googleapis.com/youtube/v3/channels?part=snippet&part=statistics&forUsername=\(channelName)&key=\(Constants.apiKey)"
        
        let urlComponents = URLComponents(string: apiChannelUrl)!
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VideoItemError.channelItemNotFound
        }
        
        let decoder = JSONDecoder()
        let channelResponse = try decoder.decode(ResponseChannelItem.self, from: data)
        
        return channelResponse.items![0] 
    }
    
    func fetchImage(url: String) async throws -> UIImage {
        
        let urlComponents = URLComponents(string: url)!
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VideoItemError.imageNotFound
        }
        
        guard let image = UIImage(data: data) else {
            throw VideoItemError.imageNotFound
        }
        
        return image
    }
}
