import UIKit
import SnapKit
import Then

// MARK: - Data Model
struct LogicalThinkingItem {
    let id: Int
    let title: String
    let description: String
    let additionalText: String
    let score: Int
}

// MARK: - Collection View Cell
class LogicalThinkingCell: UICollectionViewCell {
    static let identifier = "LogicalThinkingCell"
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.1
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    private let headerView = UIView().then {
        $0.layer.cornerRadius = 12
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .darkGray
        $0.numberOfLines = 1
    }
    
    private let decorationStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let additionalLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        $0.textColor = .gray
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        $0.textColor = .systemPurple
        $0.textAlignment = .right
    }
    
    private let scoreUnitLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .systemPurple
        $0.text = "점"
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        contentView.addSubview(containerView)
        
        [headerView, descriptionLabel, additionalLabel, scoreLabel, scoreUnitLabel].forEach {
            containerView.addSubview($0)
        }
        
        [titleLabel, decorationStackView].forEach {
            headerView.addSubview($0)
        }
        
        setupHeaderGradient()
        setupDecorationViews()
    }
    
    private func setupHeaderGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = 12
        
        headerView.layer.insertSublayer(gradientLayer, at: 0)
        
        DispatchQueue.main.async {
            gradientLayer.frame = self.headerView.bounds
        }
    }
    
    private func setupDecorationViews() {
        let smallDot1 = createDotView(size: 6, color: .systemPurple.withAlphaComponent(0.6))
        let mediumDot = createDotView(size: 10, color: .systemPurple.withAlphaComponent(0.8))
        let smallDot2 = createDotView(size: 6, color: .systemPurple.withAlphaComponent(0.6))
        
        [smallDot1, mediumDot, smallDot2].forEach {
            decorationStackView.addArrangedSubview($0)
        }
        
        let largeDot = createDotView(size: 20, color: .systemPurple.withAlphaComponent(0.3))
        headerView.addSubview(largeDot)
        
        largeDot.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview().offset(-4)
            make.width.height.equalTo(20)
        }
    }
    
    private func createDotView(size: CGFloat, color: UIColor) -> UIView {
        return UIView().then {
            $0.backgroundColor = color
            $0.layer.cornerRadius = size / 2
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(size)
            }
        }
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
            make.trailing.lessThanOrEqualTo(decorationStackView.snp.leading).offset(-8)
        }
        
        decorationStackView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        additionalLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        scoreLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.trailing.equalTo(scoreUnitLabel.snp.leading).offset(-4)
        }
        
        scoreUnitLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(12)
        }
    }
    
    // MARK: - Configuration
    func configure(with item: LogicalThinkingItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        additionalLabel.text = item.additionalText
        scoreLabel.text = "\(item.score)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = headerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = headerView.bounds
        }
    }
}
