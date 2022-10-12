//
//  Alert.swift
//  YouTubeAPI
//
//  Created by Vladimir Pisarenko on 12.10.2022.
//

import Foundation
import UIKit

class Alert {
    static func alert(error: Error, vc: UIViewController) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        vc.present(alert, animated: true, completion: nil)
    }
}
