import UIKit
import Then
import SnapKit

class MainViewController: UIViewController {
    private var accessToken: String?
    private var refreshToken: String?
    private var selectedFileURL: URL?  // 선택된 파일 URL 저장
    
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
        $0.isUserInteractionEnabled = true  // 탭 가능하도록 설정
    }
    private let endButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.backgroundColor = .qwer
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.addTarget(self, action: #selector(endButtonTapped), for: .touchUpInside)
    }
    private let tabBarBackView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    private let rankImageView = UIImageView().then {
        $0.image = UIImage(named: "rank")?.withRenderingMode(.alwaysOriginal)
        $0.isUserInteractionEnabled = true
    }
    
    private let logImageView = UIImageView().then {
        $0.image = UIImage(named: "log")?.withRenderingMode(.alwaysOriginal)
        $0.isUserInteractionEnabled = true
    }
    private let plusImageView = UIImageView().then {
        $0.image = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        addView()
        layout()
        setupGestures()
        getTokenAPI()
    }
    
    @objc private func endButtonTapped() {
        let moveViewController = MoveViewController()
        navigationController?.pushViewController(moveViewController, animated: true)
    }
    
    func addView() {
        [
            mainLogoImageView,
            mainLineImageView,
            upLoadLabel,
            mainFileImageView,
            loadDetailLabel,
            selectImageView,
            endButton,
            tabBarBackView,
            plusImageView
        ].forEach { view.addSubview($0) }
        
        tabBarBackView.addSubview(rankImageView)
        tabBarBackView.addSubview(logImageView)
    }
    
    func layout() {
        mainLogoImageView.snp.makeConstraints {
            $0.top.equalTo(47)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(58)
            $0.height.equalTo(43)
        }
        mainLineImageView.snp.makeConstraints {
            $0.top.equalTo(60)
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
            $0.centerX.equalToSuperview()
            $0.width.equalTo(247)
            $0.height.equalTo(202)
        }
        selectImageView.snp.makeConstraints {
            $0.bottom.equalTo(endButton.snp.top).offset(-78)
            $0.centerX.equalToSuperview()
        }
        endButton.snp.makeConstraints {
            $0.bottom.equalTo(tabBarBackView.snp.top).offset(-108)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(51)
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
            $0.top.equalTo(endButton.snp.bottom).offset(64)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(89)
            $0.height.equalTo(88)
        }
    }
    
    private func setupGestures() {
        let rankTapGesture = UITapGestureRecognizer(target: self, action: #selector(rankImageViewTapped))
        rankImageView.addGestureRecognizer(rankTapGesture)
        
        let logTapGesture = UITapGestureRecognizer(target: self, action: #selector(logImageViewTapped))
        logImageView.addGestureRecognizer(logTapGesture)
        
        let selectTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageViewTapped))
        selectImageView.addGestureRecognizer(selectTapGesture)
    }
    
    @objc private func rankImageViewTapped() {
        let rankViewController = RankViewController()
        navigationController?.pushViewController(rankViewController, animated: true)
    }
    
    @objc private func logImageViewTapped() {
        let recordViewController = RecordViewController()
        navigationController?.pushViewController(recordViewController, animated: true)
    }
    
    @objc private func selectImageViewTapped() {
        presentDocumentPicker()
    }
    
    // MARK: - API Methods
    private func getTokenAPI() {
        NetworkManager.shared.getToken { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tokenResponse):
                    self?.accessToken = tokenResponse.accessToken
                    self?.refreshToken = tokenResponse.refreshToken
                    print("Tokens saved successfully")
                    print("Access Token: \(tokenResponse.accessToken)")
                    print("Refresh Token: \(tokenResponse.refreshToken)")
                    
                case .failure(let error):
                    print("Token API Error: \(error.localizedDescription)")
                    // 필요시 에러 처리 로직 추가
                }
            }
        }
    }
    
    // MARK: - File Selection Methods
    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true)
    }
    
    private func handleSelectedFile(_ url: URL) {
        selectedFileURL = url
        
        // 파일 정보 확인
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let fileSizeInMB = fileSize.doubleValue / (1024 * 1024)
                
                print("Selected file: \(url.lastPathComponent)")
                print("File size: \(String(format: "%.2f", fileSizeInMB)) MB")
                
                // 50MB 제한 확인
                if fileSizeInMB > 50 {
                    showAlert(title: "파일 크기 초과", message: "50MB 이하의 파일만 업로드 가능합니다.")
                    selectedFileURL = nil
                    return
                }
                
                // UI 업데이트 (선택된 파일명 표시 등)
                updateUIForSelectedFile(fileName: url.lastPathComponent)
            }
        } catch {
            print("Error reading file attributes: \(error)")
            showAlert(title: "오류", message: "파일 정보를 읽을 수 없습니다.")
        }
    }
    
    private func updateUIForSelectedFile(fileName: String) {
        // 파일이 선택되었음을 사용자에게 알리는 UI 업데이트
        // 예: 라벨 텍스트 변경, 버튼 활성화 등
        DispatchQueue.main.async { [weak self] in
            // 여기서 UI 업데이트 로직 추가
            print("파일이 선택되었습니다: \(fileName)")
            // 예시: self?.upLoadLabel.text = "선택됨: \(fileName)"
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension MainViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        handleSelectedFile(selectedURL)
    }
}
