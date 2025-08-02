import UIKit
import Then
import SnapKit

class MainViewController: UIViewController {
    private var accessToken: String?
    private var expirationTime: String?
    private var selectedFileURL: URL?
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
        $0.isUserInteractionEnabled = true
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
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .qwer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backGround
        addView()
        layout()
        setupGestures()
        getTokenAPI()
        updateEndButtonState()
    }
    
    @objc private func endButtonTapped() {
        guard let selectedFileURL = selectedFileURL else {
            showAlert(title: "파일 선택 필요", message: "먼저 PDF 파일을 선택해주세요.")
            return
        }
        
        guard let accessToken = accessToken else {
            // 토큰이 없을 때 다시 시도
            showAlert(title: "인증 중...", message: "토큰을 다시 가져오는 중입니다.") { [weak self] in
                self?.getTokenAPI()
            }
            return
        }
        
        uploadPortfolioFile(fileURL: selectedFileURL, accessToken: accessToken)
    }
    
    // 레이아웃 및 기타 메서드들은 동일...
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
            plusImageView,
            loadingIndicator
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
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
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
    
    // MARK: - API Methods (수정된 부분)
    private func getTokenAPI() {
        print("🔄 Attempting to get token...")
        showLoading(true) // 토큰 가져오는 동안 로딩 표시
        
        NetworkManager.shared.getToken { [weak self] result in
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let tokenResponse):
                    self?.accessToken = tokenResponse.accessToken
                    print("✅ Token saved successfully: \(tokenResponse.accessToken.prefix(10))...")
                    self?.updateEndButtonState() // 토큰 받은 후 버튼 상태 업데이트
                    
                case .failure(let error):
                    print("❌ Token API Error: \(error.localizedDescription)")
                    if case .apiError(let code, let message) = error {
                        print("📋 Error Code: \(code)")
                        print("💬 Error Message: \(message)")
                    }
                    
                    // 네트워크 연결 문제일 수 있으니 재시도 옵션 제공
                    self?.showRetryAlert(title: "토큰 오류",
                                        message: "인증 토큰을 가져올 수 없습니다.\n네트워크 연결을 확인해주세요.") {
                        self?.getTokenAPI()
                    }
                }
            }
        }
    }
    
    private func uploadPortfolioFile(fileURL: URL, accessToken: String) {
        showLoading(true)
        
        NetworkManager.shared.uploadPortfolio(fileURL: fileURL, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let uploadResponse):
                    print("✅ File uploaded successfully")
                    print("🎯 Upload ID: \(uploadResponse.id)")
                    print("📄 File Name: \(uploadResponse.logicalName)")
                    print("🔗 URLs: \(uploadResponse.url)")
                    
                    self?.showSuccessAndNavigate()
                    
                case .failure(let error):
                    print("❌ Upload Error: \(error.localizedDescription)")
                    
                    var errorMessage = "업로드 중 오류가 발생했습니다."
                    
                    if case .apiError(let code, let message) = error {
                        print("📋 Upload Error Code: \(code)")
                        print("💬 Upload Error Message: \(message)")
                        errorMessage = message
                    }
                    
                    self?.showAlert(title: "업로드 실패", message: errorMessage)
                }
            }
        }
    }
    
    private func showSuccessAndNavigate() {
        let alert = UIAlertController(title: "업로드 완료", message: "포트폴리오가 성공적으로 업로드되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            let moveViewController = MoveViewController()
            self?.navigationController?.pushViewController(moveViewController, animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            endButton.isEnabled = false
            endButton.alpha = 0.6
        } else {
            loadingIndicator.stopAnimating()
            updateEndButtonState() // 로딩 종료 후 버튼 상태 재평가
        }
    }
    
    // MARK: - File Selection Methods (수정된 부분)
    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true)
    }
    
    private func handleSelectedFile(_ url: URL) {
        // 파일 접근 권한 확보
        guard url.startAccessingSecurityScopedResource() else {
            showAlert(title: "파일 접근 오류", message: "선택한 파일에 접근할 수 없습니다.")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        selectedFileURL = url
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let fileSizeInMB = fileSize.doubleValue / (1024 * 1024)
                
                // 파일명을 안전하게 디코딩
                let fileName = url.lastPathComponent.removingPercentEncoding ?? url.lastPathComponent
                print("Selected file: \(fileName)")
                print("File size: \(String(format: "%.2f", fileSizeInMB)) MB")
                
                if fileSizeInMB > 50 {
                    showAlert(title: "파일 크기 초과", message: "50MB 이하의 파일만 업로드 가능합니다.")
                    selectedFileURL = nil
                    updateEndButtonState()
                    return
                }
                
                updateUIForSelectedFile(fileName: fileName)
                updateEndButtonState()
            }
        } catch {
            print("Error reading file attributes: \(error)")
            showAlert(title: "오류", message: "파일 정보를 읽을 수 없습니다.")
            selectedFileURL = nil
            updateEndButtonState()
        }
    }
    
    private func updateUIForSelectedFile(fileName: String) {
        DispatchQueue.main.async { [weak self] in
            print("파일이 선택되었습니다: \(fileName)")
            // 파일명이 너무 길면 축약
            let displayName = fileName.count > 20 ? String(fileName.prefix(17)) + "..." : fileName
            self?.upLoadLabel.text = "선택됨: \(displayName)"
            self?.upLoadLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            self?.loadDetailLabel.text = "업로드할 준비가 완료되었습니다."
        }
    }
    
    // 수정된 버튼 상태 업데이트 로직
    private func updateEndButtonState() {
        DispatchQueue.main.async { [weak self] in
            let hasFile = self?.selectedFileURL != nil
            let hasToken = self?.accessToken != nil
            
            print("🔍 Button state check - File: \(hasFile), Token: \(hasToken)")
            
            if hasFile && hasToken {
                self?.endButton.backgroundColor = .qwer
                self?.endButton.isEnabled = true
                self?.endButton.alpha = 1.0
                print("✅ Button enabled")
            } else {
                self?.endButton.backgroundColor = .lightGray
                self?.endButton.isEnabled = false
                self?.endButton.alpha = 0.6
                print("❌ Button disabled - Missing: \(hasFile ? "" : "File ") \(hasToken ? "" : "Token")")
            }
        }
    }
    
    // 일반 알림
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                completion?()
            })
            self?.present(alert, animated: true)
        }
    }
    
    // 재시도 알림
    private func showRetryAlert(title: String, message: String, retryAction: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "재시도", style: .default) { _ in
                retryAction()
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
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
