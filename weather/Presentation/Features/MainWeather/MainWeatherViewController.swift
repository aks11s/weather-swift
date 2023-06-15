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

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = AppColor.white
        ai.hidesWhenStopped = true
        return ai
    }()

    // Шапка
    private let pinIconView = UIImageView()
    private let cityLabel = UILabel()
    private let menuButton = UIButton(type: .custom)

    // Дата
    private let dateLabel = UILabel()

    // Основной блок погоды
    private let weatherIconView = UIImageView()
    private let conditionLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let celsiusLabel = UILabel()

    // Детали погоды
    private let humidityView = DetailWeatherView()
    private let windView = DetailWeatherView()
    private let feelsLikeView = DetailWeatherView()

    // Прогноз
    private let forecastBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    private let forecastOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.forecastOverlay
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
        view.backgroundColor = AppColor.black

        // Background photo — выбор по времени суток
        backgroundImageView.image = UIImage(named: TimeTheme.backgroundImageName())
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)

        // Тёмный оверлей поверх фото
        darkeningView.backgroundColor = AppColor.blackOverlay
        view.addSubview(darkeningView)

        view.addSubview(activityIndicator)

        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Иконка локации
        pinIconView.image = UIImage(named: "icon_location") ?? UIImage(systemName: "location.fill")
        pinIconView.tintColor = AppColor.white
        pinIconView.contentMode = .scaleAspectFit
        contentView.addSubview(pinIconView)

        // Название города
        cityLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        cityLabel.textColor = AppColor.white
        contentView.addSubview(cityLabel)

        // Кнопка меню / добавить / отмена
        menuButton.tintColor = AppColor.white
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        contentView.addSubview(menuButton)
        configureMenuButton()

        // Дата
        dateLabel.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        dateLabel.textColor = AppColor.white
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)

        // Иконка погоды
        weatherIconView.contentMode = .scaleAspectFit
        weatherIconView.tintColor = AppColor.white
        contentView.addSubview(weatherIconView)

        // Описание погоды
        conditionLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        conditionLabel.textColor = AppColor.white
        conditionLabel.textAlignment = .center
        contentView.addSubview(conditionLabel)

        // Температура
        temperatureLabel.font = UIFont.systemFont(ofSize: 86, weight: .medium)
        temperatureLabel.textColor = AppColor.white
        temperatureLabel.textAlignment = .center
        contentView.addSubview(temperatureLabel)

        // Знак градуса
        celsiusLabel.text = "ºC"
        celsiusLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        celsiusLabel.textColor = AppColor.white
        contentView.addSubview(celsiusLabel)

        humidityView.configure(icon: "icon_humidity", label: "HUMIDITY", value: "56", unit: "%")
        windView.configure(icon: "icon_wind", label: "WIND", value: "4.63", unit: "km/h")
        feelsLikeView.configure(icon: "icon_feelslike", label: "FEELS LIKE", value: "22", unit: "°")
        contentView.addSubview(humidityView)
        contentView.addSubview(windView)
        contentView.addSubview(feelsLikeView)

        // Контейнер прогноза с блюром
        contentView.addSubview(forecastBlurView)
        forecastBlurView.contentView.addSubview(forecastOverlay)

        forecastCollectionView.backgroundColor = AppColor.clear
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

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // MARK: - Шапка
        pinIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(78)
            make.left.equalToSuperview().offset(24)
            make.width.height.equalTo(32)
        }

        cityLabel.snp.makeConstraints { make in
            make.centerY.equalTo(pinIconView)
            make.left.equalTo(pinIconView.snp.right).offset(4)
        }

        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(pinIconView)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(32)
        }

        // MARK: - Дата
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(171)
            make.centerX.equalToSuperview()
        }

        // MARK: - Основной блок погоды
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
        }

        celsiusLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel).offset(8)
            make.left.equalTo(temperatureLabel.snp.right).offset(2)
        }

        // MARK: - Детали
        humidityView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(565)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(115)
            make.height.equalTo(80)
        }

        windView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(565)
            make.left.equalToSuperview().offset(139)
            make.width.equalTo(115)
            make.height.equalTo(80)
        }

        feelsLikeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(565)
            make.left.equalToSuperview().offset(254)
            make.width.equalTo(115)
            make.height.equalTo(80)
        }

        // MARK: - Прогноз
        forecastBlurView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(663)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(153)
            make.bottom.equalToSuperview().offset(-36)
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
                self?.activityIndicator.stopAnimating()
                self?.updateUI(with: weather)
            case .loading:
                self?.activityIndicator.startAnimating()
            case .error(let error):
                self?.activityIndicator.stopAnimating()
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
            menuButton.setTitleColor(AppColor.white, for: .normal)
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
