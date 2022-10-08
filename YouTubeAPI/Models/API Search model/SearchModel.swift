//
//  SearchModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 07.10.2022.
//

import Foundation

struct SearchModel: Decodable, Hashable {
   
    var thumbnail: String?
    var channelTitle: String?
    var channelId: String?
    
    var allVideoUploadsPlaylistId: String?
    var subscriberCount: String?
    
    
    enum CodingKeys: String, CodingKey {
        
        case snippet
        case thumbnails
        case high
        
        case thumbnail = "url"
        case channelTitle
        case channelId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.channelTitle = try snippetContainer.decode(String.self, forKey: .channelTitle)
        self.channelId = try snippetContainer.decode(String.self, forKey: .channelId)
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnail = try highContainer.decode(String.self, forKey: .thumbnail)
        
    }
}
