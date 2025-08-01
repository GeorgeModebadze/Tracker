import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
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
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        if let trackerId = trackerId {
            request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        }
        
        do {
            return try context.fetch(request).compactMap { coreData in
                guard let trackerId = coreData.tracker?.id,
                      let date = coreData.date else {
                    return nil
                }
                return TrackerRecord(trackerId: trackerId, date: date)
            }
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    func deleteRecord(trackerId: UUID, date: Date) -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            trackerId as CVarArg,
            date as CVarArg
        )
        
        do {
            if let record = try context.fetch(request).first {
                context.delete(record)
                try context.save()
                return true
            }
            return false
        } catch {
            context.rollback()
            print("Failed to delete record: \(error)")
            return false
        }
    }
}
