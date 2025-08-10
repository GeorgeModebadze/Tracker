import UIKit

final class EmojiCollectionView: UICollectionView {
    
    let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    var selectedEmoji: String? {
        didSet { reloadData() }
    }
    var onSelectionChanged: (() -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        super.init(frame: frame, collectionViewLayout: layout)
        
        register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        dataSource = self
        delegate = self
        backgroundColor = .clear
        isScrollEnabled = false
        
        allowsSelection = true
        allowsMultipleSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmojiCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
            assertionFailure("Failed to dequeue EmojiCell")
            return UICollectionViewCell()
        }
        cell.configure(with: emojis[indexPath.row], isSelected: emojis[indexPath.row] == selectedEmoji)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 56
        let spacingBetweenItems: CGFloat = 5
        let totalSpacing = spacingBetweenItems * 5
        let width = (availableWidth - totalSpacing) / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmoji = emojis[indexPath.row]
        if let prevSelected = emojis.firstIndex(of: selectedEmoji ?? "") {
            let prevIndexPath = IndexPath(item: prevSelected, section: 0)
            collectionView.reloadItems(at: [prevIndexPath, indexPath])
        } else {
            collectionView.reloadItems(at: [indexPath])
        }
        onSelectionChanged?()
    }
}

private class EmojiCell: UICollectionViewCell {
    private let emojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(emojiLabel)
        emojiLabel.font = .systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        backgroundColor = isSelected ? UIColor(resource: .lightGrayPick) : .clear
        layer.cornerRadius = isSelected ? 16 : 0
        layer.masksToBounds = true
    }
}
