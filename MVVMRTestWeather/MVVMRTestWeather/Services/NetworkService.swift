//
//  NetworkService.swift
//  MVVMRTestWeather
//
//  Created by Егор Ершов on 21.05.2025.
//

import Foundation
import Combine

enum NetworkError: CustomStringConvertible, Error {
    case badURL
    case noData
    case parseError
    
    var description: String {
        switch self {
        case .badURL:
            return "Bad URL created!"
        case .noData:
            return "No data received!"
        case .parseError:
            return "Parsing data error!"
        }
    }
}

protocol iNetworkService {
    func getRelayForecast() -> PassthroughSubject<WeatherData, Error>
    func fetchForecast(for city: String)
}

final class NetworkService: iNetworkService {
    
    enum WeatherApi {
        case forecast
        
        var baseUrl: String {
            "https://api.weatherapi.com/v1"
        }
        var endpoints: String {
            switch self {
            case .forecast:
                "/forecast.json"
            }
        }
        var apiKey: String {
            guard let value = ProcessInfo.processInfo.environment["API_KEY"] else { fatalError("No API key secured!") }
            return value
        }
        var days: Int {
            5
        }
    }
    
    private let relayForecast = PassthroughSubject<WeatherData, Error>()
    
    func getRelayForecast() -> PassthroughSubject<WeatherData, Error> {
        self.relayForecast
    }
    
    func createURL(for city: String, with type: WeatherApi, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlString = "\(type.baseUrl)\(type.endpoints)?key=\(type.apiKey)&days=\(type.days)&q=\(city)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        completion(.success(url))
    }
    
    func sendRequest(with url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
    
    func parseData<T: Decodable>(from data: Data, in type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let json = try? JSONDecoder().decode(type, from: data) else {
            completion(.failure(NetworkError.parseError))
            return
        }
        completion(.success(json))
    }
    
    func fetchForecast(for city: String) {
        createURL(for: city, with: .forecast) { [weak self] urlResult in
            switch urlResult {
            case .failure(let error):
                self?.relayForecast.send(completion: .failure(error))
            case .success(let url):
                self?.sendRequest(with: url) { [weak self] requestResult in
                    switch requestResult {
                    case .failure(let error):
                        self?.relayForecast.send(completion: .failure(error))
                    case .success(let data):
                        self?.parseData(from: data, in: WeatherData.self) { [weak self] parseResult in
                            switch parseResult {
                            case .failure(let error):
                                self?.relayForecast.send(completion: .failure(error))
                            case .success(let weatherData):
                                self?.relayForecast.send(weatherData)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
