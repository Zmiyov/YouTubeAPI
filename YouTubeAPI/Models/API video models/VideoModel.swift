//
//  VideoItemModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation

struct VideoModel: Decodable {
    
    var videoId = ""
    var viewCount = ""
    
    enum CodingKeys: String, CodingKey {
        
        case statistics
        
        case videoId = "id"
        case viewCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.videoId = try container.decode(String.self, forKey: .videoId)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        self.viewCount = try snippetContainer.decode(String.self, forKey: .viewCount)
    }
}
