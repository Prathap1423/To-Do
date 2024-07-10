//
//  AllTasksExtension.swift
//  Zoho Task
//
//  Created by prathap on 09/07/24.
//

import UIKit
import CoreLocation

extension AllTasksViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            fetchWeather(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        
        let apiKey = "c611712226af47de842112304240907"
        
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.locationManager.stopUpdatingLocation()
            guard let data = data, error == nil else {
                print("Failed to fetch data")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    self.parseWeatherData(json: json)
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func parseWeatherData(json: [String: Any]) {
        if let location = json["location"] as? [String: Any],
           let current = json["current"] as? [String: Any],
           let cityName = location["name"] as? String,
           let temperature = current["temp_c"] as? Double {
            let weather = " \(cityName) \(temperature)°C"
            print(weather)
            configureNavigationLeftButtonItems(title: weather)
        } else {
            print("Failed to extract weather data")
        }
    }
    
    func configureNavigationLeftButtonItems(title: String) {
        DispatchQueue.main.async {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setImage(UIImage(named: "Weather_Icon"), for: .normal)
            button.tintColor = .black
            // Adjust image and title positions
            button.sizeToFit()
            button.imageView?.contentMode = .scaleAspectFit
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            
            // Set the UIButton as the custom view of a UIBarButtonItem
            let leftBarButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    }
}


