import UIKit

final class TrackersViewController: UIViewController {
    
    private var selectedFilter: TrackerFilterType = .all
    
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    private var categories: [TrackerCategory] {
        return trackerStore.fetchTrackersGroupedByCategory()
    }
    
    private var completedTrackers: [TrackerRecord] {
        return recordStore.fetchAllRecords()
    }
    
    private enum EmptyState {
        case noTrackers
        case searchNoResults
        case none
    }
    
    private var emptyState: EmptyState = .none {
        didSet {
            updateEmptyState()
        }
    }
    
    private var currentDate = Date()
    
    private var filteredCategories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var isSearching = false
    private var cancelButtonWidth: NSLayoutConstraint?
    
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
        label.text = NSLocalizedString("trackers_tab", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("search_cancel_button", comment: ""), for: .normal)
        button.isHidden = true
        button.alpha = 0
        button.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.placeholder = NSLocalizedString("search_placeholder", comment: "")
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
        label.text = NSLocalizedString("empty_trackers_ph", comment: "")
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
    
    private let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("filters_button", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = UIColor(resource: .blueBackground)
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
        addTopBorderToTabBar()
        
        print("Загружено трекеров: \(trackerStore.fetchTrackers().count)")
        
        if categories.isEmpty {
            emptyState = .noTrackers
        } else {
            emptyState = .none
        }
        
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
        searchField.delegate = self
        
        visibleCategories = filteredCategories
        
        collectionView.delegate = self
        
        filterTrackers(for: currentDate)
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        navButtonsContainer.addSubview(addButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navButtonsContainer)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        searchStackView.addArrangedSubview(searchField)
        searchStackView.addArrangedSubview(cancelButton)
        
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(searchStackView)
        contentContainer.addSubview(collectionView)
        view.addSubview(contentContainer)
        
        emptyStateContainer.addSubview(emptyStateImage)
        emptyStateContainer.addSubview(emptyStateLabel)
        view.addSubview(emptyStateContainer)
        
        view.addSubview(filtersButton)
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
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        
        cancelButtonWidth = cancelButton.widthAnchor.constraint(equalToConstant: 0)
        cancelButtonWidth?.isActive = true
        
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
            
            searchStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchStackView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            searchStackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            searchStackView.heightAnchor.constraint(equalToConstant: 36),
            
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
            collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        collectionView.contentInset.bottom = 74
        collectionView.verticalScrollIndicatorInsets.bottom = 74
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        searchField.addTarget(self, action: #selector(searchFieldDidBeginEditing), for: .editingDidBegin)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
    }
    
    private func updateEmptyState() {
        //        let hasTrackers = !categories.isEmpty
        let hasTrackersOnDate = trackersExist(on: currentDate) > 0
        let hasVisibleTrackers = !visibleCategories.isEmpty
        
        switch emptyState {
        case .noTrackers:
            emptyStateImage.image = UIImage(named: "starholder")
            emptyStateLabel.text = NSLocalizedString("empty_trackers_ph", comment: "")
            emptyStateContainer.isHidden = false
            //            filtersButton.isHidden = true
            filtersButton.isHidden = !hasTrackersOnDate
        case .searchNoResults:
            emptyStateImage.image = UIImage(named: "nothing")
            emptyStateLabel.text = NSLocalizedString("filters_nothing_found", comment: "")
            emptyStateContainer.isHidden = false
            filtersButton.isHidden = !hasTrackersOnDate
        case .none:
            emptyStateContainer.isHidden = true
            filtersButton.isHidden = !hasTrackersOnDate
        }
        
        let isFilterActive = selectedFilter != .all && selectedFilter != .today
        let titleColor: UIColor = isFilterActive ? .red : .white
        filtersButton.setTitleColor(titleColor, for: .normal)
    }
    
    private func filterTrackers(for date: Date, searchText: String? = nil) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekdayEnum = WeekDay.allCases[(weekday + 5) % 7]
        
        let filtered = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let dayFilter: Bool
                if tracker.schedule.isEmpty {
                    dayFilter = true
                } else {
                    let trackerWeekdays = tracker.schedule.compactMap { WeekDay(rawValue: $0) }
                    dayFilter = trackerWeekdays.contains(weekdayEnum)
                }
                
                let searchFilter: Bool
                if let searchText = searchText, !searchText.isEmpty {
                    searchFilter = tracker.name.lowercased().contains(searchText.lowercased())
                } else {
                    searchFilter = true
                }
                
                let stateFilter: Bool
                switch selectedFilter {
                case .all, .today:
                    stateFilter = true
                case .completed:
                    stateFilter = isTrackerCompleted(tracker.id, on: date)
                case .incompleted:
                    stateFilter = !isTrackerCompleted(tracker.id, on: date)
                }
                
                return dayFilter && searchFilter && stateFilter
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
        
        visibleCategories = filtered
        
        if let searchText = searchText, !searchText.isEmpty {
            emptyState = visibleCategories.isEmpty ? .searchNoResults : .none
        } else {
            emptyState = visibleCategories.isEmpty ? .noTrackers : .none
        }
        
        collectionView.reloadData()
        emptyStateContainer.isHidden = !visibleCategories.isEmpty
    }
    
