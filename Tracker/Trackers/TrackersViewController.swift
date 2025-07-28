import UIKit

final class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Привычки", trackers: [])
    ]
    
    var completedTrackers: [TrackerRecord] = []
    
    private var currentDate = Date()
    
    private var filteredCategories: [TrackerCategory] = []
    
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
        field.borderStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.layer.cornerRadius = 10
        field.layer.masksToBounds = true
        field.backgroundColor = .borderGray
        
        field.leftViewMode = .always
        field.rightViewMode = .always
        field.clearButtonMode = .whileEditing
        
        let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconView.tintColor = .gray
        iconView.contentMode = .scaleAspectFit
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
        iconView.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        container.addSubview(iconView)
        
        field.leftView = container
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.rightView = paddingView
        field.rightViewMode = .always
        
        return field
    }()
    
    private let emptyStateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "starholder")
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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
        addTopBorderToTabBar()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeader.reuseIdentifier
        )
        
        filterTrackers(for: currentDate)
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        navButtonsContainer.addSubview(addButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navButtonsContainer)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(searchField)
        contentContainer.addSubview(collectionView)
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
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    
    private func filterTrackers(for date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekdayEnum = WeekDay.allCases[(weekday + 5) % 7]
        
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let trackerWeekdays = tracker.schedule.compactMap { WeekDay(rawValue: $0) }
                return trackerWeekdays.contains(weekdayEnum)
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
        
        collectionView.reloadData()
        emptyStateContainer.isHidden = !filteredCategories.isEmpty
    }
    
    @objc private func addButtonTapped() {
        let habitVC = HabitViewController()
        habitVC.modalPresentationStyle = .automatic
        
        habitVC.onTrackerCreated = { [weak self] newCategory in
            guard let self else { return }
            
            var updatedCategories = self.categories
            
            if let index = updatedCategories.firstIndex(where: { $0.title == newCategory.title }) {
                let existingTrackers = updatedCategories[index].trackers
                let updatedTrackers = existingTrackers + newCategory.trackers
                updatedCategories[index] = TrackerCategory(
                    title: newCategory.title,
                    trackers: updatedTrackers
                )
            } else {
                updatedCategories.append(newCategory)
            }
            
            self.categories = updatedCategories
            self.filterTrackers(for: self.currentDate)
        }
        
        present(habitVC, animated: true)
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        print("Выбранная дата: \(formattedDate)")
        filterTrackers(for: currentDate)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let calendar = Calendar.current
        
        let isCompleted = completedTrackers.contains {
            $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: currentDate)
        }
        
        let completedCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        let isFutureDate = currentDate > Date()
        
        let isEnabled = !isFutureDate
        
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            count: completedCount,
            isEnabled: isEnabled
        )
        
        cell.onToggle = { [weak self] in
            guard let self = self else { return }
            
            if self.currentDate > Date() {
                return
            }
            
            var newCompletedTrackers = self.completedTrackers
            
            if isCompleted {
                newCompletedTrackers.removeAll {
                    $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: self.currentDate)
                }
            } else {
                newCompletedTrackers.append(TrackerRecord(trackerId: tracker.id, date: self.currentDate))
            }
            
            self.completedTrackers = newCompletedTrackers
            collectionView.reloadItems(at: [indexPath])
        }
        
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 8) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeader.reuseIdentifier,
                for: indexPath
              ) as? TrackerHeader else {
            return UICollectionReusableView()
        }
        
        let category = filteredCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 32)
    }
}
