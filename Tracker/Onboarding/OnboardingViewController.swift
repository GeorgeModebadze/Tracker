import UIKit

final class OnboardingViewController: UIViewController {
    
    private var pages: [Onboarding] = []
    private var currentPageIndex = 0
    
    private lazy var pageViewController: UIPageViewController = {
        let pageView = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageView.dataSource = self
        pageView.delegate = self
        return pageView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = .lightGray
        control.hidesForSinglePage = true
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupPageViewController()
        setupPageControl()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        setupPages()
    }
    
    private func setupPages() {
        pages = [
            Onboarding(
                title: NSLocalizedString("onboarding_first_page_title", comment: ""),
                imageName: "onboarding1"
            ),
            Onboarding(
                title: NSLocalizedString("onboarding_second_page_title", comment: ""),
                imageName: "onboarding2"
            )
        ]
        pageControl.numberOfPages = pages.count
    }
    
    private func setupPageViewController() {
        guard let firstViewController = makeViewController(for: 0) else { return }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        pageViewController.setViewControllers(
            [firstViewController],
            direction: .forward,
            animated: true
        )
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
    
    private func makeViewController(for index: Int) -> OnboardingUIPageViewController? {
        guard pages.indices.contains(index) else { return nil }
        
        let model = pages[index]
        let viewController = OnboardingUIPageViewController(model: model)
        viewController.delegate = self
        return viewController
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingUIPageViewController,
              let currentIndex = pages.firstIndex(where: { $0.title == currentVC.model?.title }) else {
            return nil
        }
        return makeViewController(for: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingUIPageViewController,
              let currentIndex = pages.firstIndex(where: { $0.title == currentVC.model?.title }) else {
            return nil
        }
        return makeViewController(for: currentIndex + 1)
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? OnboardingUIPageViewController,
              let currentIndex = pages.firstIndex(where: { $0.title == currentVC.model?.title }) else {
            return
        }
        currentPageIndex = currentIndex
        pageControl.currentPage = currentIndex
    }
}

extension OnboardingViewController: OnboardingUIPageViewControllerDelegate {
    func didCompleteOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        
        let tabBarController = TabBarController()
        guard let window = view.window else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        })
    }
}
