import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func fetchTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let trackers = try context.fetch(request)
            return trackers.compactMap { cdTracker in
                guard let id = cdTracker.id,
                      let name = cdTracker.name,
                      let color = cdTracker.color else {
                    return nil
                }
                
                let schedule: [String] = (cdTracker.value(forKey: "schedule") as? Data).flatMap {
                    try? JSONDecoder().decode([String].self, from: $0)
                } ?? []
                
                return Tracker(
                    id: id,
                    name: name,
                    color: color,
                    emoji: cdTracker.emoji ?? "",
                    schedule: schedule
                )
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    func addTracker(_ tracker: Tracker, categoryTitle: String) -> Bool {
        let cdTracker = TrackerCoreData(context: context)
        cdTracker.id = tracker.id
        cdTracker.name = tracker.name
        cdTracker.color = tracker.color
        cdTracker.emoji = tracker.emoji
        
        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        let category: TrackerCategoryCoreData
        if let existingCategory = try? context.fetch(categoryRequest).first {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = categoryTitle
        }
        
        cdTracker.category = category
        
        do {
            let scheduleData = try JSONEncoder().encode(tracker.schedule)
            cdTracker.setValue(scheduleData as NSData, forKey: "schedule")
        } catch {
            print("Failed to encode schedule: \(error)")
        }
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            print("Failed to save tracker: \(error)")
            return false
        }
    }
    
    func updateTracker(_ oldTracker: Tracker, with newTracker: Tracker, categoryTitle: String) -> Bool {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", oldTracker.id as CVarArg)
        
        do {
            guard let trackerToUpdate = try context.fetch(request).first else { return false }
            
            trackerToUpdate.name = newTracker.name
            trackerToUpdate.color = newTracker.color
            trackerToUpdate.emoji = newTracker.emoji
            
            let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
            
            let category: TrackerCategoryCoreData
            if let existingCategory = try context.fetch(categoryRequest).first {
                category = existingCategory
            } else {
                category = TrackerCategoryCoreData(context: context)
                category.title = categoryTitle
            }
            
            trackerToUpdate.category = category
            
            let scheduleData = try JSONEncoder().encode(newTracker.schedule)
            trackerToUpdate.setValue(scheduleData as NSData, forKey: "schedule")
            
            try context.save()
//            delegate?.didUpdateTrackers()
            return true
        } catch {
            print("Ошибка обновления трекера: \(error)")
            context.rollback()
            return false
        }
    }
    
    func deleteTracker(_ tracker: Tracker) -> Bool {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            guard let trackerToDelete = try context.fetch(request).first else { return false }
            
            context.delete(trackerToDelete)
            try context.save()
//            delegate?.didUpdateTrackers()
            return true
        } catch {
            print("Ошибка удаления трекера: \(error)")
            context.rollback()
            return false
        }
    }
    
    func getCategory(for tracker: Tracker) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            guard let tracker = try context.fetch(request).first else { return nil }
            return tracker.category
        } catch {
            print("Ошибка получения категории: \(error)")
            return nil
        }
    }
    
    func fetchTrackersGroupedByCategory() -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let categories = try context.fetch(request)
            return categories.compactMap { category in
                guard let title = category.title,
                      let trackersSet = category.trackers,
                      let cdTrackers = trackersSet.allObjects as? [TrackerCoreData] else {
                    return nil
                }
                
                let sortedTrackers = cdTrackers.sorted { ($0.name ?? "") < ($1.name ?? "") }
                    .compactMap { cdTracker -> Tracker? in
                        guard let id = cdTracker.id,
                              let name = cdTracker.name,
                              let color = cdTracker.color else {
                            return nil
                        }
                        
                        let schedule: [String] = (cdTracker.value(forKey: "schedule") as? Data).flatMap {
                            try? JSONDecoder().decode([String].self, from: $0)
                        } ?? []
                        
                        return Tracker(
                            id: id,
                            name: name,
                            color: color,
                            emoji: cdTracker.emoji ?? "",
                            schedule: schedule
                        )
                    }
                
                return TrackerCategory(title: title, trackers: sortedTrackers)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func printAllTrackersInDatabase() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // Добавляем сортировку
        
        do {
            let trackers = try context.fetch(request)
            print("-Trackers in Database (sorted by name)-")
            trackers.forEach {
                let schedule = ($0.value(forKey: "schedule") as? Data).flatMap {
                    try? JSONDecoder().decode([String].self, from: $0)
                } ?? []
                print("ID: \($0.id?.uuidString ?? "nil"), Name: \($0.name ?? "nil"), Schedule: \(schedule)")
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
//        try? fetchedResultsController.performFetch()
    }
}
