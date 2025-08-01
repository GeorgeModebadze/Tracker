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
        
        let weekDays: [WeekDay] = tracker.schedule.compactMap { WeekDay(rawValue: $0) }
        cdTracker.schedule = try? JSONEncoder().encode(weekDays) as NSData
        
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
                  let color = coreData.color,
                  let scheduleData = coreData.schedule as? Data,
                  let weekDays = try? JSONDecoder().decode([WeekDay].self, from: scheduleData) else {
                return nil
            }
            
            return Tracker(
                id: id,
                name: name,
                color: color,
                emoji: coreData.emoji ?? "",
                schedule: weekDays.map { $0.rawValue }
            )
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
