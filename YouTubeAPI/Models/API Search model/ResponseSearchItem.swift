//
//  ResponseSearchItem.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 07.10.2022.
//

import Foundation

import Foundation

struct ResponseSearchItem: Decodable {
    
    var items: [SearchModel]?
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([SearchModel].self, forKey: .items )
    }
}
