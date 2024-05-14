//
//  WeatherSubscriber.swift
//  weather
//
//  Created by dit-user on 2024/05/07.
//

import Foundation
import Combine
import UIKit
import OSLog
import Alamofire

class WeatherManager {
    let logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")

    var cancellables = Set<AnyCancellable>()

    //publisher
    func getLocation(urlstr : String) -> AnyPublisher<WeatherForecast, AFError> {
        AF.request(urlstr)
            .publishDecodable(type: WeatherForecast.self)
            .value()
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }

    func subjectTask(urlString: String) -> Future<[[String]], Error> {
        var tempArray = [[String]]()
        var weatherDescriptions: [String] = []

        let future = Future<[[String]], Error> { promise in
            self.getLocation(urlstr: urlString)
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            self.logger.trace("API request completed.")
                            // 成功した場合、tempArrayを使ってpromiseに成功を渡す
                            promise(.success(tempArray))
                        case .failure(let error):
                            // 失敗した場合、エラーをpromiseに渡す
                            self.logger.error("API request failed with error: \(error)")
                            promise(.failure(error))
                    }
                }, receiveValue: { weatherForecast in
                    for (i, _) in weatherForecast.daily.time.enumerated() {
                        weatherDescriptions.append(WeatherCODE(weathercode: weatherForecast.daily.weather_code[i]))

                        tempArray.append(["\(weatherForecast.daily.time[i]) ","最高気温\(weatherForecast.daily.temperature_2m_max[i])°C","最低気温\(weatherForecast.daily.temperature_2m_min[i])°C","\(weatherDescriptions[i])"])
                    }
                })
                .store(in: &self.cancellables)
        }
        return future
    }
}

