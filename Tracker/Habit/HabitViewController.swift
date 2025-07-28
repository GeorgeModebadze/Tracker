import UIKit

final class HabitViewController: UIViewController {
    
    var onTrackerCreated: ((TrackerCategory) -> Void)?
    
    private var selectedSchedule: Set<String> = [] {
        didSet {
            updateScheduleLabel()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameFieldStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameTextField: UITextField = {
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
    
    private let optionsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryArrow: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scheduleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleArrow: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let cancelButton: UIButton = {
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
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        //        button.backgroundColor = .gray
        button.backgroundColor = UIColor(resource: .ypGray)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
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
        
        view.addSubview(titleLabel)
        view.addSubview(nameFieldStack)
        view.addSubview(optionsBackgroundView)
        view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameFieldStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameFieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameFieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            optionsBackgroundView.topAnchor.constraint(equalTo: nameFieldStack.bottomAnchor, constant: 24),
            optionsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsBackgroundView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryStackView.topAnchor.constraint(equalTo: optionsBackgroundView.topAnchor, constant: 0),
            categoryStackView.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -40),
            //            categoryStackView.heightAnchor.constraint(equalToConstant: 75), //
            
            categoryArrow.centerYAnchor.constraint(equalTo: categoryStackView.centerYAnchor),
            categoryArrow.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: optionsBackgroundView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            categoryButton.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: 0),
            
            separator.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -16),
            separator.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 0),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleStackView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 0),
            scheduleStackView.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor, constant: 16),
            scheduleStackView.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -40),
            scheduleStackView.bottomAnchor.constraint(equalTo: optionsBackgroundView.bottomAnchor, constant: -16),
            scheduleStackView.heightAnchor.constraint(equalToConstant: 75), //
            
            scheduleArrow.centerYAnchor.constraint(equalTo: scheduleStackView.centerYAnchor),
            scheduleArrow.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor, constant: -16),
            
            scheduleButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsBackgroundView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsBackgroundView.trailingAnchor),
            scheduleButton.bottomAnchor.constraint(equalTo: optionsBackgroundView.bottomAnchor),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: "YPGreen",
            emoji: "😪",
            schedule: WeekDay.allCases.map { $0.rawValue }
        )
        
        let category = TrackerCategory(
            title: "Привычки",
            trackers: [newTracker]
        )
        
        onTrackerCreated?(category)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func categoryButtonTapped() {
        print("Категория нажата")
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = selectedSchedule
        scheduleVC.onScheduleSelected = { [weak self] selectedDays in
            self?.selectedSchedule = selectedDays
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
        
        createButton.isEnabled = isNameValid && isScheduleValid
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .gray
    }
}
