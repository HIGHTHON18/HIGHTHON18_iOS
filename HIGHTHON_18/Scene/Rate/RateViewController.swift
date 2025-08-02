import UIKit
import SnapKit
import Then

class RateViewController: UIViewController {
    
    // MARK: - Properties
    var feedbackDetail: FeedbackDetail?
    
    // MARK: - Original UI Components
    private let mainLogoImageView = UIImageView().then {
        $0.image = UIImage(named: "mainDa")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(named: "arrow")?.withRenderingMode(.alwaysOriginal)
        $0.isUserInteractionEnabled = true
    }
    
    private let rateImageView = UIImageView().then {
        $0.image = UIImage(named: "rateImage")?.withRenderingMode(.alwaysOriginal)
    }

    private let overallEvaluationLabel = UILabel().then {
        $0.text = "종합 평가"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = UIColor(named: "customBlack")
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding: CGFloat = 32 // 좌우 여백
        let interItemSpacing: CGFloat = 12 // 셀 간격
        let cellWidth = (screenWidth - horizontalPadding - interItemSpacing) / 2
        let cellHeight: CGFloat = 140
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(EvaluationCell.self, forCellWithReuseIdentifier: EvaluationCell.identifier)
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false // 4개 항목만 있으므로 스크롤 비활성화
        return cv
    }()
    
    // MARK: - Data
    private var evaluationItems: [EvaluationDisplayItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        setupData()
        addView()
        layout()
        setupGestures()
    }
    
    private func setupData() {
        var items: [EvaluationDisplayItem] = []
        
        if let feedback = feedbackDetail {
            // 네트워크 응답 데이터로 설정
            print("🔍 Setting up data with feedback detail")
            
            if let jobFit = feedback.jobFit {
                print("✅ Adding Job Fit: score=\(jobFit.score)")
                items.append(EvaluationDisplayItem(
                    id: 1,
                    title: "직무 적합성",
                    titleEng: "Job Fit",
                    description: jobFit.review,
                    score: jobFit.score,
                    bgColor: .systemBlue,
                    titleColor: .systemBlue
                ))
            }
            
            if let logicalThinking = feedback.logicalThinking {
                print("✅ Adding Logical Thinking: score=\(logicalThinking.score)")
                items.append(EvaluationDisplayItem(
                    id: 2,
                    title: "논리적 사고",
                    titleEng: "Logical Thinking",
                    description: logicalThinking.review,
                    score: logicalThinking.score,
                    bgColor: .systemGreen,
                    titleColor: .systemGreen
                ))
            }
            
            if let writingClarity = feedback.writingClarity {
                print("✅ Adding Writing Clarity: score=\(writingClarity.score)")
                items.append(EvaluationDisplayItem(
                    id: 3,
                    title: "작성 명료성",
                    titleEng: "Writing Clarity",
                    description: writingClarity.review,
                    score: writingClarity.score,
                    bgColor: .systemOrange,
                    titleColor: .systemOrange
                ))
            }
            
            if let layoutReadability = feedback.layoutReadability {
                print("✅ Adding Layout Readability: score=\(layoutReadability.score)")
                items.append(EvaluationDisplayItem(
                    id: 4,
                    title: "레이아웃 가독성",
                    titleEng: "Layout Readability",
                    description: layoutReadability.review,
                    score: layoutReadability.score,
                    bgColor: .systemPurple,
                    titleColor: .systemPurple
                ))
            }
            
            print("📊 Total items from API: \(items.count)")
            
        } else {
            print("⚠️ No feedback detail available, using sample data")
            // 기본 샘플 데이터
            items = [
                EvaluationDisplayItem(
                    id: 1,
                    title: "직무 적합성",
                    titleEng: "Job Fit",
                    description: "해당 직무에 필요한 기술 스택과 경험이 얼마나 부합하는지 평가합니다.",
                    score: 75,
                    bgColor: .systemBlue,
                    titleColor: .systemBlue
                ),
                EvaluationDisplayItem(
                    id: 2,
                    title: "논리적 사고",
                    titleEng: "Logical Thinking",
                    description: "문제 해결과정의 논리성과 체계적인 접근 방식을 평가합니다.",
                    score: 70,
                    bgColor: .systemGreen,
                    titleColor: .systemGreen
                ),
                EvaluationDisplayItem(
                    id: 3,
                    title: "작성 명료성",
                    titleEng: "Writing Clarity",
                    description: "내용 전달의 명확성과 글의 가독성을 종합적으로 평가합니다.",
                    score: 65,
                    bgColor: .systemOrange,
                    titleColor: .systemOrange
                ),
                EvaluationDisplayItem(
                    id: 4,
                    title: "레이아웃 가독성",
                    titleEng: "Layout Readability",
                    description: "포트폴리오의 시각적 구성과 정보 배치의 효율성을 평가합니다.",
                    score: 60,
                    bgColor: .systemPurple,
                    titleColor: .systemPurple
                )
            ]
        }
        
        evaluationItems = items
        print("🎯 Final evaluation items count: \(evaluationItems.count)")
    }
    
    // MARK: - Public Methods (개선된 버전)
    func updateWithFeedbackDetail(_ detail: FeedbackDetail) {
        print("🔄 Updating RateViewController with feedback detail")
        print("📋 Feedback ID: \(detail.id)")
        print("📄 Title: \(detail.title)")
        print("📊 Overall Status: \(detail.overallStatus)")
        
        self.feedbackDetail = detail
        
        // 평가 데이터 확인
        if let overallEval = detail.overallEvaluation {
            print("✅ Overall evaluation found")
            print("📊 Job Fit: \(overallEval.jobFit.score) - \(overallEval.jobFit.review.prefix(50))...")
            print("📊 Logical Thinking: \(overallEval.logicalThinking.score) - \(overallEval.logicalThinking.review.prefix(50))...")
            print("📊 Writing Clarity: \(overallEval.writingClarity.score) - \(overallEval.writingClarity.review.prefix(50))...")
            print("📊 Layout Readability: \(overallEval.layoutReadability.score) - \(overallEval.layoutReadability.review.prefix(50))...")
        } else {
            print("⚠️ No overall evaluation found in feedback detail")
        }
        
        setupData()
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            print("🔄 Collection view reloaded with new data")
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(arrowTapped))
        arrowImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func arrowTapped() {
        navigationController?.popViewController(animated: true)
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
            $0.height.equalTo(296) // 2줄 * 140 + 간격 16 = 296
        }
    }
}

// MARK: - UICollectionViewDataSource
extension RateViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evaluationItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EvaluationCell.identifier, for: indexPath) as! EvaluationCell
        cell.configure(with: evaluationItems[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension RateViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedItem = evaluationItems[indexPath.item]
        print("Selected: \(selectedItem.title) - Score: \(selectedItem.score)")
        
        // 상세 리뷰 내용을 보여주는 팝업이나 다른 화면으로 이동 가능
        showDetailReview(for: selectedItem)
    }
    
    private func showDetailReview(for item: EvaluationDisplayItem) {
        let alert = UIAlertController(
            title: item.title,
            message: item.description,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
