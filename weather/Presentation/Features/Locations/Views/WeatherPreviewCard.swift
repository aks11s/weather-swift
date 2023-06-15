import UIKit
import SnapKit

/// Карточка с кратким превью погоды для выбранного города
class WeatherPreviewCard: UIView {

    // MARK: - UI

    private let blurView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    // Название города
    private let cityLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        l.textColor = AppColor.white
        return l
    }()

    // Описание погоды
    private let conditionLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = AppColor.whiteMuted
        return l
    }()

    // Ряд с влажностью
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

    // Ряд с ветром
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

    // Блок температуры
    private let tempGroupView = UIView()
    private let temperatureLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 48, weight: .medium)
        l.textColor = AppColor.white
        l.textAlignment = .center
        return l
    }()
    // Знак градуса
    private let celsiusLabel: UILabel = {
        let l = UILabel()
        l.text = "ºC"
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        l.textColor = AppColor.white
        return l
    }()

    // Иконка погоды
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

        addSubview(cityLabel)
        cityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
        }

        addSubview(conditionLabel)
        conditionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(52)
            make.left.equalToSuperview().offset(16)
        }

        humidityStack.axis = .horizontal
        humidityStack.spacing = 4
        humidityStack.addArrangedSubview(humidityTitleLabel)
        humidityStack.addArrangedSubview(humidityValueLabel)
        addSubview(humidityStack)
        humidityStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(93)
            make.left.equalToSuperview().offset(16)
        }

        windStack.axis = .horizontal
        windStack.spacing = 4
        windStack.addArrangedSubview(windTitleLabel)
        windStack.addArrangedSubview(windValueLabel)
        addSubview(windStack)
        windStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(117)
            make.left.equalToSuperview().offset(16)
        }

        addSubview(tempGroupView)
        tempGroupView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(71)
            make.left.equalToSuperview().offset(203)
            make.width.equalTo(134)
            make.height.equalTo(57)
        }

        tempGroupView.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1)
            make.left.equalToSuperview()
            make.width.equalTo(134)
            make.height.equalTo(56)
        }

        tempGroupView.addSubview(celsiusLabel)
        celsiusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(97)
        }

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
