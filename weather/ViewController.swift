//
//  ViewController.swift
//  weather
//
//  Created by Max Kuzmin on 24.02.2023.
//

import UIKit
import CoreLocation

final class ViewController: UIViewController {
    
    private let networkManager = NetworkManager()
    private var locationManager: CLLocationManager?
    private var currentTemp = 0.0
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        setupUI()
        checkForSwitcPreference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layer.contents = UIImage(named: "background")?.cgImage
    }
    
    private let weatherImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let labelTemp: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Bold", size: 50)
        return label
    }()
    
    private let labelDescriprion: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Light", size: 15)
        return label
    }()
    
    private let labelCity: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Medium", size: 20)
        return label
    }()
    
    private lazy var tempSwitch: UISwitch = {
        let tempSwitch = UISwitch()
        tempSwitch.onTintColor = .black
        tempSwitch.translatesAutoresizingMaskIntoConstraints = false
        tempSwitch.addTarget(self, action: #selector(switchDidTap), for: .valueChanged)
        return tempSwitch
    }()
}

private extension ViewController {
    func fetchData(lat: String, lon: String) {
        networkManager.jsonPars(lat: lat, lon: lon) { weatherData in
            DispatchQueue.main.async {
                guard let weather = weatherData.list.first,
                      let desc = weather.weather.first?.description,
                      let icon = weather.weather.first?.icon,
                      let id = weather.weather.first?.id else { return }
                
                let iconModel = IconModel()
                self.currentTemp = weather.main.temp - 273.15
                self.weatherImage.image = iconModel.fetchImage(icon: icon, id: Int(id))
                self.labelTemp.text = "\(String(format: "%.2f", weather.main.temp - 273.15))°C"
                self.labelDescriprion.text = "\(desc)"
                self.labelCity.text = (weatherData.city.name)
            }
        }
    }
    
    @objc
    func switchDidTap() {
        if tempSwitch.isOn {
            labelTemp.text = "\(String(format: "%.2f", currentTemp * 1.8 + 32))°F"
            userDefaultsConfig()
        } else {
            labelTemp.text = "\(String(format: "%.2f", currentTemp))°C"
            userDefaultsConfig()
        }
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(weatherImage)
        view.addSubview(labelDescriprion)
        view.addSubview(labelTemp)
        view.addSubview(labelCity)
        view.addSubview(tempSwitch)
        
        NSLayoutConstraint.activate([
            labelTemp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelTemp.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            labelDescriprion.bottomAnchor.constraint(equalTo: labelTemp.topAnchor, constant: -20),
            labelDescriprion.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labelDescriprion.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            weatherImage.bottomAnchor.constraint(equalTo: labelDescriprion.topAnchor, constant: -10),
            weatherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            labelCity.topAnchor.constraint(equalTo: labelTemp.bottomAnchor, constant: 20),
            labelCity.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labelCity.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tempSwitch.topAnchor.constraint(equalTo: labelCity.bottomAnchor, constant: 25),
            tempSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

// MARK: - CLLocation
extension ViewController: CLLocationManagerDelegate {
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        let lat = String(first.coordinate.latitude)
        let lon = String(first.coordinate.longitude)
        fetchData(lat: lat, lon: lon)
    }
}

// MARK: - User Defaults
private extension ViewController {
    func userDefaultsConfig() {
        if tempSwitch.isOn {
            defaults.set(true, forKey: "switchModeOn")
        } else {
            defaults.set(false, forKey: "switchModeOff")
        }
    }
    
    func checkForSwitcPreference() {
        print(defaults)
        if defaults.bool(forKey: "switchModeOn") {
            tempSwitch.setOn(true, animated: false)
        } else {
            tempSwitch.setOn(false, animated: false)
        }
    }
}
