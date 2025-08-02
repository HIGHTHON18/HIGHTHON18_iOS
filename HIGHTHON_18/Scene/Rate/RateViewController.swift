import UIKit
import SnapKit
import Then

class RateViewController: UIViewController {
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        addView()
        layout()
    }
    
    
    func addView() {
        [
            mainLogoImageView,
            arrowImageView,
            rateImageView,
            overallEvaluationLabel
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
    }
}
