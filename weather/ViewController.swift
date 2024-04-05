//
//  ViewController.swift
//  weather
//
//  Created by 空野耕介 on 2024/02/28.
//  text

import UIKit
import CoreLocation
import MapKit
import Foundation
import Alamofire
import os
import Combine

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

class ViewController: UIViewController,CLLocationManagerDelegate ,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var pressGesrec: UITapGestureRecognizer!
    @IBOutlet weak var tebleView: UITableView!
    var locationManager: CLLocationManager!
    var lon : Double = 0
    var lat : Double = 0
    var logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")
    var weatherarray : [String] = []
    var pinAnnotations: [MKPointAnnotation] = []
    var cancellables = Set<AnyCancellable>() //Combine


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

        self.logger.debug("lon:\(self.lon)")
        self.logger.debug("lat:\(self.lat)")

    }

    func getURL(latitude: Double, longitude: Double) -> String {
        let timezone = "Asia/Tokyo"
        let daily = "weather_code"
        let max = "temperature_2m_max"
        let min = "temperature_2m_min"
        let urlstr = "https://api.open-meteo.com/v1/forecast?"+"latitude=\(latitude)&longitude=\(longitude)&daily=\(daily),\(max),\(min)&timezone=\(timezone)"
        return urlstr
    }

    //publisher
    func getLocation(urlstr : String) -> PassthroughSubject<WeatherForecast, AFError> {
        let subject = PassthroughSubject<WeatherForecast, AFError>()
        AF.request(urlstr)
            .publishDecodable(type: WeatherForecast.self)
            .value()
            .mapError { error in
                return AFError.invalidURL(url: urlstr)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        self.logger.trace("API request completed.")
                    case .failure(let error):
                        subject.send(completion: .failure(error))
                }
            }, receiveValue: { weatherForecast in
                subject.send(weatherForecast)
                subject.send(completion: .finished)
            })
            .store(in: &cancellables)
        return subject
    }



    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {
                return
            }
        subjectTask()

    }

    func subjectTask() -> Void {
        var tempArray = [[String]]()
        var weatherDescriptions: [String] = []

        getLocation(urlstr: getURL(latitude: lat, longitude: lon))
            .sink(receiveCompletion: { completion in
                print("completion:\(completion)")
            }, receiveValue: { weatherForecast in
                for (i, date) in weatherForecast.daily.time.enumerated() {
                    weatherDescriptions.append(self.WeatherCODE(weathercode: weatherForecast.daily.weather_code[i]))

                    tempArray.append(["\(weatherForecast.daily.time[i]) ","最高気温\(weatherForecast.daily.temperature_2m_max[i])°C","最低気温\(weatherForecast.daily.temperature_2m_min[i])°C","\(weatherDescriptions[i])"])
                    
                    self.weatherarray = tempArray.flatMap{$0}
                    self.tebleView.reloadData()
                }
            })
            .store(in: &cancellables)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)

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
    

    
    



