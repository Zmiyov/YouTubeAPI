//
//  VideoItemModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation

struct VideoModel: Decodable {
    
    var title: String?
    var videoId: String?
    var viewCount: String?
    
    enum CodingKeys: String, CodingKey {
        
        case snippet
        case statistics
        
        case videoId = "id"
        case title
        case viewCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.videoId = try container.decode(String.self, forKey: .videoId)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        
        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
        self.viewCount = try statisticsContainer.decode(String.self, forKey: .viewCount)
    }
}
