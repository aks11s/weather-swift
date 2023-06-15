import UIKit
import SnapKit

class DetailWeatherView: UIView {

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

        // Иконка
        iconView.tintColor = AppColor.white
        iconView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }

        // Подпись раздела
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = AppColor.white
        labelView.textAlignment = .center
        stackView.addArrangedSubview(labelView)

        // Значение + единица измерения
        valueStack.axis = .horizontal
        valueStack.spacing = 0
        stackView.addArrangedSubview(valueStack)

        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = AppColor.white
        valueStack.addArrangedSubview(valueLabel)

        unitLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        unitLabel.textColor = AppColor.white
        valueStack.addArrangedSubview(unitLabel)
    }

    func configure(icon: String, label: String, value: String, unit: String) {
        // Сначала ищем в Assets, если нет — берём SF Symbol
        iconView.image = UIImage(named: icon) ?? UIImage(systemName: icon)
        labelView.text = label
        valueLabel.text = value
        unitLabel.text = unit
    }
}
