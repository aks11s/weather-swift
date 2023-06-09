import UIKit
import SnapKit

/// Карточка локации — Figma "Weather Preview Card" (345×153)
class WeatherPreviewCard: UIView {

    // MARK: - UI

    // Background (borderRadius: 24)
    private let blurView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    // City — Roboto Bold 24pt, white, x=16 y=16
    private let cityLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        l.textColor = AppColor.white
        return l
    }()

    // Condition — Roboto Medium 16pt, rgba(255,255,255,0.8), x=16 y=52
    private let conditionLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = AppColor.whiteMuted
        return l
    }()

    // Humidity row — x=16 y=93
    private let humidityStack = UIStackView()
    private let humidityTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Humidity"
        l.font = UIFont.systemFont(ofSize: 16, weight: .light)
        l.textColor = AppColor.whiteMuted
        return l
    }()
    private let humidityValueLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.textColor = AppColor.white
        return l
    }()

    // Wind row — x=16 y=117
    private let windStack = UIStackView()
    private let windTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Wind"
        l.font = UIFont.systemFont(ofSize: 16, weight: .light)
        l.textColor = AppColor.whiteMuted
        return l
    }()
    private let windValueLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.textColor = AppColor.white
        return l
    }()

    // Temperature group — x=203 y=71, 134×57
    private let tempGroupView = UIView()
    private let temperatureLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 48, weight: .medium)
        l.textColor = AppColor.white
        l.textAlignment = .center
        return l
    }()
    // ºC — Sen Bold 24pt, absolute x=96.78 y=0 within tempGroup
    private let celsiusLabel: UILabel = {
        let l = UILabel()
        l.text = "ºC"
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        l.textColor = AppColor.white
        return l
    }()

    // Weather icon — x=273 y=16, 56×56
    private let weatherIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColor.white
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        layer.cornerRadius = 24
        clipsToBounds = true

        addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // City — x=16 y=16
        addSubview(cityLabel)
        cityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
        }

        // Condition — x=16 y=52
        addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(52)
            make.left.equalToSuperview().offset(16)
        }

        // Humidity row — x=16 y=93, gap=4
        humidityStack.axis = .horizontal
        humidityStack.spacing = 4
        humidityStack.addArrangedSubview(humidityTitleLabel)
        humidityStack.addArrangedSubview(humidityValueLabel)
        addSubview(humidityStack)
        humidityStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(93)
            make.left.equalToSuperview().offset(16)
        }

        // Wind row — x=16 y=117, gap=4
        windStack.axis = .horizontal
        windStack.spacing = 4
        windStack.addArrangedSubview(windTitleLabel)
        windStack.addArrangedSubview(windValueLabel)
        addSubview(windStack)
        windStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(117)
            make.left.equalToSuperview().offset(16)
        }

        // Temperature group — x=203 y=71, 134×57
        addSubview(tempGroupView)
        tempGroupView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(71)
            make.left.equalToSuperview().offset(203)
            make.width.equalTo(134)
            make.height.equalTo(57)
        }

        // Temp number — Roboto Medium 48pt, centered in 134pt
        tempGroupView.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1)
            make.left.equalToSuperview()
            make.width.equalTo(134)
            make.height.equalTo(56)
        }

        // ºC — absolute x=96.78 y=0 within tempGroupView
        tempGroupView.addSubview(celsiusLabel)
        celsiusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(97) // ≈ 96.78
        }

        // Weather icon — x=273 y=16, 56×56
        addSubview(weatherIconView)
        weatherIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(273)
            make.width.height.equalTo(56)
        }
    }

    // MARK: - Configure

    func configure(with weather: Weather) {
        cityLabel.text = weather.city.name
        conditionLabel.text = weather.current.condition.description
        humidityValueLabel.text = " \(weather.current.humidity)%"
        windValueLabel.text = " \(Int(weather.current.windSpeed)) km/h"
        temperatureLabel.text = "\(weather.current.temperature)"
        weatherIconView.image = UIImage(systemName: weather.current.condition.sfSymbol)
    }
}
