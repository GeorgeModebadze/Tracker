import UIKit

enum TrackerFilterType: Int {
    case all
    case today
    case completed
    case incompleted
}

protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilterType)
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterSelectionDelegate?
    var currentFilter: TrackerFilterType = .all
    
    private let filters: [String] = [
        NSLocalizedString("filters_all", comment: ""),
        NSLocalizedString("filters_today", comment: ""),
        NSLocalizedString("filters_completed", comment: ""),
        NSLocalizedString("filters_incompleted", comment: "")
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters_title", comment: "")
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3)
        table.layer.cornerRadius = 16
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupTableView()
    }

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = filters[indexPath.row]
        config.textProperties.color = .black
        config.textProperties.font = .systemFont(ofSize: 17)
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        if TrackerFilterType(rawValue: indexPath.row) == currentFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedFilter = TrackerFilterType(rawValue: indexPath.row) else { return }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        }
        
        if let previousCell = tableView.cellForRow(at: IndexPath(row: currentFilter.rawValue, section: 0)),
           previousCell != tableView.cellForRow(at: indexPath) {
            previousCell.accessoryType = .none
        }
        
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
