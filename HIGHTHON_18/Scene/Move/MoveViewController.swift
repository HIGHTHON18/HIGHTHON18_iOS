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
    private let feedDetailLabel = UILabel().then {
        $0.text = "피드백은 최대 2분까지 소요될 수 있습니다."
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor(named: "mainGray")
    }
    private let sentImageView = UIImageView().then {
        $0.image = UIImage(named: "moveSent")?.withRenderingMode(.alwaysOriginal)
    }
    private let tabBarBackView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    private let plusImageView = UIImageView().then {
        $0.image = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        $0.isUserInteractionEnabled = true
    }
    private let rankImageView = UIImageView().then {
        $0.image = UIImage(named: "rank")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let logImageView = UIImageView().then {
        $0.image = UIImage(named: "log")?.withRenderingMode(.alwaysOriginal)
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
       view.backgroundColor = .backGround
       navigationItem.hidesBackButton = true
       addView()
       layout()
       setupGestures()  // 제스처 설정 추가
    }
    
    func addView() {
        [
            daeImageView,
            aiFeedLabel,
            sentImageView,
            tabBarBackView,
            plusImageView,
            feedDetailLabel
        ].forEach { view.addSubview($0) }
        
        tabBarBackView.addSubview(rankImageView)
        tabBarBackView.addSubview(logImageView)
    }
    
    func layout() {
        daeImageView.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(47)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(58)
            $0.height.equalTo(43)
        }
        aiFeedLabel.snp.makeConstraints {
            $0.top.equalTo(daeImageView.snp.bottom).offset(67)
            $0.centerX.equalToSuperview()
        }
        feedDetailLabel.snp.makeConstraints {
            $0.top.equalTo(aiFeedLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        sentImageView.snp.makeConstraints {
            $0.top.equalTo(feedDetailLabel.snp.bottom).offset(62)
            $0.centerY.equalToSuperview()
        }
        tabBarBackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(72)
        }
        rankImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(80)
            $0.bottom.equalToSuperview().offset(-15)
            $0.width.equalTo(25)
        }
        logImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(260)
            $0.bottom.equalToSuperview().offset(-15)
            $0.width.equalTo(25)
        }
        plusImageView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-28)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(89)
            $0.height.equalTo(88)
        }
    }
    
    // 제스처 설정 함수 추가
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(plusImageViewTapped))
        plusImageView.addGestureRecognizer(tapGesture)
    }
    
    // plusImageView 탭 시 실행될 함수
    @objc private func plusImageViewTapped() {
        navigationController?.popViewController(animated: true)
    }
}
