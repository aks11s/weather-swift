import UIKit
import SnapKit

class LocationsViewController: UIViewController, Routing {
    weak var coordinator: Coordinator?

    private let viewModel: LocationsViewModel

    // MARK: - UI

    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(red: 57/255, green: 26/255, blue: 73/255, alpha: 1).cgColor,
            UIColor(red: 48/255, green: 29/255, blue: 92/255, alpha: 1).cgColor,
            UIColor(red: 38/255, green: 33/255, blue: 113/255, alpha: 1).cgColor,
            UIColor(red: 48/255, green: 29/255, blue: 92/255, alpha: 1).cgColor,
            UIColor(red: 57/255, green: 26/255, blue: 73/255, alpha: 1).cgColor
        ]
        g.locations = [0.11, 0.33, 0.57, 0.71, 0.91]
        g.startPoint = CGPoint(x: 1, y: 1)
        g.endPoint = CGPoint(x: 0, y: 0)
        return g
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header — y=78, x=24, width=345
    private let headingLabel: UILabel = {
        let l = UILabel()
        l.text = "Saved Locations"
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.textColor = .white
        return l
    }()

    private let searchButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "icon_search") ?? UIImage(systemName: "magnifyingglass"), for: .normal)
        b.tintColor = .white
        return b
    }()

    // Dynamic cards container (stack of WeatherPreviewCards)
    private var cardViews: [WeatherPreviewCard] = []

    // "Add new" button — 345×59
    private let addButton: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()
    private let addBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let addOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 170/255, green: 165/255, blue: 165/255, alpha: 0.7)
        return v
    }()
    private let addIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "icon_add") ?? UIImage(systemName: "plus")
        iv.tintColor = UIColor.white.withAlphaComponent(0.8)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let addLabel: UILabel = {
        let l = UILabel()
        l.text = "Add new"
        l.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        return l
    }()

    // MARK: - Init

    init(viewModel: LocationsViewModel = LocationsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Скрыть nav bar и отключить swipe back
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupViews() {
        view.layer.insertSublayer(gradientLayer, at: 0)

        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headingLabel)
        contentView.addSubview(searchButton)

        // Add new button
        addButton.addSubview(addBlurView)
        addButton.addSubview(addOverlay)
        addButton.addSubview(addIconView)
        addButton.addSubview(addLabel)
        contentView.addSubview(addButton)

        let addTap = UITapGestureRecognizer(target: self, action: #selector(addNewTapped))
        addButton.addGestureRecognizer(addTap)
    }

    private func setupLayout() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        headingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(86)
            make.left.equalToSuperview().offset(24)
        }
        searchButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(78)
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(32)
        }

        addBlurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        addOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        addIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(108)
            make.width.height.equalTo(24)
        }
        addLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(addIconView.snp.right).offset(8)
        }
    }

    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] state in
            if case .loaded(let locations) = state {
                self?.renderCards(with: locations)
            }
        }
    }

    // MARK: - Dynamic cards

    private func renderCards(with weathers: [Weather]) {
        // Удаляем старые карточки
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews = []

        var previousAnchor: ConstraintItem = headingLabel.snp.bottom

        for (index, weather) in weathers.enumerated() {
            let card = WeatherPreviewCard()
            card.configure(with: weather)
            card.tag = index
            card.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.addGestureRecognizer(tap)

            contentView.addSubview(card)
            card.snp.makeConstraints { make in
                // Первая карточка: y=142 от contentView, остальные: +24 от предыдущей
                if index == 0 {
                    make.top.equalToSuperview().offset(142)
                } else {
                    make.top.equalTo(previousAnchor).offset(24)
                }
                make.left.equalToSuperview().offset(24)
                make.width.equalTo(345)
                make.height.equalTo(153)
            }

            previousAnchor = card.snp.bottom
            cardViews.append(card)
        }

        // "Add new" — всегда ниже последней карточки
        addButton.snp.remakeConstraints { make in
            if cardViews.isEmpty {
                make.top.equalToSuperview().offset(142)
            } else {
                make.top.equalTo(previousAnchor).offset(24)
            }
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(59)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - Actions

    @objc private func addNewTapped() {
        coordinator?.eventOccurred(with: .showSearch)
    }

    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag,
              case .loaded(let weathers) = viewModel.state,
              index < weathers.count
        else { return }
        coordinator?.eventOccurred(with: .showWeather(location: weathers[index].city))
    }
}
