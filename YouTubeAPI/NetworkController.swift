//
//  NetworkController.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation

class NetworkController {
    
    enum VideoItemError: Error, LocalizedError {
        case playlistItemNotFound
        case videoItemNotFound
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
}
