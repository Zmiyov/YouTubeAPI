//
//  ChannelModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 06.10.2022.
//

import Foundation

struct ChannelModel: Decodable, Hashable {
   
    var allVideoUploadsPlaylistId: String?
    var subscriberCount: String?
    
    enum CodingKeys: String, CodingKey {
        
        case contentDetails
        case relatedPlaylists
        case statistics
        
        case allVideoUploadsPlaylistId = "uploads"
        case subscriberCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let contentDetailsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .contentDetails)
        let relatedPlaylistsContainer = try contentDetailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .relatedPlaylists)
        self.allVideoUploadsPlaylistId = try relatedPlaylistsContainer.decode(String.self, forKey: .allVideoUploadsPlaylistId)
        
        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        self.subscriberCount = try statisticsContainer.decode(String.self, forKey: .subscriberCount)
    }
}
