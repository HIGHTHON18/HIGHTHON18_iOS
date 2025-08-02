import UIKit
import SnapKit
import Then

class MoveViewController: UIViewController {
    private let daeImageView = UIImageView().then {
        $0.image = UIImage(named: "mainDa")?.withRenderingMode(.alwaysOriginal)
    }
    private let aiFeedLabel = UILabel().then {
        $0.text = "AI 피드백 진행중"
        $0.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        $0.textColor = .black
    }
    
    private let sentImageView = UIImageView().then {
        $0.image = UIImage(named: "mainSent")?.withRenderingMode(.alwaysOriginal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        addView()
        layout()
    }
    
    func addView() {
        [
            daeImageView,
            aiFeedLabel,
            sentImageView
        ].forEach { view.addSubview($0) }
    }
    
    func layout() {
        daeImageView.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(47)
            $0.centerX.equalToSuperview()
        }
        aiFeedLabel.snp.makeConstraints {
            $0.top.equalTo(daeImageView.snp.bottom).offset(67)
            $0.leading.equalToSuperview().inset(57)
            $0.trailing.equalToSuperview().inset(56)
        }
        sentImageView.snp.makeConstraints {
            $0.centerX.centerX.equalToSuperview()
        }
    }
    
}
