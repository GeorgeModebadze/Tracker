import UIKit

final class TrackerCategoryViewController: UIViewController {
    
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    private let viewModel = TrackerCategoryViewModel()
    
    private let tableContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .ypWhite
        table.layer.cornerRadius = 16
        table.clipsToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("categories_title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "starholder"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("categories_placeholder_text", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("categories_add_button", comment: ""), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
        viewModel.fetchCategories()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        tableContainer.addSubview(tableView)
        view.addSubview(tableContainer)
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        emptyImageView.isHidden = true
        emptyLabel.isHidden = true
        
        view.addSubview(titleLabel)
        view.addSubview(tableContainer)
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableContainer.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24),
            
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor),
            
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message: message)
        }
    }
    
    private func updateUI() {
        let hasCategories = !viewModel.categories.isEmpty
        tableView.isHidden = !hasCategories
        emptyImageView.isHidden = hasCategories
        emptyLabel.isHidden = hasCategories
        tableView.reloadData()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func setSelectedCategory(title: String) {
        viewModel.selectedCategory = TrackerCategory(title: title, trackers: [])
    }
    
    @objc private func addCategoryTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.setTitle(NSLocalizedString("new_category_title", comment: ""))
        newCategoryVC.onSave = { [weak self] categoryName in
            self?.viewModel.addCategory(named: categoryName)
        }
        present(newCategoryVC, animated: true)
    }
}

extension TrackerCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        let isSelected = viewModel.isCategorySelected(category)
        let isLast = indexPath.row == viewModel.categories.count - 1
        cell.configure(with: category.title, isSelected: isSelected, isLast: isLast)
        
        return cell
    }
}

extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModel.categories[indexPath.row]
        viewModel.selectCategory(selectedCategory)
        onCategorySelected?(selectedCategory)
        tableView.reloadData()
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: NSLocalizedString("cat_menu_edit", comment: "Редактировать")
            ) { [weak self] _ in
                self?.presentEditCategoryScreen(for: category)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("cat_menu_delete", comment: "Удалить"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.showDeleteConfirmation(for: category)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func presentEditCategoryScreen(for category: TrackerCategory) {
        let editVC = NewCategoryViewController()
        editVC.editingCategory = category
        editVC.setTitle(NSLocalizedString("edit_category_title", comment: ""))
        
        editVC.onSave = { [weak self] newTitle in
            self?.viewModel.updateCategory(category, with: newTitle)
        }
        
        present(editVC, animated: true)
    }
    
    private func showDeleteConfirmation(for category: TrackerCategory) {
        let alert = UIAlertController(
            title: NSLocalizedString("cat_delete_alert_title", comment: "Удаление категории"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cat_delete_alert_cancel", comment: "Отмена"),
            style: .cancel
        ))
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cat_delete_alert_delete", comment: "Удалить"),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.deleteCategory(category)
        })
        
        present(alert, animated: true)
    }
}
