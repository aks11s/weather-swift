import UIKit
import SnapKit

class DetailWeatherView: UIView {
    // Figma: column, alignItems=center, gap=4px
    // icon 30×30, label Roboto Medium 14pt, value Roboto Medium 14pt, color white

    private let stackView = UIStackView()
    private let iconView = UIImageView()
    private let labelView = UILabel()
    private let valueStack = UIStackView()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Icon — 30×30 per Figma layout_6O7BG2
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }

        // Section label — Roboto Medium 14pt, style_E1X9LU
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = .white
        labelView.textAlignment = .center
        stackView.addArrangedSubview(labelView)

        // Value row (value + unit)
        valueStack.axis = .horizontal
        valueStack.spacing = 0
        stackView.addArrangedSubview(valueStack)

        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .white
        valueStack.addArrangedSubview(valueLabel)

        unitLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        unitLabel.textColor = .white
        valueStack.addArrangedSubview(unitLabel)
    }

    func configure(icon: String, label: String, value: String, unit: String) {
        // Try asset catalog first (Figma icons), fallback to SF Symbol
        iconView.image = UIImage(named: icon) ?? UIImage(systemName: icon)
        labelView.text = label
        valueLabel.text = value
        unitLabel.text = unit
    }
}
