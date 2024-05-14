//
//  TableDataSource.swift
//  weather
//
//  Created by dit-user on 2024/05/11.
//

import Foundation
import UIKit

protocol WeatherTableDataSourceDelegate: AnyObject {
    func updateTableViewWithData()
}

class WeatherTableDataSource: NSObject, UITableViewDataSource ,UITableViewDelegate{
    weak var delegate: WeatherTableDataSourceDelegate?

    var weatherData = [String]() // TableViewに表示するデータ
    var cellIdentifier = ""

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // セルの設定
        cell.textLabel?.text = weatherData[indexPath.row]

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

    // TableViewのデータを更新するメソッド
    func update(with data: [[String]]) {
        weatherData = data.flatMap{$0}
        delegate?.updateTableViewWithData()
    }
}
