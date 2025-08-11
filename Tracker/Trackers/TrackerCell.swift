import UIKit

final class TrackerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    
    var onToggle: (() -> Void)?
    var tracker: Tracker?
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let trackerNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPWhite")
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let trackerCounterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YPBlack")
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(named: "YPWhite")
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, count: Int, isEnabled: Bool = true) {
        self.tracker = tracker
        
        let background = UIColor(named: tracker.color)
        cardView.backgroundColor = background
        emojiView.backgroundColor = UIColor(resource: .ypWhite).withAlphaComponent(0.3)
        emojiLabel.text = tracker.emoji
        trackerNameLabel.text = tracker.name
        trackerCounterLabel.text = "\(count) \(dayText(for: count))"
        
        let iconName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(
            systemName: iconName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        
        toggleButton.setImage(image, for: .normal)
        toggleButton.backgroundColor = background?.withAlphaComponent(isCompleted ? 0.3 : 1.0)
        toggleButton.isEnabled = isEnabled
        toggleButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    private func setupView() {
        contentView.addSubview(cardView)
        contentView.addSubview(trackerCounterLabel)
        contentView.addSubview(toggleButton)
        
        cardView.addSubview(emojiView)
        emojiView.addSubview(emojiLabel)
        cardView.addSubview(trackerNameLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            trackerNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            trackerCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackerCounterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            
            toggleButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            toggleButton.centerYAnchor.constraint(equalTo: trackerCounterLabel.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 34),
            toggleButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func toggleTapped() {
        onToggle?()
    }
    
    private func dayText(for count: Int) -> String {
        let lastTwoDigits = count % 100
        let lastDigit = count % 10
        
        if (11...14).contains(lastTwoDigits) {
            return "дней"
        }
        
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
}
