import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    override init() {
        self.context = CoreDataStack.shared.context
        super.init()
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let categories = try context.fetch(request)
        return categories.compactMap { category in
            let title = category.title ?? NSLocalizedString("uncategorized", comment: "")
            let cdTrackers = (category.trackers?.allObjects as? [TrackerCoreData]) ?? []
            
            let trackers = cdTrackers.compactMap { cdTracker -> Tracker? in
                guard let id = cdTracker.id,
                      let name = cdTracker.name,
                      let color = cdTracker.color else {
                    return nil
                }
                
                let schedule: [String] = {
                    guard let scheduleString = cdTracker.scheduleString else { return [] }
                    return scheduleString.components(separatedBy: ",")
                }()
                
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
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let categories = try context.fetch(request)
            return categories.compactMap { category in
                let title = category.title ?? NSLocalizedString("uncategorized", comment: "")
                let trackers = (category.trackers?.allObjects as? [TrackerCoreData])?.compactMap { $0.toTracker() } ?? []
                return TrackerCategory(title: title, trackers: trackers)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func fetchCategoryCoreData(with title: String) throws -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    func addCategory(title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
        delegate?.didUpdateCategories()
    }
    
    func updateCategory(_ oldTitle: String, with newTitle: String) throws {
        guard let category = try fetchCategoryCoreData(with: oldTitle) else {
            throw NSError(domain: "Category not found", code: 404)
        }
        
        category.title = newTitle
        try context.save()
        delegate?.didUpdateCategories()
    }
    
    func deleteCategory(_ title: String) throws {
        guard let category = try fetchCategoryCoreData(with: title) else {
            throw NSError(domain: "Category not found", code: 404)
        }
        
        context.delete(category)
        try context.save()
        delegate?.didUpdateCategories()
    }
}

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = self.id,
              let name = self.name,
              let color = self.color else {
            return nil
        }
        
        let schedule: [String] = {
            guard let scheduleString = self.scheduleString else { return [] }
            return scheduleString.components(separatedBy: ",")
        }()
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: self.emoji ?? "",
            schedule: schedule
        )
    }
}
