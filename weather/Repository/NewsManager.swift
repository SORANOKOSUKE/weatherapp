//
//  NewsManager.swift
//  weather
//
//  Created by dit-user on 2024/05/13.
//

import Foundation
import Alamofire
import Combine
import UIKit


class NewsManager {
    private var cancellables = Set<AnyCancellable>()

    func getNewsReport(url: String) -> AnyPublisher<NewsForcast, AFError> {
        return AF.request(url)
            .publishDecodable(type: NewsForcast.self)
            .value()
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }



    func getNews(completion: @escaping (Result<NewsForcast, Error>) -> Void) {
        let apikey = "9123f41483314392aa3dde64c4d29b1c"
        let co = "jp"
        getNewsReport(url: "https://newsapi.org/v2/top-headlines?country=\(co)&apiKey=\(apikey)")
            .sink(receiveCompletion: { result in
                switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        completion(.failure(error))
                }
            }, receiveValue: { newsForcast in
                completion(.success(newsForcast))
            })
            .store(in: &cancellables)
    }

    func getNewsImage(url: String) -> AnyPublisher<UIImage?, AFError> {
        return AF.request(url)
            .publishData()
            .tryMap { response -> UIImage? in
                if let data = response.data {
                    return UIImage(data: data)
                } else {
                    return UIImage(named: "noimage.png")
                }
            }
            .mapError { error in
                print("Error occurred during request: \(error)")
                return error as! AFError
            }
            .eraseToAnyPublisher()
    }

    func getImage(url: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        getNewsImage(url: url)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    // エラーが発生した場合はエラー処理を行います。
                    print("Error fetching image: \(error)")
                    completion(.failure(error))
                }
            }, receiveValue: { image in
                // 成功した場合は値を受け取り、結果を処理します。
                completion(.success(image))
            })
            .store(in: &cancellables)
    }
}
