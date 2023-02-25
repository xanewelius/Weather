//
//  IconModel.swift
//  weather
//
//  Created by Max Kuzmin on 25.02.2023.
//

import UIKit

struct IconModel {
    func fetchImage(icon: String, id: Int) -> UIImage{
        switch id {
        case 800:
            if icon == "01d" {
                return UIImage(named: "sun") ?? UIImage()
            } else {
                return UIImage(named: "moon") ?? UIImage()
            }
        case 200...232:
            return UIImage(named: "thunderstorm") ?? UIImage()
        case 300...504:
            return UIImage(named: "rain") ?? UIImage()
        case 511...622:
            return UIImage(named: "snow") ?? UIImage()
        case 701...781:
            return UIImage(named: "fog") ?? UIImage()
        default:
            return UIImage(named: "cloud") ?? UIImage()
        }
    }
}
