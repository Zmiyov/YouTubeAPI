//
//  ResponsePlaylistists.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 09.10.2022.
//

import Foundation

struct ResponsePlaylistists: Decodable {
    
    var items: [PlaylistsModel]?
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([PlaylistsModel].self, forKey: .items )
    }
}
