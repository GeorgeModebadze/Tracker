import UIKit

final class TrackersViewController: UIViewController {
    
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    private var categories: [TrackerCategory] {
        return trackerStore.fetchTrackersGroupedByCategory()
    }
    
    private var completedTrackers: [TrackerRecord] {
        return recordStore.fetchAllRecords()
    }
    
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
//        picker.locale = Locale(identifier: "ru_RU")
        picker.locale = Locale.current
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
        
        print("Загружено трекеров: \(trackerStore.fetchTrackers().count)")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeader.reuseIdentifier
        )
        
        trackerStore.delegate = self
        recordStore.delegate = self
        
        collectionView.delegate = self
        
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
                if tracker.schedule.isEmpty {
                    return true
                }
                
                let trackerWeekdays = tracker.schedule.compactMap { WeekDay(rawValue: $0) }
                return trackerWeekdays.contains(weekdayEnum)
            }
            collectionView.reloadData()
            emptyStateContainer.isHidden = !filteredCategories.isEmpty
            
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
            print("Пытаемся сохранить \(newCategory.trackers.count) трекеров")
            var successCount = 0
            for tracker in newCategory.trackers {
                if self.trackerStore.addTracker(tracker, categoryTitle: newCategory.title) {
                    successCount += 1
                }
            }
            print("Успешно сохранено \(successCount) трекеров")
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
        
        collectionView.visibleCells.forEach { cell in
            if let indexPath = collectionView.indexPath(for: cell) {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: "Редактировать"
            ) { [weak self] _ in
                self?.editTracker(tracker)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteTracker(tracker)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        let habitVC = HabitViewController()
        habitVC.editingTracker = tracker
        habitVC.modalPresentationStyle = .automatic
        
        habitVC.onTrackerCreated = { [weak self] updatedCategory in
            guard let self = self,
                  let updatedTracker = updatedCategory.trackers.first else {
                return
            }
            
            let success = self.trackerStore.updateTracker(tracker, with: updatedTracker, categoryTitle: updatedCategory.title)
        }
        
        present(habitVC, animated: true)
    }
    
    private func confirmDeleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: "Уверены, что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) { [weak self] _ in
            self?.trackerStore.deleteTracker(tracker)
        })
        
        alert.addAction(UIAlertAction(
            title: "Отменить",
            style: .cancel
        ))
        
        present(alert, animated: true)
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
        
        let allRecords = recordStore.fetchRecords(for: tracker.id)
        
        let isCompleted = allRecords.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }
        
        let completedCount = allRecords.count
        
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            count: completedCount,
            isEnabled: !(currentDate > Date())
        )
        
        
        
        cell.onToggle = { [weak self] in
            guard let self = self else { return }
            
            if self.currentDate > Date() {
                return
            }
            
            if isCompleted {
                let success = self.recordStore.removeRecord(trackerId: tracker.id, date: self.currentDate)
                if success {
                    print("Record removed for date: \(self.currentDate)")
                }
            } else {
                let success = self.recordStore.addRecord(trackerId: tracker.id, date: self.currentDate)
                if success {
                    print("Record added for date: \(self.currentDate)")
                }
            }
            
            DispatchQueue.main.async {
                collectionView.reloadItems(at: [indexPath])
            }
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

extension Array where Element == Tracker {
    func groupedByCategory() -> [TrackerCategory] {
        var categoriesDict = [String: [Tracker]]()
        
        for tracker in self {
            let categoryTitle = (tracker as? TrackerCoreData)?.category?.title ?? "Без категории"
            
            if categoriesDict[categoryTitle] == nil {
                categoriesDict[categoryTitle] = [tracker]
            } else {
                categoriesDict[categoryTitle]?.append(tracker)
            }
        }
        
        return categoriesDict.map { key, value in
            TrackerCategory(title: key, trackers: value)
        }.sorted { $0.title < $1.title }
    }
}

extension TrackersViewController: TrackerStoreDelegate, TrackerRecordStoreDelegate {
    func didUpdateTrackers() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Обновление трекеров после изменения")
            self.filterTrackers(for: self.currentDate)
            self.collectionView.reloadData()
        }
    }
    
    func didUpdateRecords() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.visibleCells.forEach { cell in
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
}
