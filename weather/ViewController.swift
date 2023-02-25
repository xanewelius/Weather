//
//  ViewController.swift
//  weather
//
//  Created by Max Kuzmin on 24.02.2023.
//

import UIKit

final class ViewController: UIViewController {
    
    private let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        fetchData()
        setupUI()
    }
    
    private let weatherImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cloud")
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
}

private extension ViewController {
    
    func fetchData() {
        networkManager.jsonPars(lat: "44,95300", lon: "34,06413") { weatherData in
            DispatchQueue.main.async {
                guard let weather = weatherData.list.first,
                      let desc = weather.weather.first?.description else { return }
                
                self.labelTemp.text = "\(String(format: "%.2f", weather.main.temp - 273.15))°C"
                self.labelDescriprion.text = "\(desc)"
                self.labelCity.text = (weatherData.city.name)
            }
        }
    }
    func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview (backgroundImage, at: 0)
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(weatherImage)
        view.addSubview(labelDescriprion)
        view.addSubview(labelTemp)
        view.addSubview(labelCity)
        
        NSLayoutConstraint.activate([
            weatherImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            weatherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            labelDescriprion.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: 20),
            labelDescriprion.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labelDescriprion.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            labelTemp.topAnchor.constraint(equalTo: labelDescriprion.bottomAnchor, constant: 25),
            labelTemp.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labelTemp.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            labelCity.topAnchor.constraint(equalTo: labelTemp.bottomAnchor, constant: 20),
            labelCity.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labelCity.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

