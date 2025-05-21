//
//  MainBuilder.swift
//  MVVMRTestWeather
//
//  Created by Егор Ершов on 21.05.2025.
//

import UIKit

final class MainBuilder {
    
    static func build() -> UIViewController {
        let service: iNetworkService = NetworkService()
        let viewModel = MainViewModel(weatherService: service)
        let viewController = MainViewController(viewModel: viewModel)
        return viewController
    }
    
}
