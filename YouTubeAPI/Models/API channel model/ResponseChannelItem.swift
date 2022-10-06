//
//  ResponseChannelItem.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 06.10.2022.
//

import Foundation

struct ResponseChannelItem: Decodable {
    
    var items: [ChannelModel]?
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([ChannelModel].self, forKey: .items )
    }
}
