import UIKit

final class ColorCollectionView: UICollectionView {
    
    let colorNames = [
        "ColorSelection1", "ColorSelection2", "ColorSelection3",
        "ColorSelection4", "ColorSelection5", "ColorSelection6",
        "ColorSelection7", "ColorSelection8", "ColorSelection9",
        "ColorSelection10", "ColorSelection11", "ColorSelection12",
        "ColorSelection13", "ColorSelection14", "ColorSelection15",
        "ColorSelection16", "ColorSelection17", "ColorSelection18"
    ]
    
    var selectedColorName: String? {
        didSet {
            reloadData()
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        super.init(frame: frame, collectionViewLayout: layout)
        
        register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
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

extension ColorCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        let colorName = colorNames[indexPath.row]
        let color = UIColor(named: colorName) ?? .gray
        cell.configure(with: color, isSelected: colorName == selectedColorName)
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
        selectedColorName = colorNames[indexPath.row]
        reloadData()
    }
}

private class ColorCell: UICollectionViewCell {
    private let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(colorView)
        colorView.layer.cornerRadius = 8
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        if isSelected {
            layer.borderWidth = 3
            layer.borderColor = color.cgColor
            layer.cornerRadius = 8
            layer.masksToBounds = true
        } else {
            layer.borderWidth = 0
        }
    }
}
