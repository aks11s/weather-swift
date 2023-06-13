import UIKit
import SnapKit

class LocationsViewController: UIViewController, Routing, UIGestureRecognizerDelegate {
    weak var coordinator: Coordinator?

    private let viewModel: LocationsViewModel

    // MARK: - UI

    private let backgroundImageView = UIImageView()

    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            AppColor.gradientTop.cgColor,
            AppColor.gradientMid.cgColor,
            AppColor.gradientBottom.cgColor,
            AppColor.gradientMid.cgColor,
            AppColor.gradientTop.cgColor
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
        l.textColor = AppColor.white
        return l
    }()

    private let searchButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "icon_search") ?? UIImage(systemName: "magnifyingglass"), for: .normal)
        b.tintColor = AppColor.white
        return b
    }()

    private let searchBar: UISearchBar = {
        let s = UISearchBar()
        s.placeholder = "Search cities..."
        s.searchBarStyle = .minimal
        s.barTintColor = AppColor.clear
        s.backgroundColor = AppColor.clear
        s.tintColor = AppColor.white
        s.clipsToBounds = true
        if let tf = s.value(forKey: "searchField") as? UITextField {
            tf.textColor = AppColor.white
            tf.attributedPlaceholder = NSAttributedString(
                string: "Search cities...",
                attributes: [.foregroundColor: AppColor.whiteFaint]
            )
        }
        return s
    }()

    private var searchBarHeightConstraint: Constraint?

    // Dynamic cards container (stack of WeatherPreviewCards)
    private var cardViews: [WeatherPreviewCard] = []
    private var containerViews: [UIView] = []
    private var currentlySwipedIndex: Int?

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
        v.backgroundColor = AppColor.cardBackground
        return v
    }()
    private let addIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "icon_add") ?? UIImage(systemName: "plus")
        iv.tintColor = AppColor.whiteMuted
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let addLabel: UILabel = {
        let l = UILabel()
        l.text = "Add new"
        l.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        l.textColor = AppColor.whiteMuted
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
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        viewModel.load() // перезагрузить после добавления нового города
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
        // Background image — выбор по времени суток
        backgroundImageView.image = UIImage(named: TimeTheme.backgroundImageName())
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)

        view.layer.insertSublayer(gradientLayer, at: 0)

        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headingLabel)
        contentView.addSubview(searchButton)
        contentView.addSubview(searchBar)
        searchBar.delegate = self

        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)

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
        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }

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

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(headingLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            searchBarHeightConstraint = make.height.equalTo(0).constraint
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
        containerViews.forEach { $0.removeFromSuperview() }
        cardViews = []
        containerViews = []
        currentlySwipedIndex = nil

        var previousAnchor: ConstraintItem = searchBar.snp.bottom

        for (index, weather) in weathers.enumerated() {
            // Container — красный фон при свайпе (удаление)
            let container = UIView()
            container.backgroundColor = AppColor.deleteRed
            container.layer.cornerRadius = 24
            container.clipsToBounds = true
            contentView.addSubview(container)
            container.snp.makeConstraints { make in
                make.top.equalTo(previousAnchor).offset(24)
                make.left.equalToSuperview().offset(24)
                make.width.equalTo(345)
                make.height.equalTo(153)
            }

            // Иконка корзины (справа в контейнере)
            let trashIcon = UIImageView(image: UIImage(systemName: "trash"))
            trashIcon.tintColor = AppColor.white
            trashIcon.contentMode = .scaleAspectFit
            container.addSubview(trashIcon)
            trashIcon.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-24)
                make.width.height.equalTo(24)
            }

            // Прозрачная кнопка удаления (правые 80pt контейнера)
            let deleteButton = UIButton()
            deleteButton.tag = index
            deleteButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
            container.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { make in
                make.right.top.bottom.equalToSuperview()
                make.width.equalTo(80)
            }

            // Карточка поверх (скользит влево, открывая красный фон)
            let card = WeatherPreviewCard()
            card.configure(with: weather)
            card.tag = index
            card.isUserInteractionEnabled = true
            container.addSubview(card)
            card.snp.makeConstraints { $0.edges.equalToSuperview() }

            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(_:)))
            pan.delegate = self
            card.addGestureRecognizer(pan)

            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.addGestureRecognizer(tap)

            containerViews.append(container)
            cardViews.append(card)
            previousAnchor = container.snp.bottom
        }

        let addButtonTopAnchor: ConstraintItem = containerViews.isEmpty ? searchBar.snp.bottom : previousAnchor
        addButton.snp.remakeConstraints { make in
            make.top.equalTo(addButtonTopAnchor).offset(24)
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(345)
            make.height.equalTo(59)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - Swipe helpers

    private func openCard(at index: Int) {
        guard index < cardViews.count else { return }
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3) {
            self.cardViews[index].transform = CGAffineTransform(translationX: -80, y: 0)
        }
        currentlySwipedIndex = index
    }

    private func closeCard(at index: Int) {
        guard index < cardViews.count else { return }
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3) {
            self.cardViews[index].transform = .identity
        }
        if currentlySwipedIndex == index { currentlySwipedIndex = nil }
    }

    // MARK: - Actions

    private var isSearchActive = false

    @objc private func searchTapped() {
        isSearchActive = !isSearchActive
        searchBarHeightConstraint?.update(offset: isSearchActive ? 44 : 0)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.contentView.layoutIfNeeded()
        }

        if isSearchActive {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.text = nil
            searchBar.resignFirstResponder()
            viewModel.filter(by: "")
        }
    }

    @objc private func addNewTapped() {
        coordinator?.eventOccurred(with: .showSearch)
    }

    @objc private func handleCardPan(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view else { return }
        let index = card.tag
        let translation = gesture.translation(in: card.superview)

        switch gesture.state {
        case .began:
            if let prev = currentlySwipedIndex, prev != index { closeCard(at: prev) }

        case .changed:
            card.transform = CGAffineTransform(translationX: min(0, translation.x), y: 0)

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: card.superview)
            if translation.x < -60 || velocity.x < -500 {
                openCard(at: index)
            } else {
                closeCard(at: index)
            }

        default:
            break
        }
    }

    @objc private func deleteTapped(_ sender: UIButton) {
        let index = sender.tag
        guard case .loaded(let weathers) = viewModel.state, index < weathers.count else { return }
        let locationId = weathers[index].city.id
        let container = containerViews[index]

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            container.alpha = 0
            container.transform = CGAffineTransform(translationX: -345, y: 0)
        }) { _ in
            self.viewModel.removeLocation(id: locationId)
        }
    }

    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }

        if currentlySwipedIndex == index {
            closeCard(at: index)
            return
        }

        guard case .loaded(let weathers) = viewModel.state, index < weathers.count else { return }
        coordinator?.eventOccurred(with: .showWeather(location: weathers[index].city))
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LocationsViewController {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: pan.view)
        return abs(velocity.x) > abs(velocity.y)
    }
}

// MARK: - UISearchBarDelegate

extension LocationsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(by: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
