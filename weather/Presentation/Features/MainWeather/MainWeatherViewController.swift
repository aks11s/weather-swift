import UIKit
import SnapKit

enum MainWeatherMode {
    case normal
    case preview(location: Location, storage: LocationStorageProtocol)
}

class MainWeatherViewController: UIViewController, Routing {
    let viewModel: MainWeatherViewModel
    weak var coordinator: Coordinator?

    private let mode: MainWeatherMode

    // MARK: - UI Components

    private let backgroundImageView = UIImageView()
    private let darkeningView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header (y=78)
    private let pinIconView = UIImageView()
    private let cityLabel = UILabel()
    private let menuButton = UIButton(type: .custom)

    // Date/Updated (y=171, y=227)
    private let dateLabel = UILabel()
    private let updatedLabel = UILabel()

    // Main weather block (y=276, column, gap=-8)
    private let weatherIconView = UIImageView()
    private let conditionLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let celsiusLabel = UILabel()

    // Details (y=565)
    private let humidityView = DetailWeatherView()
    private let windView = DetailWeatherView()
    private let feelsLikeView = DetailWeatherView()

    // Forecast (y=663, shared blur background)
    private let forecastBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    private let forecastOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 83/255, green: 83/255, blue: 83/255, alpha: 0.3)
        return v
    }()
    private let forecastCollectionView: UICollectionView

    init(viewModel: MainWeatherViewModel = MainWeatherViewModel(), mode: MainWeatherMode = .normal) {
        self.viewModel = viewModel
        self.mode = mode

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 19, bottom: 16, right: 17)
        layout.itemSize = CGSize(width: 68, height: 121)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = .black

        // Background photo
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)

        // Darkening overlay — rgba(0,0,0,0.33) per Figma
        darkeningView.backgroundColor = UIColor.black.withAlphaComponent(0.33)
        view.addSubview(darkeningView)

        // Scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Pin icon (location.fill or asset)
        pinIconView.image = UIImage(named: "icon_location") ?? UIImage(systemName: "location.fill")
        pinIconView.tintColor = .white
        pinIconView.contentMode = .scaleAspectFit
        contentView.addSubview(pinIconView)

        // City label — Roboto Regular 18pt
        cityLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        cityLabel.textColor = .white
        contentView.addSubview(cityLabel)

        // Menu / Add / Cancel button
        menuButton.tintColor = .white
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        contentView.addSubview(menuButton)
        configureMenuButton()

        // Date — Roboto Medium 40pt
        dateLabel.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)

        // Updated — Roboto Light 16pt
        updatedLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        updatedLabel.textColor = .white
        updatedLabel.textAlignment = .center
        contentView.addSubview(updatedLabel)

        // Weather icon — 95×95
        weatherIconView.contentMode = .scaleAspectFit
        weatherIconView.tintColor = .white
        contentView.addSubview(weatherIconView)

        // Condition — Roboto Bold 40pt
        conditionLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        conditionLabel.textColor = .white
        conditionLabel.textAlignment = .center
        contentView.addSubview(conditionLabel)

        // Temperature — Roboto Medium 86pt
        temperatureLabel.font = UIFont.systemFont(ofSize: 86, weight: .medium)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        contentView.addSubview(temperatureLabel)

        // ºC — Sen Bold 24pt (mapped to system bold)
        celsiusLabel.text = "ºC"
        celsiusLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        celsiusLabel.textColor = .white
        contentView.addSubview(celsiusLabel)

        // Details
        humidityView.configure(icon: "icon_humidity", label: "HUMIDITY", value: "56", unit: "%")
        windView.configure(icon: "icon_wind", label: "WIND", value: "4.63", unit: "km/h")
        feelsLikeView.configure(icon: "icon_feelslike", label: "FEELS LIKE", value: "22", unit: "°")
        contentView.addSubview(humidityView)
        contentView.addSubview(windView)
        contentView.addSubview(feelsLikeView)

        // Forecast container — blur + overlay
        contentView.addSubview(forecastBlurView)
        forecastBlurView.contentView.addSubview(forecastOverlay)

        // Forecast collection view
        forecastCollectionView.backgroundColor = .clear
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        forecastCollectionView.register(ForecastCell.self, forCellWithReuseIdentifier: "ForecastCell")
        forecastCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(forecastCollectionView)
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

        // MARK: Header — y=78
        pinIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(78)
            make.left.equalToSuperview().offset(24)
            make.width.height.equalTo(32)
        }

        cityLabel.snp.makeConstraints { make in
            make.centerY.equalTo(pinIconView)
            make.left.equalTo(pinIconView.snp.right).offset(4) // 24+32+4=60 ≈ Figma x=60.26
        }

        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(pinIconView)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(32)
        }

        // MARK: Date — y=171, Updated — y=227
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(171)
            make.centerX.equalToSuperview()
        }

        updatedLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(227)
            make.centerX.equalToSuperview()
        }

        // MARK: Main weather block — y=276, column gap=-8
        // Order: Icon → Condition → Temperature (gap=-8 between each)
        weatherIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(276)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(95)
        }

        conditionLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherIconView.snp.bottom).offset(-8)
            make.centerX.equalToSuperview()
        }

        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(conditionLabel.snp.bottom).offset(-8)
            make.centerX.equalToSuperview()
            make.width.equalTo(134) // Figma: fixed width 134.3
        }

        // ºC: absolute x=118, y=10 within Value_temp frame
        celsiusLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel).offset(10)
            make.left.equalTo(temperatureLabel.snp.left).offset(118)
        }

        // MARK: Details — y=565, height=80
        // Figma positions within Details frame (left offset 24 from screen):
        // Humidity x=0, Wind x=150, FeelsLike x=273
        humidityView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(565)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(115)  // 345 / 3
            make.height.equalTo(80)
        }

        windView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(565)
            make.left.equalToSuperview().offset(139)        // 24 + 115
            make.width.equalTo(115)
            make.height.equalTo(80)
        }

        feelsLikeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(565)
            make.left.equalToSuperview().offset(254)        // 24 + 230
            make.width.equalTo(115)
            make.height.equalTo(80)
        }

        // MARK: Forecast — y=663, width=345, height=153
        forecastBlurView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(663)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(153)
            make.bottom.equalToSuperview().offset(-36) // sets contentView height = 852
        }

        forecastOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        forecastCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(forecastBlurView)
        }
    }

    // MARK: - Bindings

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
            icon: "icon_humidity",
            label: "HUMIDITY",
            value: "\(weather.current.humidity)",
            unit: "%"
        )
        windView.configure(
            icon: "icon_wind",
            label: "WIND",
            value: String(format: "%.2f", weather.current.windSpeed),
            unit: "km/h"
        )
        feelsLikeView.configure(
            icon: "icon_feelslike",
            label: "FEELS LIKE",
            value: "\(weather.current.feelsLike)",
            unit: "°"
        )

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "MMMM dd"
        dateLabel.text = dateFmt.string(from: Date())

        let updatedFmt = DateFormatter()
        updatedFmt.dateFormat = "M/d/yyyy h:mm a"
        updatedLabel.text = "Updated as of \(updatedFmt.string(from: weather.updatedAt))"

        forecastCollectionView.reloadData()
    }

    private func configureMenuButton() {
        switch mode {
        case .normal:
            menuButton.setImage(UIImage(named: "icon_menu") ?? UIImage(systemName: "line.3.horizontal"), for: .normal)
            menuButton.setTitle(nil, for: .normal)
        case .preview(let location, let storage):
            let isSaved = storage.load().contains(where: { $0.id == location.id })
            let title = isSaved ? "Cancel" : "Add"
            menuButton.setImage(nil, for: .normal)
            menuButton.setTitle(title, for: .normal)
            menuButton.setTitleColor(.white, for: .normal)
            menuButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }

    @objc private func menuTapped() {
        switch mode {
        case .normal:
            coordinator?.eventOccurred(with: .showLocations)
        case .preview(let location, let storage):
            let isSaved = storage.load().contains(where: { $0.id == location.id })
            if isSaved {
                dismiss(animated: true)
            } else {
                storage.add(location)
                // Закрыть и превью, и SearchVC одновременно
                presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UICollectionView

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
