//
//  PlaylistsModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 09.10.2022.
//

import Foundation

struct PlaylistsModel: Decodable, Hashable {
    
    var playlistTitle: String?

    enum CodingKeys: String, CodingKey {
        
        case snippet
        case playlistTitle = "title"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.playlistTitle = try snippetContainer.decode(String.self, forKey: .playlistTitle)
    }
}
