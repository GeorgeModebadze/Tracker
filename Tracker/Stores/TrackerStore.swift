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
    
    func addTracker(_ tracker: Tracker) -> Bool {
        let cdTracker = TrackerCoreData(context: context)
        cdTracker.id = tracker.id
        cdTracker.name = tracker.name
        cdTracker.color = tracker.color
        cdTracker.emoji = tracker.emoji.isEmpty ? nil : tracker.emoji
        
        do {
            let scheduleData = try JSONEncoder().encode(tracker.schedule)
            cdTracker.setValue(scheduleData as NSData, forKey: "schedule")
            print("Schedule saved: \(tracker.schedule)")
        } catch {
            print("Failed to encode schedule: \(error)")
            cdTracker.setValue(nil, forKey: "schedule")
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
    
    func fetchTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        
        return objects.compactMap { coreData in
            guard let id = coreData.id,
                  let name = coreData.name,
                  let color = coreData.color else {
                return nil
            }
            
            let schedule: [String]
            if let scheduleData = coreData.value(forKey: "schedule") as? Data {
                do {
                    schedule = try JSONDecoder().decode([String].self, from: scheduleData)
                } catch {
                    print("Failed to decode schedule: \(error)")
                    schedule = []
                }
            } else {
                schedule = []
            }
            
            return Tracker(
                id: id,
                name: name,
                color: color,
                emoji: coreData.emoji ?? "",
                schedule: schedule
            )
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
