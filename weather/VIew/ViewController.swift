//
//  ViewController.swift
//  weather
//
//  Created by 空野耕介 on 2024/02/28.
//  text

import UIKit
import MapKit
import Foundation
import os

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate{

    var logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var pressGesrec: UITapGestureRecognizer!
    @IBOutlet weak var tableView: UITableView!
    
    var mapViewManager: MapViewManager?

    var weatherViewModel = WeatherViewModel()

    let weatherDataSource = WeatherTableDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        //tableviewのデータソースの設定
        weatherViewModel.weatherDataSource.cellIdentifier = "weatherCell"
        weatherViewModel.weatherDataSource.delegate = self
        tableView.dataSource = weatherViewModel.weatherDataSource
        tableView.delegate = self

        //アプリ内に保存されていれば，lat,lon（緯度経度）を表示
        if let latlon = UserDefaults.standard.array(forKey: "latlon") as? [Double] {
            weatherViewModel.fetchWeatherData(forLatitude: latlon[0] as Double,longitude: latlon[1] as Double)
        }
        
        //mapviewの設定
        mapViewManager = MapViewManager(mapView: mapView)
        mapViewManager?.coordinateHandler = { lat, lon in
            self.weatherViewModel.fetchWeatherData(forLatitude: lat,longitude: lon)
        }
    }

}

extension ViewController: WeatherTableDataSourceDelegate {
    func updateTableViewWithData() { //tableviewの変更のたびに呼ばれる
        tableView.reloadData()
    }
}

