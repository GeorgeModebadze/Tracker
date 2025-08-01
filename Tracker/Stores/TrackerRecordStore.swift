import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    weak var delegate: TrackerRecordStoreDelegate?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
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
    
    // MARK: - Public Methods
    func addRecord(trackerId: UUID, date: Date) -> Bool {
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            guard let tracker = try context.fetch(trackerRequest).first else {
                print("Tracker not found")
                return false
            }
            
            let record = TrackerRecordCoreData(context: context)
            record.date = date
            record.tracker = tracker
            
            try context.save()
            return true
        } catch {
            context.rollback()
            print("Failed to add record: \(error)")
            return false
        }
    }
    
    func fetchRecords(for trackerId: UUID? = nil) -> [TrackerRecord] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        
        let filtered = trackerId == nil ? objects : objects.filter { $0.tracker?.id == trackerId }
        
        return filtered.compactMap { coreData in
            guard let trackerId = coreData.tracker?.id,
                  let date = coreData.date else {
                return nil
            }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
//    func removeRecord(trackerId: UUID, date: Date) -> Bool {
//        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
//        let calendar = Calendar.current
//        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
//        
//        do {
//            if let record = try context.fetch(request).first(where: { record in
//                guard let recordDate = record.date else { return false }
//                return calendar.isDate(recordDate, inSameDayAs: date)
//            }) {
//                context.delete(record)
//                try context.save()
//                return true
//            }
//            return false
//        } catch {
//            context.rollback()
//            print("Failed to remove record: \(error)")
//            return false
//        }
//    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
