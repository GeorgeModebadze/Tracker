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
                
                let trackers = cdTrackers.compactMap { cdTracker -> Tracker? in
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
                
                return TrackerCategory(title: title, trackers: trackers)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func printAllTrackersInDatabase() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let trackers = try context.fetch(request)
            print("-Trackers in Database-")
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
    }
}
