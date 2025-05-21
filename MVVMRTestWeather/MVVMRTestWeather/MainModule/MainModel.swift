//
//  MainModel.swift
//  MVVMRTestWeather
//
//  Created by Егор Ершов on 21.05.2025.
//

struct WeatherData: Decodable {
    let location: LocationItem
    let forecast: Forecast
}

struct LocationItem: Decodable {
    let name: String
    let country: String
}

struct Forecast: Decodable {
    let forecast: [ForecastItem]
    
    enum CodingKeys: String, CodingKey {
        case forecast = "forecastday"
    }
}

struct ForecastItem: Decodable {
    let date: String
    let day: DayItem
}

struct DayItem: Decodable {
    let temp: Double
    let wind: Double
    let humidity: Int
    let condition: ConditionItem
    
    enum CodingKeys: String, CodingKey {
        case temp = "avgtemp_c"
        case wind = "maxwind_kph"
        case humidity = "avghumidity"
        case condition
    }
}

struct ConditionItem: Decodable {
    let text: String
    let icon: String
}
