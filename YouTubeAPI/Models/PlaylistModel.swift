//
//  PlaylistModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation

class PlaylistModel {
    
    func getVideos() {
        
        let url = URL(string: Constants.apiUrl)
        guard url != nil else { return }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { data, response, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let response = try decoder.decode(ResponseItem.self, from: data!)
                print(response)
            } catch {
                print(error)
            }
        }
        dataTask.resume()
    }
}
