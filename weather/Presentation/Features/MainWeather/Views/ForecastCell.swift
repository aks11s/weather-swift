import UIKit
import SnapKit

class ForecastCell: UICollectionViewCell {

    private let stackView = UIStackView()
    private let dayDateLabel = UILabel()
    private let weatherIconView = UIImageView()
    private let tempLabel = UILabel()
    private let windLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        // Фон задаётся родительским контейнером с блюром
        contentView.backgroundColor = AppColor.clear

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        dayDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dayDateLabel.textColor = AppColor.forecastText
        dayDateLabel.textAlignment = .center
        stackView.addArrangedSubview(dayDateLabel)

        weatherIconView.tintColor = AppColor.forecastText
        weatherIconView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(weatherIconView)
        weatherIconView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        tempLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tempLabel.textColor = AppColor.forecastText
        stackView.addArrangedSubview(tempLabel)

        windLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        windLabel.textColor = AppColor.forecastText
        windLabel.textAlignment = .center
        windLabel.numberOfLines = 2
        stackView.addArrangedSubview(windLabel)
    }

    func configure(with daily: DailyWeather) {
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "EEE"
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd"

        // День и число в одну строку
        dayDateLabel.text = "\(dayFmt.string(from: daily.date)) \(dateFmt.string(from: daily.date))"
        tempLabel.text = "\(daily.maxTemp)º"
        windLabel.text = String(format: "%.0f\nkm/h", daily.maxWindSpeed)
        weatherIconView.image = UIImage(systemName: daily.condition.sfSymbol)
    }
}
