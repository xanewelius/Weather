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
    private let defaults = UserDefaults.standard
    
    private var currentTempCelsius = 0.0
    private var currentTempFahrenheit = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        layout()
        checkForSwitchPreference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layer.contents = UIImage(named: "background1")?.cgImage
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
        label.font = UIFont(name: "Montserrat-Bold", size: 25)
        return label
    }()
    
    private let labelDescriprion: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Light", size: 15)
        return label
    }()
    
    private let labelCity: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Medium", size: 20)
        return label
    }()
    
    let dateInfo: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Montserrat-Light", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tempSwitch: UISwitch = {
        let tempSwitch = UISwitch()
        tempSwitch.onTintColor = .black
        tempSwitch.translatesAutoresizingMaskIntoConstraints = false
        tempSwitch.addTarget(self, action: #selector(switchDidTap), for: .valueChanged)
        return tempSwitch
    }()
    
    private let tempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 20
        view.layer.opacity = 0.3
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sdgdStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
                
                let date = Date(timeIntervalSince1970: TimeInterval(weather.dt))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, d MMM yyyy HH:mm"
                dateFormatter.locale = Locale(identifier: "ru") //en_US
                let dateString = dateFormatter.string(from: date)
                
                self.dateInfo.text = "\(dateString)"
                self.currentTempCelsius  = weather.main.temp - 273.15
                self.currentTempFahrenheit = self.currentTempCelsius * 1.8 + 32
                self.switchDidTap()
                self.weatherImage.image = iconModel.fetchImage(icon: icon, id: Int(id))
                self.labelDescriprion.text = "\(desc)"
                self.labelCity.text = (weatherData.city.name)
            }
        }
    }
    
    @objc
    func switchDidTap() {
        if tempSwitch.isOn {
            labelTemp.text = "\(String(format: "%.2f", currentTempFahrenheit))°F"
        } else {
            labelTemp.text = "\(String(format: "%.2f", currentTempCelsius))°C"
        }
        userDefaultsConfig()
    }
    
    func layout() {
        view.addSubview(labelCity)
        view.addSubview(dateInfo)
        
        view.addSubview(tempStackView)
        
        
        tempStackView.insertSubview(blurView, at: 0)
        tempStackView.addArrangedSubview(weatherImage)
        tempStackView.addArrangedSubview(labelDescriprion)
        tempStackView.addArrangedSubview(labelTemp)
        //infoStackView.addArrangedSubview(tempSwitch)
        
        
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            blurView.heightAnchor.constraint(equalToConstant: 150),
            blurView.widthAnchor.constraint(equalToConstant: 140),
            
            tempStackView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            tempStackView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
            
            weatherImage.heightAnchor.constraint(equalToConstant: 70),
            weatherImage.widthAnchor.constraint(equalToConstant: 70),
            
            labelDescriprion.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: -10),
            labelDescriprion.widthAnchor.constraint(equalTo: blurView.widthAnchor, constant: -20), // Ограничить ширину labelDescription
            
            labelCity.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            labelCity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dateInfo.topAnchor.constraint(equalTo: labelCity.bottomAnchor, constant: 10),
            dateInfo.widthAnchor.constraint(equalToConstant: 150),
            dateInfo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
            defaults.set(tempSwitch.isOn, forKey: "setSwitch")
        } else {
            defaults.set(tempSwitch.isOn, forKey: "setSwitch")
        }
    }
    
    func checkForSwitchPreference() {
        if defaults.object(forKey: "setSwitch") != nil {
            tempSwitch.isOn = defaults.bool(forKey: "setSwitch")
        } else {
            tempSwitch.isOn = defaults.bool(forKey: "setSwitch")
        }
    }
}
