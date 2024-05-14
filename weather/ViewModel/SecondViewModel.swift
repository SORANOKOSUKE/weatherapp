//
//  SecondViewModel.swift
//  weather
//
//  Created by dit-user on 2024/05/14.
//

import Combine
import UIKit

class SecondViewModel {
    @Published var weatherData: [[String]] = []
    @Published var newsData: (titles: [Any], urls: [String], images: [UIImage]) = ([], [], [])

    private var cancellables = Set<AnyCancellable>()
    private var weatherManager = WeatherManager()
    private var newsManager = NewsManager()

    func fetchWeatherData(forLatitude lat: Double, longitude lon: Double) {
        let url: String = getURL(latitude: lat, longitude: lon)
        weatherManager.subjectTask(urlString: url)
            .sink(receiveCompletion: { completion in
                //エラー文
            }, receiveValue: { data in
                self.weatherData = data
            })
            .store(in: &cancellables)
    }

    func fetchNews() {
        newsManager.getNews { result in
            switch result {
            case .success(let newsForcast):
                self.fetchNewsForcast(newsForcast)
            case .failure(let error):
                print("Error fetching news: \(error)")
            }
        }
    }

    private func fetchNewsForcast(_ newsForcast: NewsForcast) {
        var newsarray: [Any] = []
        var imageArray: [UIImage] = []
        var newsnote: [String] = []

        let group = DispatchGroup()

        for article in newsForcast.articles {
            newsarray.append(article.title)
            newsnote.append(article.url)
            if let urlToImage = article.urlToImage {
                group.enter()
                newsManager.getImage(url: urlToImage) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let image):
                        if let image = image {
                            imageArray.append(image)
                        } else {
                            imageArray.append(UIImage(named: "noimage.png")!)
                        }
                    case .failure:
                        imageArray.append(UIImage(named: "noimage.png")!)
                    }
                }
            } else {
                print("Image URL is nil")
                imageArray.append(UIImage(named: "noimage.png")!)
            }
        }

        group.notify(queue: .main) {
            self.newsData = (titles: newsarray, urls: newsnote, images: imageArray)
        }
    }
}