    private func performSearch(with text: String) {
        isSearching = !text.isEmpty
        filterTrackers(for: currentDate, searchText: text)
    }
    
    private func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        return recordStore.fetchRecords(for: trackerId, date: date).count > 0
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
    
    private func showCancelButton() {
        cancelButton.isHidden = false
        let buttonWidth = cancelButton.intrinsicContentSize.width + 12
        
        cancelButtonWidth?.constant = buttonWidth
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.cancelButton.alpha = 1
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private func searchFieldDidBeginEditing() {
        guard cancelButton.isHidden else { return }
        
        isSearching = true
        showCancelButton()
    }
    
    @objc private func cancelSearch() {
        searchField.text = ""
        searchField.resignFirstResponder()
        isSearching = false
        filterTrackers(for: currentDate)
        hideCancelButton()
    }
    
    private func hideCancelButton() {
        cancelButtonWidth?.constant = 0
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.cancelButton.alpha = 0
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.cancelButton.isHidden = true
        })
    }
    
    @objc private func filtersButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.currentFilter = selectedFilter
        present(filterVC, animated: true)
    }
    
    private func trackersExist(on date: Date) -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekdayEnum = WeekDay.allCases[(weekday + 5) % 7]
        
        return categories.reduce(0) { count, category in
            count + category.trackers.filter { tracker in
                tracker.schedule.isEmpty || tracker.schedule.compactMap { WeekDay(rawValue: $0) }.contains(weekdayEnum)
            }.count
        }
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        //        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: NSLocalizedString("trackers_context_menu_edit", comment: "")
            ) { [weak self] _ in
                self?.editTracker(tracker)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("trackers_context_menu_delete", comment: ""),
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
            title: NSLocalizedString("delete_tracker_alert", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("delete_tracker_alert_delete", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            self?.trackerStore.deleteTracker(tracker)
        })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("delete_tracker_alert_cancel", comment: ""),
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //        return filteredCategories.count
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return filteredCategories[section].trackers.count
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        //        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
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
        
        //        let category = filteredCategories[indexPath.section]
        let category = visibleCategories[indexPath.section]
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
            let categoryTitle = (tracker as? TrackerCoreData)?.category?.title ?? NSLocalizedString("uncategorized", comment: "")
            
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
        print("didUpdateTrackers вызван")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Обновление трекеров после изменения")
            //            self.filterTrackers(for: self.currentDate)
            //            self.collectionView.reloadData()
            if self.isSearching, let searchText = self.searchField.text {
                self.filterTrackers(for: self.currentDate, searchText: searchText)
            } else {
                self.filterTrackers(for: self.currentDate)
            }
        }
    }
    
    func didUpdateRecords() {
        print("didUpdateRecords вызван")
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

extension TrackersViewController: UISearchTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        performSearch(with: newText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        performSearch(with: "")
        return true
    }
}

extension TrackersViewController: FilterSelectionDelegate {
    func didSelectFilter(_ filter: TrackerFilterType) {
        selectedFilter = filter
        
        if filter == .today {
            let today = Date()
            currentDate = today
            datePicker.date = today
        }
        
        filterTrackers(for: currentDate)
    }
}
