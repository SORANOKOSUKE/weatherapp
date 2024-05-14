//
//  SecondViewController.swift
//  weather
//
//  Created by dit-user on 2024/04/04.
//

import UIKit
import Foundation
import os
import Alamofire
import Combine


class SecondViewController: UIViewController, CityPickerDelegateDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var table2View: UITableView!
    @IBOutlet weak var table3View: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var land: UILabel!

    let weatherDataSource = WeatherTableDataSource()
    let newsTableDataSource = NewsTableDataSource()

    var weatherSubscriber =  WeatherSubscriber()
    var newsmanager = NewsManager()
    var secondViewModel = SecondViewModel()

    let cityPickerDelegate = CityPickerDelegate(cityname: cities)

    var weatherarray : [String] = []

    var cancellables = Set<AnyCancellable>() //Combine

    var lon : Double = 139.6917
    var lat : Double = 35.6895

    var logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //pickerの設定
        pickerView.delegate = cityPickerDelegate
        pickerView.dataSource = cityPickerDelegate

        //pickerの動作検知
        cityPickerDelegate.delegate = self

        //tableview2のデータソース設定
        weatherDataSource.cellIdentifier = "citiesCell"
        table2View.dataSource = weatherDataSource
        table2View.delegate = weatherDataSource

        //tableview3のデータソース設定
        newsTableDataSource.cellIdentifier = "newsCell"
        table3View.dataSource = newsTableDataSource
        table3View.delegate = newsTableDataSource

        //tableview2,tableview3のデータソースを非同期に更新
        bindViewModel()

        //weatherdataの初期値　東京の天気情報を取得
        secondViewModel.fetchWeatherData(forLatitude: lat, longitude: lon)
        self.land.text = "東京の天気"

        //ニュースデータの情報を取得
        secondViewModel.fetchNews()

        //スクロールviewの設定
        scrollView.addSubview(pickerView)
        scrollView.addSubview(table2View)
        scrollView.addSubview(table3View)
    }

    func cityPickerDelegate(_ cityPickerDelegate: CityPickerDelegate, didUpdateWeatherData data: [[String]]) {
        // データを受け取り、テーブルビューを更新する処理を実行する
        updateTableView2WithData(data: data)
    }

    func updateTableView2WithData(data: [[String]]) {
        weatherDataSource.update(with: data)
        table2View.reloadData()
    }

    private func bindViewModel() {
        secondViewModel.$weatherData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.weatherDataSource.update(with: data)
                self?.table2View.reloadData()
            }
            .store(in: &cancellables)

        secondViewModel.$newsData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.newsTableDataSource.update(title: data.titles, url: data.urls, image: data.images)
                self?.table3View.reloadData()
            }
            .store(in: &cancellables)
    }
}

