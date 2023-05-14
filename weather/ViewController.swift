//
//  ViewController.swift
//  weather
//
//  Created by Max Kuzmin on 24.02.2023.
//

import UIKit
import CoreLocation

final class ViewController: UIViewController {
    
    private let iconModel = IconModel()
    private var locationManager: CLLocationManager?
    private let defaults = UserDefaults.standard
    
    private var weatherForecast: [ResponseBody.ListResponse] = []
    private var currentTempCelsius = 0.0
    private var currentTempFahrenheit = 0.0
    private let collectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        configureView()
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
    
    let blurTempView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 20
        view.layer.opacity = 0.3
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let elementsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let pressureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Medium", size: 20)
        return label
    }()
    
    private let pressureImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pressure"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let pressureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Medium", size: 20)
        return label
    }()
    
    private let humidityImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "humidity"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let humidityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let windLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Medium", size: 20)
        return label
    }()
    
    private let windImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "wind"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let windStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let blurElemetnsView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 20
        view.layer.opacity = 0.3
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 120)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
}

extension ViewController {
    func fetchData(lat: String, lon: String) {
        NetworkManager.shared.jsonPars(lat: lat, lon: lon) { weatherData in
            DispatchQueue.main.async {
                guard let weather = weatherData.list.first,
                      let desc = weather.weather.first?.description,
                      let icon = weather.weather.first?.icon,
                      let id = weather.weather.first?.id else { return }
                
                
                self.weatherForecast = weatherData.list
                self.collectionView.reloadData()
                 
                self.pressureLabel.text = String(format: "%.0f", weather.main.pressure / 1.333) + " mm"
                self.humidityLabel.text = "\(weather.main.humidity)%"
                self.windLabel.text = "\(weather.wind.speed) m/s"
                
                self.dateInfo.text = "\(self.dateFormatter(date: weather, format: "EEEE, d MMM yyyy, на HH:mm"))"
                self.currentTempCelsius  = weather.main.temp - 273.15
                self.currentTempFahrenheit = self.currentTempCelsius * 1.8 + 32
                self.switchDidTap()
                self.weatherImage.image = self.iconModel.fetchImage(icon: icon, id: Int(id))
                self.labelDescriprion.text = "\(desc)"
                self.labelCity.text = (weatherData.city.name)
            }
        }
    }
    
    func dateFormatter(date: ResponseBody.ListResponse, format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date.dt - 1))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ru") //en_US
        let dateString = dateFormatter.string(from: date)
        return dateString
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
    
    func configureView() {
        view.addSubview(labelCity)
        view.addSubview(dateInfo)
        
        view.addSubview(tempStackView)
        tempStackView.insertSubview(blurTempView, at: 0)
        tempStackView.addArrangedSubview(weatherImage)
        tempStackView.addArrangedSubview(labelDescriprion)
        tempStackView.addArrangedSubview(labelTemp)
        
        view.addSubview(elementsStackView)
        elementsStackView.insertSubview(blurElemetnsView, at: 0)
        
        elementsStackView.addArrangedSubview(pressureStackView)
        elementsStackView.addArrangedSubview(humidityStackView)
        elementsStackView.addArrangedSubview(windStackView)
        
        pressureStackView.addArrangedSubview(pressureImageView)
        pressureStackView.addArrangedSubview(pressureLabel)
        
        humidityStackView.addArrangedSubview(humidityImageView)
        humidityStackView.addArrangedSubview(humidityLabel)
        
        windStackView.addArrangedSubview(windImageView)
        windStackView.addArrangedSubview(windLabel)
        
        //infoStackView.addArrangedSubview(tempSwitch)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        layout()
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            tempStackView.centerXAnchor.constraint(equalTo: blurTempView.centerXAnchor),
            tempStackView.centerYAnchor.constraint(equalTo: blurTempView.centerYAnchor),
            
            blurTempView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            blurTempView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            blurTempView.heightAnchor.constraint(equalToConstant: 150),
            blurTempView.widthAnchor.constraint(equalToConstant: 140),
            
            weatherImage.heightAnchor.constraint(equalToConstant: 70),
            weatherImage.widthAnchor.constraint(equalToConstant: 70),
            
            labelDescriprion.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: -10),
            labelDescriprion.widthAnchor.constraint(equalTo: blurTempView.widthAnchor, constant: -20), // Ограничить ширину labelDescription
            
            labelCity.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            labelCity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dateInfo.topAnchor.constraint(equalTo: labelCity.bottomAnchor, constant: 10),
            dateInfo.widthAnchor.constraint(equalToConstant: 150),
            dateInfo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            elementsStackView.centerXAnchor.constraint(equalTo: blurElemetnsView.centerXAnchor),
            elementsStackView.centerYAnchor.constraint(equalTo: blurElemetnsView.centerYAnchor),
            pressureStackView.widthAnchor.constraint(equalTo: blurElemetnsView.widthAnchor, constant: -40),
            humidityStackView.widthAnchor.constraint(equalTo: blurElemetnsView.widthAnchor, constant: -40),
            windStackView.widthAnchor.constraint(equalTo: blurElemetnsView.widthAnchor, constant: -40  ),
            
            pressureImageView.heightAnchor.constraint(equalToConstant: 30),
            pressureImageView.widthAnchor.constraint(equalToConstant: 30),
            humidityImageView.heightAnchor.constraint(equalToConstant: 30),
            humidityImageView.widthAnchor.constraint(equalToConstant: 30),
            windImageView.heightAnchor.constraint(equalToConstant: 30),
            windImageView.widthAnchor.constraint(equalToConstant: 30),
            
            blurElemetnsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            blurElemetnsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            blurElemetnsView.heightAnchor.constraint(equalToConstant: 150),
            blurElemetnsView.widthAnchor.constraint(equalToConstant: 190),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
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

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count: ", weatherForecast.count)
        return weatherForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        
        
        let weather = weatherForecast[indexPath.item]
        cell.configure(with: weather)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionInsets.top
    }
}
