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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        layout()
    }
    
    
    func addView() {
        [
            mainLogoImageView,
            mainLineImageView
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
    }
}

