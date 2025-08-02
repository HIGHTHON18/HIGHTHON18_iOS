import UIKit
import SnapKit
import Then

class RateViewController: UIViewController {
    var feedbackDetail: FeedbackDetail?

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }

    private let contentView = UIView()

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

    private let overallEvaluationDetailLabel = UILabel().then {
        $0.text = "데이터 기반의 UX디자인이 돋보여요"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor(named: "publicBlue")
        $0.numberOfLines = 0
    }

    private let scoreLabel = UILabel().then {
        $0.text = "점수 평가"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = UIColor(named: "customBlack")
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 180, height: 210)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(EvaluationCell.self, forCellWithReuseIdentifier: EvaluationCell.identifier)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    private let strongLabel = UILabel().then {
        $0.text = "강점 분석"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = UIColor(named: "customBlack")
    }

    private let strongDetailLabel = UILabel().then {
        $0.text = "강점 분석 Test"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .customBlack
    }
    
    private let improveLabel = UILabel().then {
        $0.text = "개선할 점 및 해결 방안"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .customBlack
    }
    
    private let improveDetailLabel = UILabel().then {
        $0.text = "개선할 점 test"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        $0.textColor = .customBlack
    }

    private var evaluationItems: [EvaluationDisplayItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        setupData()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        addView()
        layout()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션바 숨기기
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // 자동 생성되는 뒤로가기 제스처 비활성화
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다른 화면으로 이동할 때 네비게이션바 다시 표시
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // 뒤로가기 제스처 다시 활성화
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func setupData() {
        var items: [EvaluationDisplayItem] = []

        if let feedback = feedbackDetail,
           let overallEval = feedback.overallEvaluation {
            updateSummaryLabel(overallEval.summary)
            updateStrengthsLabel(overallEval.strengths)
            updateImprovementsLabel(overallEval.improvements) // 개선사항 업데이트 추가

            items.append(EvaluationDisplayItem(id: 1, title: "직무 적합성", titleEng: "Job Fit", description: overallEval.jobFit.review, score: overallEval.jobFit.score, bgColor: getColorForScore(overallEval.jobFit.score, baseColor: .systemBlue), titleColor: .systemBlue))

            items.append(EvaluationDisplayItem(id: 2, title: "논리적 사고", titleEng: "Logical Thinking", description: overallEval.logicalThinking.review, score: overallEval.logicalThinking.score, bgColor: getColorForScore(overallEval.logicalThinking.score, baseColor: .systemGreen), titleColor: .systemGreen))

            items.append(EvaluationDisplayItem(id: 3, title: "작성 명료성", titleEng: "Writing Clarity", description: overallEval.writingClarity.review, score: overallEval.writingClarity.score, bgColor: getColorForScore(overallEval.writingClarity.score, baseColor: .systemOrange), titleColor: .systemOrange))

            items.append(EvaluationDisplayItem(id: 4, title: "레이아웃 가독성", titleEng: "Layout Readability", description: overallEval.layoutReadability.review, score: overallEval.layoutReadability.score, bgColor: getColorForScore(overallEval.layoutReadability.score, baseColor: .systemPurple), titleColor: .systemPurple))
        } else {
            updateSummaryLabel("데이터 기반의 UX디자인이 돋보여요")

            items = [
                EvaluationDisplayItem(id: 1, title: "직무 적합성", titleEng: "Job Fit", description: "기술 스택과 경험이 적절합니다.", score: 75, bgColor: .systemBlue, titleColor: .systemBlue),
                EvaluationDisplayItem(id: 2, title: "논리적 사고", titleEng: "Logical Thinking", description: "논리적인 문제 해결 능력이 돋보입니다.", score: 70, bgColor: .systemGreen, titleColor: .systemGreen),
                EvaluationDisplayItem(id: 3, title: "작성 명료성", titleEng: "Writing Clarity", description: "글의 가독성과 전달력이 좋습니다.", score: 65, bgColor: .systemOrange, titleColor: .systemOrange),
                EvaluationDisplayItem(id: 4, title: "레이아웃 가독성", titleEng: "Layout Readability", description: "레이아웃이 정돈되어 정보 전달이 효율적입니다.", score: 60, bgColor: .systemPurple, titleColor: .systemPurple)
            ]
        }

        evaluationItems = items
    }

    private func updateSummaryLabel(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.overallEvaluationDetailLabel.text = text
        }
    }

    private func updateStrengthsLabel(_ strengths: [StrengthItem]?) {
        DispatchQueue.main.async { [weak self] in
            if let strengths = strengths, !strengths.isEmpty {
                self?.strongDetailLabel.text = self?.formatStrengths(strengths)
            } else {
                self?.strongDetailLabel.text = "다양한 협업 경험"
            }
        }
    }

    // 개선사항 업데이트 메서드 추가
    private func updateImprovementsLabel(_ improvements: [ImprovementItem]?) {
        DispatchQueue.main.async { [weak self] in
            if let improvements = improvements, !improvements.isEmpty {
                self?.improveDetailLabel.text = self?.formatImprovements(improvements)
            } else {
                self?.improveDetailLabel.text = "개선할 점이 없습니다."
            }
        }
    }

    private func formatStrengths(_ strengths: [StrengthItem]) -> String {
        var result = ""
        for (index, item) in strengths.enumerated() {
            result += "• \(item.title)\n"
            for i in 0..<min(item.content.count, 2) {
                let content = item.content[i]
                let shortened = content.count > 60 ? String(content.prefix(60)) + "..." : content
                result += "  - \(shortened)\n"
            }
            if index < strengths.count - 1 {
                result += "\n"
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 개선사항 포맷팅 메서드 추가
    private func formatImprovements(_ improvements: [ImprovementItem]) -> String {
        var result = ""
        for (index, item) in improvements.enumerated() {
            result += "• \(item.title)\n"
            for i in 0..<min(item.content.count, 3) { // 최대 3개 항목까지 표시
                let content = item.content[i]
                let shortened = content.count > 80 ? String(content.prefix(80)) + "..." : content
                result += "  - \(shortened)\n"
            }
            if index < improvements.count - 1 {
                result += "\n"
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func getColorForScore(_ score: Int, baseColor: UIColor) -> UIColor {
        switch score {
        case 80...100: return baseColor
        case 60...79: return baseColor.withAlphaComponent(0.8)
        case 40...59: return baseColor.withAlphaComponent(0.6)
        default: return baseColor.withAlphaComponent(0.4)
        }
    }

    func updateWithFeedbackDetail(_ detail: FeedbackDetail) {
        self.feedbackDetail = detail
        setupData()
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(arrowTapped))
        arrowImageView.addGestureRecognizer(tap)
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
            overallEvaluationDetailLabel,
            scoreLabel,
            collectionView,
            strongLabel,
            strongDetailLabel,
            improveLabel,
            improveDetailLabel
        ].forEach { contentView.addSubview($0) }
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

        overallEvaluationDetailLabel.snp.makeConstraints {
            $0.top.equalTo(overallEvaluationLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        scoreLabel.snp.makeConstraints {
            $0.top.equalTo(overallEvaluationDetailLabel.snp.bottom).offset(36)
            $0.leading.equalToSuperview().inset(16)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(scoreLabel.snp.bottom).inset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(296)
        }

        strongLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(16)
        }

        strongDetailLabel.snp.makeConstraints {
            $0.top.equalTo(strongLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(26)
        }
        
        improveLabel.snp.makeConstraints {
            $0.top.equalTo(strongDetailLabel.snp.bottom).offset(36)
            $0.leading.equalToSuperview().inset(16)
        }
        
        improveDetailLabel.snp.makeConstraints {
            $0.top.equalTo(improveLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(26)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
}

extension RateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evaluationItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EvaluationCell.identifier, for: indexPath) as! EvaluationCell
        cell.configure(with: evaluationItems[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = evaluationItems[indexPath.item]
        let alert = UIAlertController(title: item.title, message: item.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
