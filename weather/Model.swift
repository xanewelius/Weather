//
//  Model.swift
//  weather
//
//  Created by Max Kuzmin on 24.02.2023.
//

import Foundation

struct ResponseBody: Codable {
   
    var list: [ListResponse]
    var city: CityResponse
    
    struct ListResponse: Codable {
        var dt: Double
        var weather: [WeatherResponse]
        var main: MainResponse
    }

    struct WeatherResponse: Codable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }

    struct MainResponse: Codable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }
    
    struct CityResponse: Codable {
        var name: String
        var coord: CoordResponse
        var country: String
    }
    
    struct CoordResponse: Codable {
        var lat: Double
        var lon: Double
    }
}
