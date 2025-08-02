import UIKit
import SnapKit
import Then

struct EvaluationDisplayItem {
    let id: Int
    let title: String
    let titleEng: String
    let description: String
    let score: Int
    let bgColor: UIColor
    let titleColor: UIColor
}

class EvaluationCell: UICollectionViewCell {
    static let identifier = "EvaluationCell"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
        $0.layer.shadowOpacity = 0.08
    }

    private let backgroundColorView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.alpha = 0.1
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.lineBreakMode = .byWordWrapping
        $0.textAlignment = .left
    }

    private let titleEngLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        $0.textColor = .gray
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }

    private let descriptionLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }

    private let scoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        $0.text = "0"
        $0.textAlignment = .right
    }

    private let decorationView = UIView().then {
        $0.layer.cornerRadius = 4
        $0.alpha = 0.3
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        [backgroundColorView, titleLabel, titleEngLabel, scoreLabel, descriptionLabel, decorationView].forEach {
            containerView.addSubview($0)
        }
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backgroundColorView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(scoreLabel.snp.leading).offset(-8)
        }

        titleEngLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(scoreLabel.snp.leading).offset(-8)
        }

        scoreLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
             make.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleEngLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(decorationView.snp.top).offset(-8)
        }

        decorationView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(12)
            make.width.equalTo(40)
            make.height.equalTo(8)
        }
    }

    func configure(with item: EvaluationDisplayItem) {
        titleLabel.text = item.title
        titleEngLabel.text = item.titleEng
        descriptionLabel.text = item.description
        scoreLabel.text = "\(item.score)"

        backgroundColorView.backgroundColor = item.bgColor
        decorationView.backgroundColor = item.bgColor
        titleLabel.textColor = item.titleColor
        scoreLabel.textColor = item.bgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        titleEngLabel.text = nil
        descriptionLabel.text = nil
        scoreLabel.text = nil
    }
}
