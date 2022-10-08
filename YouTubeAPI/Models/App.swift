//
//  App.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 04.10.2022.
//

import UIKit

struct App: Hashable {
    
    let promotedHeadline: String?
    
    let title: String
    let viewCount: String
    let price: Double?
    var formattedPrice: String {
        if let price = price {
            guard let localCurrencyCode = Locale.autoupdatingCurrent.currencyCode else {
                return String(price)
            }
            return price.formatted(.currency(code: localCurrencyCode))
        } else {
            return "GET"
        }
    }
    
    let color = UIColor.random
}


