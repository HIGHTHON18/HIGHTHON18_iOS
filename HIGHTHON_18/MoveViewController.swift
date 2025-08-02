import UIKit
import SnapKit
import Then

class MoveViewController: UIViewController {
    private let daeImageView = UIImageView().then {
        $0.image = UIImage(named: "mainDa")?.withRenderingMode(.alwaysOriginal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        addView()
        layout()
    }
    
    func addView() {
        [
            daeImageView
        ].forEach { view.addSubview($0) }
    }
    
    func layout() {
        daeImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
}
