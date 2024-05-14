//
//  CityPickerDelegate.swift
//  weather
//
//  Created by dit-user on 2024/05/12.
//

import UIKit
import Combine

protocol CityPickerDelegateDelegate: AnyObject {
    func cityPickerDelegate(_ cityPickerDelegate: CityPickerDelegate, didUpdateWeatherData data: [[String]])
}

class CityPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    weak var delegate: CityPickerDelegateDelegate?
    var cityname: [String] = []
    let weatherSubscriber = WeatherSubscriber()
    var cancellables = Set<AnyCancellable>()

    init(cityname: [String]) {
        self.cityname = cityname
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cityname.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cityname[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if let coordinates = CoordinateUtility.getCoordinates(for: cityname[row]) {
                let lat = coordinates.latitude
                let lon = coordinates.longitude

                weatherSubscriber.subjectTask(urlString: getURL(latitude: lat, longitude: lon))
                    .sink(receiveCompletion: { completion in
                        // エラー処理などをここに追加するか、空にする
                    }, receiveValue: { data in
                        // データをdelegateを通じてViewControllerに伝える
                        self.delegate?.cityPickerDelegate(self, didUpdateWeatherData: data)
                    })
                    .store(in: &cancellables)
            }
        }

}

let cities = ["東京", "大阪", "名古屋", "札幌", "福岡", "仙台", "京都", "広島", "沖縄", "横浜"]

