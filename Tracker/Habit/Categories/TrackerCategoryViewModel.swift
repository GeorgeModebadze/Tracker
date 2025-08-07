import Foundation

final class TrackerCategoryViewModel {
    
    var categories: [TrackerCategory] = []
    var onCategoriesChanged: (() -> Void)?
    var selectedCategory: TrackerCategory?
    
    private let store: TrackerCategoryStore
    
    init(store: TrackerCategoryStore = TrackerCategoryStore()) {
        self.store = store
    }
    
    func fetchCategories() {
        categories = store.fetchAllCategories()
        onCategoriesChanged?()
    }
    
    func addCategory(named name: String) {
        do {
            try store.addCategory(title: name)
            fetchCategories()
        } catch {
            print("Ошибка при сохранении категории: \(error)")
        }
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
    }
    
    func isCategorySelected(_ category: TrackerCategory) -> Bool {
        selectedCategory?.title == category.title
    }
}
