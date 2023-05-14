//
//  TodayForecastCollectionViewCell.swift
//  weather
//
//  Created by Max Kuzmin on 14.05.2023.
//

import UIKit

class TodayForecastCollectionViewCell: UICollectionViewCell {
    
    private let iconModel = IconModel()
    private let viewController = ViewController()
    
    let weatherImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let tempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-Medium", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 10
        view.layer.opacity = 0.3
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateInfo: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Montserrat-Light", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with list: ResponseBody.ListResponse) {
        tempLabel.text = "\(String(format: "%.0f", list.main.temp - 273.15))°C"
        weatherImage.image = self.iconModel.fetchImage(icon: list.weather.first!.icon, id: Int(list.weather.first!.id))
        dateInfo.text = "\(viewController.dateFormatter(date: list, format: "HH:mm"))"
    }
}

private extension TodayForecastCollectionViewCell {
    func configureView() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        //contentView.backgroundColor = .systemGray6
        contentView.insertSubview(blurView, at: 0)
        contentView.addSubview(dateInfo)
        contentView.addSubview(weatherImage)
        contentView.addSubview(tempLabel)
        
        layout()
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalToConstant: 120),
            blurView.widthAnchor.constraint(equalToConstant: 100),
            
            dateInfo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            dateInfo.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 5),
            
            weatherImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            weatherImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -5),
            weatherImage.heightAnchor.constraint(equalToConstant: 25),
            weatherImage.widthAnchor.constraint(equalToConstant: 25),
            
            tempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            tempLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
    }
}
