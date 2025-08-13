import UIKit

final class TabBarController: UITabBarController {
    
    private let trackerRecordStore = TrackerRecordStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let trackerVC = UINavigationController(rootViewController: TrackersViewController())
        let statisticsVC = UINavigationController(rootViewController: StatisticsViewController(recordStore: trackerRecordStore))
        
        trackerVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers_tab", comment: ""),
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        statisticsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics_tab", comment: ""),
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        viewControllers = [trackerVC, statisticsVC]
        
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
    }
}
