//
//  ChannelModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 06.10.2022.
//

import Foundation

struct ChannelModel: Decodable, Hashable {
   
    var uploads: String?
    var subscriberCount: String?
    
    enum CodingKeys: String, CodingKey {
        
        case contentDetails
        case relatedPlaylists
        case statistics
        
        case uploads
        case subscriberCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let contentDetailsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .contentDetails)
        let relatedPlaylistsContainer = try contentDetailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .relatedPlaylists)
        self.uploads = try relatedPlaylistsContainer.decode(String.self, forKey: .uploads)
        
        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        self.subscriberCount = try statisticsContainer.decode(String.self, forKey: .subscriberCount)
    }
}
