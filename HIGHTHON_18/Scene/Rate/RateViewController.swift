import UIKit
import SnapKit
import Then



class RateViewController: UIViewController {
    
    // MARK: - Original UI Components
    private let mainLogoImageView = UIImageView().then {
        $0.image = UIImage(named: "mainDa")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(named: "arrow")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let rateImageView = UIImageView().then {
        $0.image = UIImage(named: "rateImage")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let overallEvaluationLabel = UILabel().then {
        $0.text = "종합 평가"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = UIColor(named: "customBlack")
    }
    
    // MARK: - Collection View Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 173, height: 205)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(LogicalThinkingCell.self, forCellWithReuseIdentifier: LogicalThinkingCell.identifier)
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    // MARK: - Data
    private var logicalThinkingItems: [LogicalThinkingItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        setupData()
        addView()
        layout()
    }
    
    // MARK: - Setup Methods
    private func setupData() {
        logicalThinkingItems = [
            LogicalThinkingItem(
                id: 1,
                title: "논리적 사고",
                description: "프로젝트 별 논리적인 흐름이나 설득력이 부족해요.",
                additionalText: "근거를 강화할 수 있는 구체적인 내용을 좀 더 추가하는 것이 필요해요.",
                score: 90
            ),
            LogicalThinkingItem(
                id: 2,
                title: "창의적 사고",
                description: "새로운 아이디어와 접근법을 통해 혁신적인 해결책을 제시해요.",
                additionalText: "독창적인 관점에서 문제를 바라보는 능력이 뛰어나요.",
                score: 85
            ),
            LogicalThinkingItem(
                id: 3,
                title: "비판적 사고",
                description: "정보를 객관적으로 분석하고 평가하는 능력이 우수해요.",
                additionalText: "다각도에서 문제를 검토하여 합리적 판단을 내려요.",
                score: 88
            ),
            LogicalThinkingItem(
                id: 4,
                title: "체계적 사고",
                description: "복잡한 문제를 단계별로 분해하여 체계적으로 접근해요.",
                additionalText: "전체적인 맥락을 고려하면서 세부사항까지 꼼꼼히 살펴요.",
                score: 92
            ),
            LogicalThinkingItem(
                id: 5,
                title: "전략적 사고",
                description: "장기적인 관점에서 목표를 설정하고 계획을 수립해요.",
                additionalText: "현재 상황을 분석하여 미래를 예측하고 대비해요.",
                score: 87
            ),
            LogicalThinkingItem(
                id: 6,
                title: "협력적 사고",
                description: "팀워크를 통해 시너지 효과를 창출하는 능력이 뛰어나요.",
                additionalText: "다양한 의견을 수렴하여 최적의 해결책을 찾아요.",
                score: 91
            )
        ]
    }
    
    func addView() {
        [
            mainLogoImageView,
            arrowImageView,
            rateImageView,
            overallEvaluationLabel,
            collectionView
        ].forEach { view.addSubview($0) }
    }
    
    func layout() {
        mainLogoImageView.snp.makeConstraints {
            $0.top.equalTo(47)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(58)
            $0.height.equalTo(43)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.top.equalTo(53)
            $0.leading.equalToSuperview().inset(16)
        }
        
        rateImageView.snp.makeConstraints {
            $0.top.equalTo(mainLogoImageView.snp.bottom).offset(61)
            $0.centerX.equalToSuperview()
        }
        
        overallEvaluationLabel.snp.makeConstraints {
            $0.top.equalTo(rateImageView.snp.bottom).offset(61)
            $0.leading.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(overallEvaluationLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension RateViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logicalThinkingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LogicalThinkingCell.identifier, for: indexPath) as! LogicalThinkingCell
        cell.configure(with: logicalThinkingItems[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension RateViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedItem = logicalThinkingItems[indexPath.item]
        print("Selected: \(selectedItem.title)")
        // 여기에 셀 터치 이벤트 처리 로직 추가
    }
}
