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
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) {
        do {
            try store.updateCategory(category.title, with: newTitle)
            if selectedCategory?.title == category.title {
                selectedCategory = TrackerCategory(title: newTitle, trackers: category.trackers)
            }
            fetchCategories()
        } catch {
            onError?("Не удалось обновить категорию")
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        do {
            try store.deleteCategory(category.title)
            if selectedCategory?.title == category.title {
                selectedCategory = nil
            }
            fetchCategories()
        } catch {
            onError?("Не удалось удалить категорию")
        }
    }
}

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        fetchCategories()
    }
}
