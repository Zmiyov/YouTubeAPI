//
//  PlaylistModel.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 05.10.2022.
//

import Foundation

class PlaylistDecoderModel {
    
    func getVideos() {
        
        let url = URL(string: Constants.apiListUrl)
        guard url != nil else { return }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { data, response, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let response = try decoder.decode(ResponsePlaylististItem.self, from: data!)
                print(response)
            } catch {
                print(error)
            }
        }
        dataTask.resume()
    }
}
