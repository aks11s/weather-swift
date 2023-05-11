import UIKit
import SnapKit

class LocationsViewController: UIViewController, Routing {
    weak var coordinator: Coordinator?

    private let viewModel: LocationsViewModel

    // MARK: - UI

    // Background gradient (226deg: #391A49 → #301D5C → #262171 → #301D5C → #391A49)
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

    // Weather cards — y=142, y=319, y=496
    private let card1 = WeatherPreviewCard()
    private let card2 = WeatherPreviewCard()
    private let card3 = WeatherPreviewCard()

    // "Add new" button — y=673, 345×59
    private let addButton: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()
    private let addBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return view
    }()
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

        // Header
        contentView.addSubview(headingLabel)
        contentView.addSubview(searchButton)

        // Cards
        [card1, card2, card3].forEach { contentView.addSubview($0) }

        // Add new button
        addButton.addSubview(addBlurView)
        addButton.addSubview(addOverlay)
        addButton.addSubview(addIconView)
        addButton.addSubview(addLabel)
        contentView.addSubview(addButton)
    }

    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // Header — x=24 y=78, width=345 height=32
        headingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(86) // y=78 + 8 (text baseline offset)
            make.left.equalToSuperview().offset(24)
        }
        searchButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(78)
            make.right.equalToSuperview().offset(-24) // 393-337-32=24
            make.width.height.equalTo(32)
        }

        // Cards — y=142, y=319, y=496 (each 345×153)
        card1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(142)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(153)
        }
        card2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(319)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(153)
        }
        card3.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(496)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(153)
        }

        // Add new button — y=673, 345×59
        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(673)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(59)
            make.bottom.equalToSuperview().offset(-120)
        }
        addBlurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        addOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        // Add icon — x=108 y=12, 24×24
        addIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(108)
            make.width.height.equalTo(24)
        }
        // "Add new" text — x=140 y=12
        addLabel.snp.makeConstraints { make in
            make.centerY.equalTo(addIconView)
            make.left.equalTo(addIconView.snp.right).offset(8)
        }
    }

    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] state in
            if case .loaded(let locations) = state {
                self?.updateCards(with: locations)
            }
        }
    }

    private func updateCards(with locations: [Weather]) {
        let cards = [card1, card2, card3]
        zip(cards, locations).forEach { card, weather in
            card.configure(with: weather)
        }
    }
}
