import Foundation

final class TrackerCategoryViewModel {
    
    var categories: [TrackerCategory] = []
        var onCategoriesChanged: (() -> Void)?
        var onError: ((String) -> Void)?
        var selectedCategory: TrackerCategory?
        
        private let store: TrackerCategoryStore
        
        init(store: TrackerCategoryStore = TrackerCategoryStore()) {
            self.store = store
            store.delegate = self
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
                onError?("Не удалось сохранить категорию")
            }
        }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
    }
    
    func isCategorySelected(_ category: TrackerCategory) -> Bool {
        selectedCategory?.title == category.title
    }
}

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        fetchCategories()
    }
}
