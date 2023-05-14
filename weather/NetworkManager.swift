//
//  NetworkManager.swift
//  weather
//
//  Created by Max Kuzmin on 25.02.2023.
//

import Foundation
import UIKit

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    let baseURL = "https://api.openweathermap.org/data/2.5/forecast?"
    
    func jsonPars(lat: String, lon: String, compeletionHandler: @escaping (ResponseBody) -> Void) {
        let finalURL = "\(baseURL)lat=\(lat)&lon=\(lon)&appid=55cd0a2d06779ea8b8b447c008f01830&lang=ru" // us
        print(finalURL)
        guard let url = URL(string: finalURL) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error 1:", error)
                return
            }
            guard let data = data else { return }
            var weatherData: ResponseBody?
            do{
                weatherData = try JSONDecoder().decode(ResponseBody.self, from: data)
                guard let weatherData = weatherData else { return }
                compeletionHandler(weatherData)
            }catch {
                print("Error 2:", error)
            }
        }.resume()
    }
}
