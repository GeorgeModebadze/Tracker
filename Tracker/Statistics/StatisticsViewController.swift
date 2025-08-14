import UIKit

final class StatisticsViewController: UIViewController {
    
    private let statisticsService: StatisticsService
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_title", comment: "")
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateView: UIStackView = {
        let imageView = UIImageView(image: UIImage(named: "cry"))
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = NSLocalizedString("no_stat_ph", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var statCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var statValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var statDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("statistics_completed_label", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    init(recordStore: TrackerRecordStore) {
        self.statisticsService = StatisticsService(recordStore: recordStore)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientBorderToCard()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(titleLabel)
        view.addSubview(emptyStateView)
        view.addSubview(statCardView)
        
        statCardView.addSubview(statValueLabel)
        statCardView.addSubview(statDescriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statCardView.heightAnchor.constraint(equalToConstant: 90),
            
            statValueLabel.topAnchor.constraint(equalTo: statCardView.topAnchor, constant: 12),
            statValueLabel.leadingAnchor.constraint(equalTo: statCardView.leadingAnchor, constant: 12),
            
            statDescriptionLabel.topAnchor.constraint(equalTo: statValueLabel.bottomAnchor, constant: 7),
            statDescriptionLabel.leadingAnchor.constraint(equalTo: statCardView.leadingAnchor, constant: 12)
        ])
    }
    
    private func updateUI() {
        let completedCount = statisticsService.getCompletedTrackersCount()
        
        if completedCount == 0 {
            emptyStateView.isHidden = false
            statCardView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            statCardView.isHidden = false
            statValueLabel.text = "\(completedCount)"
        }
    }
    
    private func addGradientBorderToCard() {
        statCardView.layer.sublayers?
            .filter { $0.name == "gradientBorder" }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradient = CAGradientLayer()
        gradient.name = "gradientBorder"
        gradient.frame = statCardView.bounds
        gradient.colors = [
            UIColor(hex: "#FD4C49").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#007BFA").cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16
        
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.path = UIBezierPath(roundedRect: statCardView.bounds, cornerRadius: 16).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        statCardView.layer.insertSublayer(gradient, at: 0)
    }
}
