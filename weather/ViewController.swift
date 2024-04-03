//
//  ViewController.swift
//  weather
//
//  Created by 空野耕介 on 2024/02/28.
//

import UIKit
import CoreLocation
import MapKit
import Foundation
import Alamofire
import os

struct WeatherData: Codable {
    var timezone_abbreviation: String
    var daily_units: [String: String]
    var latitude: Double
    var longitude: Double
    var elevation: Int
    var daily: [DailyWeather]
    var utc_offset_seconds: Int
    var generationtime_ms: Double
}

struct DailyWeather: Codable {
    var temperature_2m_max: Double
    var temperature_2m_min: Double
    var time: String
    var weather_code: Int
}

class ViewController: UIViewController,CLLocationManagerDelegate ,UIGestureRecognizerDelegate,UITabBarDelegate,UITableViewDataSource{
    @IBOutlet var mapView: MKMapView!
    let image =  UIImageView()
    @IBOutlet var pressGesrec: UITapGestureRecognizer!
    @IBOutlet weak var tableView: UITableView!
    var locationManager: CLLocationManager!
    var lon : Double = 0
    var lat : Double = 0
    var logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")
    var weatherarray : [String] = []
    var pinAnnotations: [MKPointAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func mapViewDidPress(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: view)
        let center = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        
        lon  = center.longitude
        lat  = center.latitude

        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = "緯度：\(round(Float(lon)*100)/100)，経度：\(round(Float(lat)*100)/100)"
        mapView.addAnnotation(annotation)

        if !pinAnnotations.isEmpty {
            let oldPin = pinAnnotations.removeFirst()
            mapView.removeAnnotation(oldPin)
        }

        pinAnnotations.append(annotation)
    }
    
    func getLocationInfo(latitude: Double, longitude: Double, completion: @escaping ([[String]]) -> Void) {
        let timezone = "Asia/Tokyo"
        let daily = "weather_code"
        let max = "temperature_2m_max"
        let min = "temperature_2m_min"
        let urlstr = "https://api.open-meteo.com/v1/forecast?"+"latitude=\(latitude)&longitude=\(longitude)&daily=\(daily),\(max),\(min)&timezone=\(timezone)"
        var tempArray = [[String]]()
        var weatherDescriptions: [String] = []
        var wareki : [String] = []

        if let weatherurl = URL(string: urlstr) {
            AF.request(weatherurl).responseDecodable(of: WeatherData.self) {response in
                switch response.result {
                   case .success(let value):
                        self.logger.trace("value.max\(value.daily)")
                        //self.logger.trace("value.times\(value.times)")
                   case .failure(let error):
                        self.logger.error("Errorrrrrr\(error.localizedDescription)")
                   }
            }
        }


        if let weatherurl = URL(string: urlstr) {
            AF.request(weatherurl).responseJSON { response in
                switch response.result{
                    case .success(let value):
                        if let json = value as? [String: Any]{
                            self.logger.trace("trace:\(json)")
                            if let dailyData = json["daily"] as? [String: Any],
                               let maxData = dailyData["temperature_2m_max"] as? [Double] ,let minData = dailyData["temperature_2m_min"] as? [Double],let timeData = dailyData["time"] as? [String] ,let wetherData = dailyData["weather_code"]as? [Double] {
                                self.logger.trace("max data: \(maxData)")
                                self.logger.trace("min data: \(minData)")
                                self.logger.trace("wether data: \(wetherData)")
                                self.logger.trace("timedata: \(timeData)")

                                for i in 0..<5{
                                    switch wetherData[i] {
                                        case 0:
                                            weatherDescriptions.append("晴天")
                                        case 1, 2, 3:
                                            weatherDescriptions.append("晴れ時々曇り、曇り")
                                        case 45, 48:
                                            weatherDescriptions.append("霧と降る霧氷")
                                        case 51, 53, 55:
                                            weatherDescriptions.append("霧雨: 軽い、中程度、そして濃い強度")
                                        case 56, 57:
                                            weatherDescriptions.append("氷結霧雨: 軽くて濃い強度")
                                        case 61, 63, 65:
                                            weatherDescriptions.append("雨：小雨、中程度、激しい雨")
                                        case 66, 67:
                                            weatherDescriptions.append("凍てつく雨：軽くて激しい雨")
                                        case 71, 73, 75:
                                            weatherDescriptions.append("降雪量: わずか、中程度、激しい")
                                        case 77:
                                            weatherDescriptions.append("雪の粒")
                                        case 80, 81, 82:
                                            weatherDescriptions.append("にわか雨：小雨、中程度、激しい雨")
                                        case 85, 86:
                                            weatherDescriptions.append("雪が少し降ったり、激しく降ったりします")
                                        case 95, 96, 99:
                                            weatherDescriptions.append("雷雨: わずかまたは中程度、わずかまたは激しいひょうを伴う雷雨")
                                        default:
                                            weatherDescriptions.append("その他の天候")
                                    }

                                    let dateString = timeData[i]
                                    let inputFormatter = DateFormatter()
                                    inputFormatter.dateFormat = "yyyy-MM-dd"
                                    if let date = inputFormatter.date(from: dateString){
                                        var outputFormatter = DateFormatter()
                                        outputFormatter.dateFormat = "yyyy年MM月dd日"
                                        let daystring = outputFormatter.string(from: date)
                                        wareki.append(daystring)
                                    }
                                    tempArray.append(["\(wareki[i]) ","最高気温\(maxData[i])°C","最低気温\(minData[i])°C","\(weatherDescriptions[i])"])
                                }
                                completion(tempArray)
                            }
                        }
                    case.failure(let error):
                        self.logger.error("error")
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
                return
            }

        getLocationInfo(latitude:lat,longitude:lon){ getArray in
            self.weatherarray = getArray.flatMap{$0}
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            mapView.removeAnnotation(annotation)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherarray.count
    }

    func tableView(_ tableView: UITableView,  cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)

        cell.textLabel?.text = weatherarray[indexPath.row]
        
        if indexPath.row % 4 == 1 {
            cell.textLabel?.textColor = UIColor.red
        }else if indexPath.row % 4 == 2 {
            cell.textLabel?.textColor = UIColor.blue
        }else{
            cell.textLabel?.textColor = UIColor.black
        }

        if indexPath.row % 4 == 0 {
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = UIColor.black.cgColor
        } else {
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = UIColor.clear.cgColor
        }

        return cell
    }

}
    

    
    



