//
//  Mapview.swift
//  weather
//
//  Created by dit-user on 2024/05/07.
//

import Foundation
import MapKit

class MapViewManager: NSObject {
    let mapView: MKMapView
    var coordinateHandler: ((Double, Double) -> Void)?

    init(mapView: MKMapView) {
        self.mapView = mapView
        super.init()
        setupMapView()
    }

    private func setupMapView() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let tapPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

        // ここでlon, latの処理を追加する
        let lon = coordinate.longitude as Double
        let lat = coordinate.latitude as Double
        coordinateHandler?(lat,lon)
        let latlon: [Double] = [lat, lon]
        UserDefaults.standard.set(latlon, forKey: "latlon")

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "緯度：\(round(Float(lon)*100)/100)，経度：\(round(Float(lat)*100)/100)"


        // 古いアノテーションを削除する
        if let oldPin = mapView.annotations.first as? MKPointAnnotation {
            mapView.removeAnnotation(oldPin)
        }
        mapView.addAnnotation(annotation)
    }
}

extension MapViewManager: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            mapView.removeAnnotation(annotation)
        }
    }
}
