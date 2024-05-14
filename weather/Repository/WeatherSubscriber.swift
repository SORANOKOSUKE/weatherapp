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

class WeatherSubscriber {
    let logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")

    var cancellables = Set<AnyCancellable>()

    func subjectTask(urlString: String) -> Future<[[String]], Error> {
        let weatherService = WeatherService()
        var tempArray = [[String]]()
        var weatherDescriptions: [String] = []

        let future = Future<[[String]], Error> { promise in
            weatherService.getLocation(urlstr: urlString)
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
                        weatherDescriptions.append(self.WeatherCODE(weathercode: weatherForecast.daily.weather_code[i]))

                        tempArray.append(["\(weatherForecast.daily.time[i]) ","最高気温\(weatherForecast.daily.temperature_2m_max[i])°C","最低気温\(weatherForecast.daily.temperature_2m_min[i])°C","\(weatherDescriptions[i])"])
                    }
                })
                .store(in: &self.cancellables)
        }
        return future
    }

    func WeatherCODE(weathercode : Int) -> String {
        let weatherstring : String
        switch weathercode {
            case 0:
                weatherstring = "晴天"
            case 1, 2, 3:
                weatherstring = "晴れ時々曇り、曇り"
            case 45, 48:
                weatherstring = "霧と降る霧氷"
            case 51, 53, 55:
                weatherstring = "霧雨: 軽い、中程度、そして濃い強度"
            case 56, 57:
                weatherstring = "氷結霧雨: 軽くて濃い強度"
            case 61, 63, 65:
                weatherstring = "雨：小雨、中程度、激しい雨"
            case 66, 67:
                weatherstring = "凍てつく雨：軽くて激しい雨"
            case 71, 73, 75:
                weatherstring = "降雪量: わずか、中程度、激しい"
            case 77:
                weatherstring = "雪の粒"
            case 80, 81, 82:
                weatherstring = "にわか雨：小雨、中程度、激しい雨"
            case 85, 86:
                weatherstring = "雪が少し降ったり、激しく降ったりします"
            case 95, 96, 99:
                weatherstring = "雷雨: わずかまたは中程度、わずかまたは激しいひょうを伴う雷雨"
            default:
                weatherstring = "その他の天候"
        }
            return weatherstring
    }
}

//publisher
class WeatherService {
    func getLocation(urlstr : String) -> AnyPublisher<WeatherForecast, AFError> {
        AF.request(urlstr)
            .publishDecodable(type: WeatherForecast.self)
            .value()
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }
}
