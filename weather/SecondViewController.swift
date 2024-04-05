//
//  SecondViewController.swift
//  weather
//
//  Created by dit-user on 2024/04/04.
//

import UIKit
import Foundation
import os

class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var table2View: UITableView!
    
    var weatherarray : [String] = []

    let cities = ["東京", "大阪", "名古屋", "札幌", "福岡", "仙台", "京都", "広島", "沖縄", "横浜"]
    var logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")

    let viewController = ViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self

    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let coordinates = getCoordinates(for: cities[row]) {
            let latitude = coordinates.latitude
            let longitude = coordinates.longitude
            self.logger.trace("Selected City: 緯度\(latitude),経度\(longitude)")
            viewController.getLocationInfo(latitude:latitude,longitude:longitude){ getArray in
                self.logger.trace("getArray:\(getArray)")
                self.weatherarray = getArray.flatMap{$0}
                DispatchQueue.main.async {
                    self.table2View.reloadData()
                }
            }
        }
    }

    func getCoordinates(for city: String) -> (latitude: Double,longitude: Double)? {
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
            return nil // 都市名に対応する緯度経度が見つからない場合は nil を返す
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherarray.count
    }

    func tableView(_ tableView: UITableView,  cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesCell", for: indexPath)

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
