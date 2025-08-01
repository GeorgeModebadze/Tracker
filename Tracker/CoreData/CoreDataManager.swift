import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

extension CoreDataManager {
    // MARK: - Trackers
    func saveTracker(_ tracker: Tracker, to category: TrackerCategory) -> Bool {
        let cdCategory = category.toCoreData(in: context)
        let cdTracker = tracker.toCoreData(context: context)
        cdTracker.category = cdCategory
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to save tracker: \(error)")
            context.rollback()
            return false
        }
    }
    
    func fetchTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { Tracker(from: $0) }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    // MARK: - Categories
    func fetchCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.map { TrackerCategory(from: $0) }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    // MARK: - Records
    func addRecord(_ record: TrackerRecord, for trackerId: UUID) -> Bool {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            guard let tracker = try context.fetch(request).first else {
                print("Tracker not found")
                return false
            }
            
            let cdRecord = record.toCoreData(context: context, tracker: tracker)
            try context.save()
            return true
        } catch {
            print("Failed to save record: \(error)")
            context.rollback()
            return false
        }
    }
    
    func fetchRecords() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { TrackerRecord(from: $0) }
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
}
