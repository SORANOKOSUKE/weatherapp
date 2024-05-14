//
//  Datasouce.swift
//  weather
//
//  Created by dit-user on 2024/05/07.
//

import Foundation

//weatherStruct
struct WeatherForecast: Decodable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let daily: DailyWeatherData
}

struct DailyWeatherData: Decodable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
}


//newsStruct
struct NewsForcast: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let source: Source  //source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let id: String?
    let name: String
}
