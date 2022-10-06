//
//  ChannelModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 06.10.2022.
//

import Foundation

struct ChannelModel: Decodable, Hashable {
   
    var thumbnail: String?
    var title: String?
    var viewCount: String?
    
    enum CodingKeys: String, CodingKey {
        
        case snippet
        case thumbnails
        case high
        case statistics
        
        case thumbnail = "url"
        case title
        case viewCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnail = try highContainer.decode(String.self, forKey: .thumbnail)
        
        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        self.viewCount = try statisticsContainer.decode(String.self, forKey: .viewCount)
    }
}
