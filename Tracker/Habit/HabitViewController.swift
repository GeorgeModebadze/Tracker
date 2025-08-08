import UIKit

final class HabitViewController: UIViewController {
    
    var onTrackerCreated: ((TrackerCategory) -> Void)?
    
    private var selectedSchedule: Set<String> = [] {
        didSet {
            updateScheduleLabel()
        }
    }
    
    private let trackerStore = TrackerStore()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameFieldStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3)
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var optionsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryArrow: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scheduleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleArrow: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .ypGray)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiCollectionView: EmojiCollectionView = {
        let collection = EmojiCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: ColorCollectionView = {
        let collection = ColorCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
        
        emojiCollectionView.onSelectionChanged = { [weak self] in
            self?.updateCreateButtonState()
        }
        
        colorCollectionView.onSelectionChanged = { [weak self] in
            self?.updateCreateButtonState()
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(buttonsStackView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        
        emojiCollectionView.allowsSelection = true
        emojiCollectionView.allowsMultipleSelection = false
        colorCollectionView.allowsSelection = true
        colorCollectionView.allowsMultipleSelection = false
        
        contentView.addSubview(titleLabel)
        
        nameFieldStack.addArrangedSubview(nameTextField)
        nameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        categoryStackView.addArrangedSubview(categoryLabel)
        categoryStackView.addArrangedSubview(categoryValueLabel)
        
        scheduleStackView.addArrangedSubview(scheduleLabel)
        scheduleStackView.addArrangedSubview(scheduleValueLabel)
        
        optionsBackgroundView.addSubview(categoryStackView)
        optionsBackgroundView.addSubview(categoryArrow)
        optionsBackgroundView.addSubview(categoryButton)
        optionsBackgroundView.addSubview(separator)
        optionsBackgroundView.addSubview(scheduleStackView)
        optionsBackgroundView.addSubview(scheduleArrow)
        optionsBackgroundView.addSubview(scheduleButton)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        contentView.addSubview(nameFieldStack)
        contentView.addSubview(optionsBackgroundView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
    }
    
    private func setupConstraints() {
        
        let emojiCount = emojiCollectionView.numberOfItems(inSection: 0)
        let emojiRows = Int(ceil(Double(emojiCount) / 6.0))
        let emojiItemSize = (view.bounds.width - 56 - 25) / 6
        let emojiHeight = CGFloat(emojiRows) * emojiItemSize + CGFloat(emojiRows - 1) * 5 + 32
        
        let colorCount = colorCollectionView.numberOfItems(inSection: 0)
        let colorRows = Int(ceil(Double(colorCount) / 6.0))
        let colorItemSize = (view.bounds.width - 56 - 25) / 6
        let colorHeight = CGFloat(colorRows) * colorItemSize + CGFloat(colorRows - 1) * 5 + 32
        
        NSLayoutConstraint.activate([
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameFieldStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameFieldStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameFieldStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            optionsBackgroundView.topAnchor.constraint(equalTo: nameFieldStack.bottomAnchor, constant: 24),
            optionsBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsBackgroundView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryStackView.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor, constant: 16),
            categoryStackView.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            
            categoryArrow.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -16),
            categoryArrow.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            
            categoryButton.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor),
            categoryButton.topAnchor.constraint(equalTo: optionsBackgroundView.topAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            separator.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -16),
            separator.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            
            scheduleStackView.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor, constant: 16),
            scheduleStackView.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
            
            scheduleArrow.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -16),
            scheduleArrow.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
            
            scheduleButton.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor),
            scheduleButton.bottomAnchor.constraint(equalTo: optionsBackgroundView.bottomAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            
            emojiLabel.topAnchor.constraint(equalTo: optionsBackgroundView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: emojiHeight),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            colorCollectionView.heightAnchor.constraint(equalToConstant: colorHeight),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let emoji = emojiCollectionView.selectedEmoji,
              let colorName = colorCollectionView.selectedColorName,
              let categoryTitle = categoryValueLabel.text, !categoryTitle.isEmpty else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: colorName,
            emoji: emoji,
            schedule: Array(selectedSchedule)
        )
        
        let category = TrackerCategory(title: categoryTitle, trackers: [newTracker])
        onTrackerCreated?(category)
        dismiss(animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func categoryButtonTapped() {
        print("Категория нажата")
        let categoriesVC = TrackerCategoryViewController()
        
        if let currentCategory = categoryValueLabel.text, !currentCategory.isEmpty {
            categoriesVC.setSelectedCategory(title: currentCategory)
        }
        
        categoriesVC.onCategorySelected = { [weak self] category in
            self?.categoryValueLabel.text = category.title
            self?.categoryValueLabel.textColor = .gray
            self?.updateCreateButtonState()
        }
        let navController = UINavigationController(rootViewController: categoriesVC)
        present(navController, animated: true)
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = selectedSchedule
        scheduleVC.onScheduleSelected = { [weak self] selectedDays in
            self?.selectedSchedule = selectedDays
            self?.updateCreateButtonState()
        }
        present(scheduleVC, animated: true)
        print("Расписание нажата")
    }
    
    private func updateScheduleLabel() {
        if selectedSchedule.isEmpty {
            scheduleValueLabel.text = nil
        } else if selectedSchedule.count == WeekDay.allCases.count {
            scheduleValueLabel.text = "Каждый день"
        } else {
            let sortedDays = WeekDay.allCases
                .filter { selectedSchedule.contains($0.rawValue) }
                .sorted { $0.order < $1.order }
            scheduleValueLabel.text = sortedDays.map { $0.shortName }.joined(separator: ", ")
        }
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isScheduleValid = !selectedSchedule.isEmpty
        let isEmojiSelected = emojiCollectionView.selectedEmoji != nil
        let isColorSelected = colorCollectionView.selectedColorName != nil
        let isCategorySelected = !(categoryValueLabel.text?.isEmpty ?? true)
        
        createButton.isEnabled = isNameValid && isScheduleValid && isEmojiSelected && isColorSelected && isCategorySelected
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .gray
    }
}
