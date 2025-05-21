//
//  MainTableViewCell.swift
//  MVVMRTestWeather
//
//  Created by Егор Ершов on 21.05.2025.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String { "\(Self.self)" }
    
    private lazy var weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var conditionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        weatherIconImageView.image = UIImage(systemName: "xmark.seal")
        dateLabel.text = nil
        conditionDescriptionLabel.text = nil
        detailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCell(with model: ForecastItem) {
        
        weatherIconImageView.downloadImage(from: model.day.condition.icon)
        dateLabel.text = dateFormatter(from: model.date)
        conditionDescriptionLabel.text = model.day.condition.text
        
        let tempView = createDetailView(title: "Temp", value: "\(model.day.temp)", icon: "thermometer.transmission")
        let windView = createDetailView(title: "Wind", value: "\(model.day.wind)", icon: "wind")
        let humidityView = createDetailView(title: "Humidity", value: "\(model.day.humidity) %", icon: "humidity")
        
        detailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        detailsStack.addArrangedSubview(tempView)
        detailsStack.addArrangedSubview(windView)
        detailsStack.addArrangedSubview(humidityView)
        
    }
    
}

private extension MainTableViewCell {
    func addSubviews() {
        contentView.addSubview(weatherIconImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(conditionDescriptionLabel)
        contentView.addSubview(detailsStack)
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            weatherIconImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            weatherIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 32),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            conditionDescriptionLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 10),
            conditionDescriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            detailsStack.topAnchor.constraint(equalTo: conditionDescriptionLabel.bottomAnchor, constant: 20),
            detailsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            detailsStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    func setupView() {
        addSubviews()
        setupConstraints()
        
        contentView.backgroundColor = .systemBlue
        contentView.layer.cornerRadius = 12
    }
    func createDetailView(title: String, value: String, icon: String) -> UIView {
        let view = UIView()
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .cyan
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: view.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            valueLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            valueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    func dateFormatter(from string: String) -> String {
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let nowDateString = formatter.string(from: nowDate)
        if nowDateString == string {
            return "Today"
        }
        let date = formatter.date(from: string)!
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date).capitalized
    }
}
