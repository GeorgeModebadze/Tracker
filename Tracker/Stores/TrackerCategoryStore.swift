import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
        try? fetchedResultsController.performFetch()
    }
    
    func addCategory(title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        let count = try context.count(for: request)
        
        if count > 0 {
            throw NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "Категория уже существует"])
        }
        
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try context.save()
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        guard let categories = fetchedResultsController.fetchedObjects else { return [] }
        return categories.compactMap {
            guard let title = $0.title else { return nil }
            return TrackerCategory(
                title: title,
                trackers: $0.trackers?.allObjects.compactMap { $0 as? Tracker } ?? []
            )
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
