import UIKit

final class TrackersViewController: UIViewController {
    
    private let navButtonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "addTracker"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchField: UITextField = {
        let field = UITextField()
        field.placeholder = "Поиск"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        field.layer.cornerRadius = 10
        
        let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconView.tintColor = .gray
        iconView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        container.addSubview(iconView)
        
        field.leftView = container
        field.leftViewMode = .always
        
        return field
    }()
    
    private let emptyStateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "starHolder")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
        addTopBorderToTabBar()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        navButtonsContainer.addSubview(addButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navButtonsContainer)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(searchField)
        view.addSubview(contentContainer)
        
        emptyStateContainer.addSubview(emptyStateImage)
        emptyStateContainer.addSubview(emptyStateLabel)
        view.addSubview(emptyStateContainer)
    }
    
    private func addTopBorderToTabBar() {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        tabBarController?.tabBar.addSubview(lineView)
        
        guard let tabBar = tabBarController?.tabBar else { return }

        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            lineView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            lineView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            navButtonsContainer.widthAnchor.constraint(equalToConstant: 44),
            navButtonsContainer.heightAnchor.constraint(equalToConstant: 44),
            
            addButton.centerXAnchor.constraint(equalTo: navButtonsContainer.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: navButtonsContainer.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42),
            
            contentContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            emptyStateContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateImage.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImage.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateContainer.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        print("Add button tapped")
    }
    
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        print("Date changed to: \(sender.date)")
    }
}
