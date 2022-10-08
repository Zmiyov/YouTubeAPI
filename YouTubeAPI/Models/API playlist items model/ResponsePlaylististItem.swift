//
//  ResponseItem.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation

struct ResponsePlaylististItem: Decodable {
    
    var items: [PlaylistItemsVideoModel]?
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([PlaylistItemsVideoModel].self, forKey: .items )
    }
}
