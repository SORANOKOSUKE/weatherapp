//
//  WeatherService.swift
//  weather
//
//  Created by dit-user on 2024/05/07.
//

import Foundation
import Alamofire
import Combine

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
