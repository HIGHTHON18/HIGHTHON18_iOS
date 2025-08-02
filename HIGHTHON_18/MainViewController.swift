import UIKit
import Then
import SnapKit

class MainViewController: UIViewController {
    private let mainLogoImageView = UIImageView().then {
        $0.image = UIImage(named: "mainDa")?.withRenderingMode(.alwaysOriginal)
    }
    private let mainLineImageView = UIImageView().then {
        $0.image = UIImage(named: "line")?.withRenderingMode(.alwaysOriginal)
    }
    private let upLoadLabel = UILabel().then {
        $0.text = "PDF를 업로드 해주세요"
        $0.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        $0.textColor = .black
    }
    private let loadDetailLabel = UILabel().then {
        $0.text = "50MB 이하, 50페이지 이내로 올려주세요."
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor(named: "mainGray")
    }
    private let mainFileImageView = UIImageView().then {
        $0.image = UIImage(named: "mainFile")?.withRenderingMode(.alwaysOriginal)
    }
    private let selectImageView = UIImageView().then {
        $0.image = UIImage(named: "select")?.withRenderingMode(.alwaysOriginal)
    }
    private let endButton = UIButton().then {
       $0.setTitle("완료", for: .normal)
       $0.backgroundColor = .qwer
       $0.setTitleColor(.white, for: .normal)
       $0.layer.cornerRadius = 10
       $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
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
            mainLineImageView,
            upLoadLabel,
            mainFileImageView,
            loadDetailLabel,
            selectImageView,
            endButton
        ].forEach { view.addSubview($0) }
    }
    
    func layout() {
        mainLogoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(58)
            $0.height.equalTo(43)
        }
        mainLineImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(13)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(24)
        }
        upLoadLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(110)
            $0.leading.equalToSuperview().inset(57)
            $0.trailing.equalToSuperview().inset(56)
        }
        loadDetailLabel.snp.makeConstraints {
            $0.top.equalTo(upLoadLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        mainFileImageView.snp.makeConstraints {
            $0.top.equalTo(278)
            $0.leading.equalToSuperview().inset(93)
            $0.trailing.equalToSuperview().inset(88)
            $0.width.equalTo(247)
            $0.height.equalTo(202)
        }
        selectImageView.snp.makeConstraints {
            $0.top.equalTo(535)
            $0.centerX.equalToSuperview()
        }
        endButton.snp.makeConstraints {
            $0.top.equalTo(selectImageView.snp.bottom).offset(78)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(396)
            $0.height.equalTo(51)
        }
     
    }
}


