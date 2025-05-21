//
//  MainViewModel.swift
//  MVVMRTestWeather
//
//  Created by Егор Ершов on 21.05.2025.
//

import UIKit
import Combine

protocol iMainViewModel {
    func getSubject() -> PassthroughSubject<WeatherData, Error>
    func getWeather(in city: String)
}

final class MainViewModel: iMainViewModel {
    
    private var weatherService: iNetworkService
    private var cancellables = Set<AnyCancellable>()
    private let subject = PassthroughSubject<WeatherData, Error>()
    
    init(weatherService: iNetworkService) {
        self.weatherService = weatherService
        
        self.weatherService.getRelayForecast().sink(receiveCompletion: { [weak self] error in
            self?.subject.send(completion: error)
        }, receiveValue: { [weak self] value in
            self?.subject.send(value)
        }).store(in: &cancellables)
    }
    
    func getSubject() -> PassthroughSubject<WeatherData, Error> {
        self.subject
    }
    
    func getWeather(in city: String) {
        self.weatherService.fetchForecast(for: city)
    }
    
}
