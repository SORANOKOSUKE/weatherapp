//
//  WeatherViewModel.swift
//  weather
//
//  Created by dit-user on 2024/05/14.
//

import Foundation
import Combine


class WeatherViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var weatherSubscriber = WeatherSubscriber()

    var weatherDataSource = WeatherTableDataSource()

    func fetchWeatherData(forLatitude lat: Double, longitude lon: Double) {
        let url: String = getURL(latitude: lat, longitude: lon)
        weatherSubscriber.subjectTask(urlString: url)
            .sink(receiveCompletion: { completion in

            }, receiveValue: { data in
                self.weatherDataSource.update(with: data)
            })
            .store(in: &cancellables)
    }
}
