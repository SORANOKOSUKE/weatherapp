//
//  CoordinateUtility.swift
//  weather
//
//  Created by dit-user on 2024/05/12.
//

import Foundation

class CoordinateUtility {
    static func getCoordinates(for city: String) -> (latitude: Double,longitude: Double)? {
        switch city {
        case "東京":
            return (35.6895, 139.6917)
        case "大阪":
            return (34.6937, 135.5023)
        case "名古屋":
            return (35.1815, 136.9066)
        case "札幌":
            return (43.0618, 141.3545)
        case "福岡":
            return (33.5904, 130.4017)
        case "仙台":
            return (38.2682, 140.8694)
        case "京都":
            return (35.0116, 135.7681)
        case "広島":
            return (34.3853, 132.4553)
        case "沖縄":
            return (26.2124, 127.6809)
        case "横浜":
            return (35.4437, 139.6380)
        default:
            return nil
        }
    }
}
