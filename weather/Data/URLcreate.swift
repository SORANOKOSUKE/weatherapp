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

