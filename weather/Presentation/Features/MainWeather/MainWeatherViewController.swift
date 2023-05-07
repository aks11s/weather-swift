import UIKit
import SnapKit

class MainWeatherViewController: UIViewController, Routing {
    let viewModel: MainWeatherViewModel
    weak var coordinator: Coordinator?

    // MARK: - UI Components

    private let backgroundImageView = UIImageView()
    private let darkeningView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let cityLabel = UILabel()
    private let dateLabel = UILabel()
    private let updatedLabel = UILabel()

    // Main weather
    private let temperatureLabel = UILabel()
    private let celsiusLabel = UILabel()
    private let conditionLabel = UILabel()
    private let weatherIconView = UIImageView()

    // Details
    private let humidityView = DetailWeatherView()
    private let windView = DetailWeatherView()
    private let feelsLikeView = DetailWeatherView()

    // Forecast
    private let forecastCollectionView: UICollectionView
    private let menuButton = UIButton()

    init(viewModel: MainWeatherViewModel = MainWeatherViewModel()) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 80, height: 140)
        self.forecastCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupBindings()
    }

    private func setupViews() {
        view.backgroundColor = .white

        // Background
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.backgroundColor = .systemBlue
        view.addSubview(backgroundImageView)

        // Darkening overlay
        darkeningView.backgroundColor = UIColor.black.withAlphaComponent(0.33)
        view.addSubview(darkeningView)

        // Scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // City label
        cityLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        cityLabel.textColor = .white
        contentView.addSubview(cityLabel)

        // Date label
        dateLabel.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)

        // Updated label
        updatedLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        updatedLabel.textColor = .white
        updatedLabel.textAlignment = .center
        contentView.addSubview(updatedLabel)

        // Temperature
        temperatureLabel.font = UIFont.systemFont(ofSize: 86, weight: .medium)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        contentView.addSubview(temperatureLabel)

        // Celsius
        celsiusLabel.text = "ºC"
        celsiusLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        celsiusLabel.textColor = .white
        contentView.addSubview(celsiusLabel)

        // Condition
        conditionLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        conditionLabel.textColor = .white
        contentView.addSubview(conditionLabel)

        // Weather icon
        weatherIconView.contentMode = .scaleAspectFit
        weatherIconView.tintColor = .white
        weatherIconView.backgroundColor = .systemYellow
        weatherIconView.layer.cornerRadius = 47.5
        weatherIconView.clipsToBounds = true
        contentView.addSubview(weatherIconView)

        // Details
        humidityView.configure(icon: "drop.fill", label: "HUMIDITY", value: "56", unit: "%")
        windView.configure(icon: "wind", label: "WIND", value: "4.63", unit: "km/h")
        feelsLikeView.configure(icon: "thermometer", label: "FEELS LIKE", value: "22", unit: "°")

        contentView.addSubview(humidityView)
        contentView.addSubview(windView)
        contentView.addSubview(feelsLikeView)

        // Collection view
        forecastCollectionView.backgroundColor = .clear
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        forecastCollectionView.register(ForecastCell.self, forCellWithReuseIdentifier: "ForecastCell")
        forecastCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(forecastCollectionView)

        // Menu button
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = .white
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        contentView.addSubview(menuButton)
    }

    private func setupLayout() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        darkeningView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // Header layout
        cityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(86)
            make.left.equalToSuperview().offset(24)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        updatedLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // Main weather
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(updatedLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }

        celsiusLabel.snp.makeConstraints { make in
            make.bottom.equalTo(temperatureLabel).offset(30)
            make.left.equalTo(temperatureLabel.snp.right).offset(-20)
        }

        conditionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(-8)
            make.centerX.equalToSuperview()
        }

        weatherIconView.snp.makeConstraints { make in
            make.width.height.equalTo(95)
            make.centerX.equalToSuperview()
            make.top.equalTo(conditionLabel.snp.bottom).offset(12)
        }

        // Details
        let detailWidth = (UIScreen.main.bounds.width - 72) / 3

        humidityView.snp.makeConstraints { make in
            make.top.equalTo(weatherIconView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(detailWidth)
            make.height.equalTo(80)
        }

        windView.snp.makeConstraints { make in
            make.top.height.equalTo(humidityView)
            make.centerX.equalToSuperview()
            make.width.equalTo(detailWidth)
        }

        feelsLikeView.snp.makeConstraints { make in
            make.top.height.equalTo(humidityView)
            make.right.equalToSuperview().offset(-24)
            make.width.equalTo(detailWidth)
        }

        // Forecast
        forecastCollectionView.snp.makeConstraints { make in
            make.top.equalTo(humidityView.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(160)
            make.bottom.equalToSuperview().offset(-40)
        }

        // Menu button
        menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(78)
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(32)
        }
    }

    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] state in
            switch state {
            case .loaded(let weather):
                self?.updateUI(with: weather)
            case .loading:
                print("Loading...")
            case .error(let error):
                print("Error: \(error)")
            case .idle:
                break
            }
        }
    }

    private func updateUI(with weather: Weather) {
        cityLabel.text = weather.city.name
        temperatureLabel.text = "\(weather.current.temperature)"
        conditionLabel.text = weather.current.condition.description
        weatherIconView.image = UIImage(systemName: weather.current.condition.sfSymbol)
        humidityView.configure(
            icon: "drop.fill",
            label: "HUMIDITY",
            value: "\(weather.current.humidity)",
            unit: "%"
        )
        windView.configure(
            icon: "wind",
            label: "WIND",
            value: String(format: "%.2f", weather.current.windSpeed),
            unit: "km/h"
        )
        feelsLikeView.configure(
            icon: "thermometer",
            label: "FEELS LIKE",
            value: "\(weather.current.feelsLike)",
            unit: "°"
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        updatedLabel.text = "Updated \(dateFormatter.string(from: weather.updatedAt))"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MMMM dd"
        dateLabel.text = dayFormatter.string(from: Date())

        forecastCollectionView.reloadData()
    }

    @objc private func menuTapped() {
        coordinator?.eventOccurred(with: .showLocations)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension MainWeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if case .loaded(let weather) = viewModel.state {
            return weather.daily.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCell

        if case .loaded(let weather) = viewModel.state, indexPath.item < weather.daily.count {
            cell.configure(with: weather.daily[indexPath.item])
        }

        return cell
    }
}
