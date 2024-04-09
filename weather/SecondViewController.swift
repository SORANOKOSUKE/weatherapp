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

//newsStruct
struct NewsForcast: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let source: Source  //source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let id: String?
    let name: String
}

class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var table2View: UITableView!
    @IBOutlet weak var table3View: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var land: UILabel!
    var weatherarray : [String] = []
    var newsarray : [Any] = []
    var cancellables = Set<AnyCancellable>() //Combine
    //var cancellables2 = Set<AnyCancellable>() //Combine
    var imageArray : [UIImage] = []
    var newsnote : [String] = []

    let cities = ["東京", "大阪", "名古屋", "札幌", "福岡", "仙台", "京都", "広島", "沖縄", "横浜"]
    var logger = Logger(subsystem: "com.amefure.sample", category: "Custom Category")

    let viewController = ViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        subjectTask(latitude: 35.6895, longitude: 139.6917) //初期値「東京」
        scrollView.contentSize = CGSize(width:view.frame.size.width, height:view.frame.size.height * 1.6)
        self.land.text = "  東京の天気"
        scrollView.addSubview(pickerView)
        scrollView.addSubview(table2View)
        scrollView.addSubview(table3View)
        getNews()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //select_reasion
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
            subjectTask(latitude: latitude, longitude: longitude)
        }
    }
    
    func subjectTask(latitude: Double, longitude: Double) -> Void {
        var tempArray = [[String]]()
        var weatherDescriptions: [String] = []
        viewController.getLocation(urlstr: viewController.getURL(latitude: latitude, longitude: longitude))
            .sink(receiveCompletion: { completion in
                print("completion[weather]:\(completion)")
            }, receiveValue: { weatherForecast in
                for (i, _) in weatherForecast.daily.time.enumerated() {
                    weatherDescriptions.append(self.viewController.WeatherCODE(weathercode: weatherForecast.daily.weather_code[i]))

                    tempArray.append(["\(weatherForecast.daily.time[i]) ","最高気温\(weatherForecast.daily.temperature_2m_max[i])°C","最低気温\(weatherForecast.daily.temperature_2m_min[i])°C","\(weatherDescriptions[i])"])
                    self.weatherarray = tempArray.flatMap{$0}
                    self.table2View.reloadData()
                }
            })
            .store(in: &viewController.cancellables)
    }

    //newsPublisher
    func getNewsReport(url:String) -> AnyPublisher<NewsForcast, AFError> {
        return AF.request(url)
            .publishDecodable(type: NewsForcast.self)
            .value()
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }
    //newsSubscriber
    func getNews()-> Void {
        let apikey = "9123f41483314392aa3dde64c4d29b1c"
        let co = "jp"
        getNewsReport(url : "https://newsapi.org/v2/top-headlines?country=\(co)&apiKey=\(apikey)")
        .sink(receiveCompletion: { completion in
                print("completion:\(completion)")
                if case let .failure(error) = completion {
                    print("Error:\(error)")
                }
            }, receiveValue: { NewsForcast in
                for article in NewsForcast.articles{
                    self.newsarray.append(article.title)
                    self.newsnote.append(article.url)
                    if let urltoimage = article.urlToImage{
                        self.ImageSubcriber(imgurlstr : urltoimage)
                    }else{
                    }
                    self.table3View.reloadData()
                }
            })
        .store(in: &cancellables)
    }

    //newsImagePublisher   //画像取得のためのsubcriber
    func getNewsImage(url: String)-> AnyPublisher<UIImage?,AFError>{
        AF.request(url)
            .publishData()
            .tryMap { response -> UIImage? in
                if let data = response.data{
                    return UIImage(data: data)
                }else{
                    return UIImage(named: "noimage.png")
                }
            }
            .mapError{error in
                return AFError.invalidURL(url: url)
            }
            .eraseToAnyPublisher()
    }

    func ImageSubcriber(imgurlstr : String) -> Void {
        self.getNewsImage(url : imgurlstr).sink(receiveCompletion: { completion in
            print("completion[image]:\(completion)")
        }, receiveValue: { image in
            if let image2 = image {
                self.imageArray.append(image2)
                self.logger.debug("complete:")
            }else{
                self.imageArray.append(UIImage(named: "noimage.png")!)
            }
        })
        .store(in: &cancellables)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table2View {
            return weatherarray.count
        } else if tableView == table3View {
            return self.newsarray.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView,  cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == table2View {
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

        } else if tableView == table3View {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
            cell.textLabel?.text = newsarray[indexPath.row] as? String
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.textLabel?.numberOfLines=0
            if imageArray.count > indexPath.row {
                cell.imageView?.image = imageArray[indexPath.row].resize(size:CGSize(width: 70, height: 60))
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table3View {
            if UIApplication.shared.canOpenURL(URL(string: self.newsnote[indexPath.row])!) {
                UIApplication.shared.open(URL(string: self.newsnote[indexPath.row])!, options: [:], completionHandler: nil)
            }else{
                self.logger.error("UIApplication:error!")
            }
        }
    }

    func getCoordinates(for city: String) -> (latitude: Double,longitude: Double)? {
        self.land.text = "  " + city + "の天気"
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
}

extension UIImage {

    func resize(size: CGSize) -> UIImage {
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        let resizedSize = CGSize(width: (self.size.width * ratio), height: (self.size.height * ratio))
        // 画質を落とさないように以下を修正
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

}
