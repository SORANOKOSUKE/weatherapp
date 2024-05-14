//
//  URLcreate.swift
//  weather
//
//  Created by dit-user on 2024/05/07.
//

import Foundation

func getURL(latitude: Double, longitude: Double) -> String {
    let timezone = "Asia/Tokyo"
    let daily = "weather_code"
    let max = "temperature_2m_max"
    let min = "temperature_2m_min"
    let urlstr = "https://api.open-meteo.com/v1/forecast?"+"latitude=\(latitude)&longitude=\(longitude)&daily=\(daily),\(max),\(min)&timezone=\(timezone)"
    return urlstr
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

