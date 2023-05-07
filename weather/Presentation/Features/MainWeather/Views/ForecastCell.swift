import UIKit
import SnapKit

class ForecastCell: UICollectionViewCell {
    private let stackView = UIStackView()
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()
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
        contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        dayLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dayLabel.textColor = .white
        stackView.addArrangedSubview(dayLabel)

        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = .white
        stackView.addArrangedSubview(dateLabel)

        weatherIconView.tintColor = .white
        weatherIconView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(weatherIconView)
        weatherIconView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        tempLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tempLabel.textColor = .white
        stackView.addArrangedSubview(tempLabel)

        windLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        windLabel.textColor = .white
        windLabel.textAlignment = .center
        windLabel.numberOfLines = 2
        stackView.addArrangedSubview(windLabel)
    }

    func configure(with daily: DailyWeather) {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"

        dayLabel.text = dayFormatter.string(from: daily.date)
        dateLabel.text = dateFormatter.string(from: daily.date)
        tempLabel.text = "\(daily.maxTemp)°"
        windLabel.text = String(format: "%.1f\nkm/h", daily.maxWindSpeed)
        weatherIconView.image = UIImage(systemName: daily.condition.sfSymbol)
    }
}
