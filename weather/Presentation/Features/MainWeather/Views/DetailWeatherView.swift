import UIKit
import SnapKit

class DetailWeatherView: UIView {
    private let stackView = UIStackView()
    private let iconView = UIImageView()
    private let labelView = UILabel()
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

        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }

        labelView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = .white
        labelView.textAlignment = .center
        stackView.addArrangedSubview(labelView)

        let valueStack = UIStackView()
        valueStack.axis = .horizontal
        valueStack.spacing = 0
        stackView.addArrangedSubview(valueStack)

        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = .white
        valueStack.addArrangedSubview(valueLabel)

        unitLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        unitLabel.textColor = .white
        valueStack.addArrangedSubview(unitLabel)
    }

    func configure(icon: String, label: String, value: String, unit: String) {
        iconView.image = UIImage(systemName: icon)
        labelView.text = label
        valueLabel.text = value
        unitLabel.text = unit
    }
}
