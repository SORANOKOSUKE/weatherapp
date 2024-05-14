//
//  NewsTableDataSource.swift
//  weather
//
//  Created by dit-user on 2024/05/13.
//

import Foundation
import UIKit

class NewsTableDataSource: NSObject, UITableViewDataSource , UITableViewDelegate{
    var newsarray : [Any] = []
    var imageArray : [UIImage] = []
    var newsnote : [String] = []
    var cellIdentifier = ""

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsarray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // セルの設定
        cell.textLabel?.text = newsarray[indexPath.row] as? String
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.numberOfLines=0
        cell.isUserInteractionEnabled = true
        if imageArray.count > indexPath.row {
            cell.imageView?.image = imageArray[indexPath.row].resize(size:CGSize(width: 70, height: 60))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell tapped at indexPath: \(indexPath)")
        guard let url = URL(string: newsnote[indexPath.row]) else {
            print("Invalid URL: \(newsnote[indexPath.row])")
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                print("Failed to open URL: \(url)")
            }
        }
    }

    // TableViewのデータを更新するメソッド
    func update(title: [Any],url:[String],image:[UIImage]) {
        newsarray = title
        imageArray = image
        newsnote = url
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

