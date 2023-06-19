import UIKit
import SnapKit

class SearchViewController: UIViewController, Routing {
    weak var coordinator: Coordinator?

    var onLocationSelected: ((Location) -> Void)?

    private let viewModel: SearchViewModel

    // MARK: - UI

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search city..."
        sb.searchBarStyle = .minimal
        sb.tintColor = AppColor.white
        sb.barTintColor = AppColor.clear
        sb.searchTextField.textColor = AppColor.white
        sb.searchTextField.backgroundColor = AppColor.whiteOverlay
        sb.searchTextField.leftView?.tintColor = AppColor.whiteDim
        sb.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search city...",
            attributes: [.foregroundColor: AppColor.whiteFaint]
        )
        return sb
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = AppColor.clear
        tv.separatorColor = AppColor.whiteOverlay
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = AppColor.white
        ai.hidesWhenStopped = true
        return ai
    }()

    // MARK: - Init

    init(viewModel: SearchViewModel = SearchViewModel()) {
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
        searchBar.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = AppColor.modalBackground

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(8)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
    }

    private func setupBindings() {
        viewModel.resultsDidChange = { [weak self] _ in
            self?.tableView.reloadData()
        }
        viewModel.isLoadingDidChange = { [weak self] loading in
            loading ? self?.activityIndicator.startAnimating()
                    : self?.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true)
    }
}

// MARK: - UITableView

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let location = viewModel.results[indexPath.row]

        cell.backgroundColor = AppColor.clear
        cell.textLabel?.textColor = AppColor.white
        cell.textLabel?.text = [location.name, location.region, location.country]
            .compactMap { $0 }
            .joined(separator: ", ")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let location = viewModel.results[indexPath.row]
        onLocationSelected?(location)
    }
}
