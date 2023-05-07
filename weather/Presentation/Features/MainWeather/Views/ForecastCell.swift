import UIKit
import SnapKit

class ForecastCell: UICollectionViewCell {
    // Figma: column layout, items top-to-bottom:
    // "Wed 16" (14pt) → icon (40×40) → "22º" (16pt) → "1-5 km/h" (10pt)
    // Color: #ECECEC per Figma fill_Z39B6L

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
        // No individual background — shared blur container handles it
        contentView.backgroundColor = .clear

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        // "Wed 16" — Roboto Regular 14pt, #ECECEC
        dayDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dayDateLabel.textColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        dayDateLabel.textAlignment = .center
        stackView.addArrangedSubview(dayDateLabel)

        // Weather icon — 40×40
        weatherIconView.tintColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        weatherIconView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(weatherIconView)
        weatherIconView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        // Temperature — Roboto Regular 16pt, #ECECEC
        tempLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tempLabel.textColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        stackView.addArrangedSubview(tempLabel)

        // Wind — Roboto Regular 10pt, 2 lines, #ECECEC
        windLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        windLabel.textColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        windLabel.textAlignment = .center
        windLabel.numberOfLines = 2
        stackView.addArrangedSubview(windLabel)
    }

    func configure(with daily: DailyWeather) {
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "EEE"
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd"

        // "Wed 16" on one line per Figma
        dayDateLabel.text = "\(dayFmt.string(from: daily.date)) \(dateFmt.string(from: daily.date))"
        tempLabel.text = "\(daily.maxTemp)º"
        windLabel.text = String(format: "%.0f\nkm/h", daily.maxWindSpeed)
        weatherIconView.image = UIImage(systemName: daily.condition.sfSymbol)
    }
}
