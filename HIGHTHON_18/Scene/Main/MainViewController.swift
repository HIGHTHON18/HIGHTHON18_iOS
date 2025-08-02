import UIKit
import Then
import SnapKit
import UniformTypeIdentifiers

class MainViewController: UIViewController {
    private var accessToken: String?
    private var expirationTime: String?
    private var selectedFileURL: URL?
    private var uploadedFileId: String?
    private let mainLogoImageView = UIImageView().then {
        $0.image = UIImage(named: "mainDa")?.withRenderingMode(.alwaysOriginal)
    }
    private let mainLineImageView = UIImageView().then {
        $0.image = UIImage(named: "line")?.withRenderingMode(.alwaysOriginal)
    }
    private let upLoadLabel = UIImageView().then {
        $0.image = UIImage(named: "qwer3")?.withRenderingMode(.alwaysOriginal)
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
        
        // 이전에 업로드된 파일 ID 복원 (필요한 경우)
        if let savedId = UserDefaults.standard.string(forKey: "lastUploadedFileId") {
            uploadedFileId = savedId
            print("📂 Restored saved file ID: \(savedId)")
        }
    }
    
    // MARK: - File ID Management
    /// 현재 업로드된 파일 ID를 반환
    func getCurrentUploadedFileId() -> String? {
        return uploadedFileId
    }
    
    /// 저장된 파일 ID를 클리어 (필요한 경우)
    func clearUploadedFileId() {
        uploadedFileId = nil
        UserDefaults.standard.removeObject(forKey: "lastUploadedFileId")
        UserDefaults.standard.synchronize()
        print("🗑️ Uploaded file ID cleared")
    }
    
    @objc private func endButtonTapped() {
        guard let selectedFileURL = selectedFileURL else {
            showAlert(title: "파일 선택 필요", message: "먼저 PDF 파일을 선택해주세요.")
            return
        }
        
        guard let accessToken = accessToken else {
            showAlert(title: "인증 중...", message: "토큰을 다시 가져오는 중입니다.") { [weak self] in
                self?.getTokenAPI()
            }
            return
        }
        
        // 바로 MoveViewController로 이동
        let moveViewController = MoveViewController()
        navigationController?.pushViewController(moveViewController, animated: true)
        
        // 백그라운드에서 파일 업로드 시작
        uploadPortfolioFileInBackground(fileURL: selectedFileURL, accessToken: accessToken, moveViewController: moveViewController)
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
            $0.centerX.equalToSuperview()
        }
        loadDetailLabel.snp.makeConstraints {
            $0.top.equalTo(upLoadLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        mainFileImageView.snp.makeConstraints {
            $0.top.equalTo(260)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(247)
            $0.height.equalTo(220)
        }
        selectImageView.snp.makeConstraints {
            $0.bottom.equalTo(endButton.snp.top).offset(-56)
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
    
    // MARK: - API Methods
    private func getTokenAPI() {
        print("🔄 Attempting to get token...")
        showLoading(true)
        
        NetworkManager.shared.getToken { [weak self] result in
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let tokenResponse):
                    self?.accessToken = tokenResponse.accessToken
                    print("✅ Token saved successfully: \(tokenResponse.accessToken.prefix(10))...")
                    self?.updateEndButtonState()
                    
                case .failure(let error):
                    print("❌ Token API Error: \(error.localizedDescription)")
                    if case .apiError(let code, let message) = error {
                        print("📋 Error Code: \(code)")
                        print("💬 Error Message: \(message)")
                    }
                    
                    self?.showRetryAlert(title: "토큰 오류",
                                        message: "인증 토큰을 가져올 수 없습니다.\n네트워크 연결을 확인해주세요.") {
                        self?.getTokenAPI()
                    }
                }
            }
        }
    }
    
    // MARK: - Background Upload Method (수정된 부분)
    private func uploadPortfolioFileInBackground(fileURL: URL, accessToken: String, moveViewController: MoveViewController) {
        print("📤 Starting background file upload...")
        
        NetworkManager.shared.uploadPortfolio(fileURL: fileURL, accessToken: accessToken) { [weak self, weak moveViewController] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let uploadResponse):
                    print("✅ File uploaded successfully")
                    print("🎯 Upload ID: \(uploadResponse.id)")
                    print("📄 File Name: \(uploadResponse.logicalName)")
                    print("🔗 URLs: \(uploadResponse.url)")
                    
                    // 업로드된 파일 ID 저장
                    self?.uploadedFileId = uploadResponse.id
                    print("💾 File ID saved: \(uploadResponse.id)")
                    
                    // UserDefaults에도 저장
                    UserDefaults.standard.set(uploadResponse.id, forKey: "lastUploadedFileId")
                    UserDefaults.standard.synchronize()
                    print("💾 File ID saved to UserDefaults")
                    
                    // 업로드 성공 후 피드백 시작 API 호출
                    guard let moveVC = moveViewController else {
                        print("❌ MoveViewController is nil")
                        return
                    }
                    self?.startFeedbackInBackground(fileId: uploadResponse.id, accessToken: accessToken, moveViewController: moveVC)
                    
                case .failure(let error):
                    print("❌ Upload Error: \(error.localizedDescription)")
                    
                    var errorMessage = "업로드 중 오류가 발생했습니다."
                    
                    if case .apiError(let code, let message) = error {
                        print("📋 Upload Error Code: \(code)")
                        print("💬 Upload Error Message: \(message)")
                        errorMessage = message
                    }
                    
                    // MoveViewController에서 에러 알림 표시
                    if let moveVC = moveViewController {
                        moveVC.showUploadErrorAlert(message: errorMessage)
                    }
                }
            }
        }
    }
    
    // MARK: - Start Feedback Method (수정된 부분)
    private func startFeedbackInBackground(fileId: String, accessToken: String, moveViewController: MoveViewController) {
        print("🔄 Starting feedback process...")
        
        NetworkManager.shared.startFeedback(fileId: fileId, accessToken: accessToken) { [weak moveViewController] result in
            DispatchQueue.main.async {
                guard let moveVC = moveViewController else {
                    print("❌ MoveViewController is nil in feedback callback")
                    return
                }
                
                switch result {
                case .success(let feedbackResponse):
                    print("✅ Feedback started successfully")
                    print("🎯 Feedback ID: \(feedbackResponse.feedbackId)")
                    moveVC.startFeedbackStatusPolling(
                        feedbackId: feedbackResponse.feedbackId,
                        accessToken: accessToken
                    )
                    
                case .failure(let error):
                    print("❌ Feedback Start Error: \(error.localizedDescription)")
                    
                    var errorMessage = "피드백 시작 중 오류가 발생했습니다."
                    
                    if case .apiError(let code, let message) = error {
                        print("📋 Feedback Error Code: \(code)")
                        print("💬 Feedback Error Message: \(message)")
                        errorMessage = message
                    }
                    
                    // MoveViewController에서 에러 알림 표시
                    moveVC.showFeedbackStartErrorAlert(message: errorMessage)
                }
            }
        }
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            endButton.isEnabled = false
            endButton.alpha = 0.6
        } else {
            loadingIndicator.stopAnimating()
            updateEndButtonState()
        }
    }
    
    // MARK: - File Selection Methods
    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true)
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func copyFileToDocuments(from sourceURL: URL) -> URL? {
        let documentsDirectory = getDocumentsDirectory()
        let fileName = sourceURL.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
                print("🗑️ Existing file removed")
            }
            
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("📁 File copied to: \(destinationURL.path)")
            return destinationURL
            
        } catch {
            print("❌ File copy error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func validateFileSize(at url: URL) -> (isValid: Bool, sizeInMB: Double) {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let fileSizeInMB = fileSize.doubleValue / (1024 * 1024)
                return (fileSizeInMB <= 50, fileSizeInMB)
            }
        } catch {
            print("❌ Error reading file size: \(error.localizedDescription)")
        }
        return (false, 0)
    }
    
    private func handleSelectedFile(_ url: URL) {
        print("🔍 Processing selected file: \(url.lastPathComponent)")
        
        let hasAccess = url.startAccessingSecurityScopedResource()
        print("🔐 Security scoped access: \(hasAccess)")
        
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
                print("🔓 Security scoped access released")
            }
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ File does not exist at path: \(url.path)")
            showAlert(title: "파일 오류", message: "선택한 파일을 찾을 수 없습니다.")
            return
        }
        
        let validation = validateFileSize(at: url)
        guard validation.isValid else {
            print("❌ File size too large: \(String(format: "%.2f", validation.sizeInMB)) MB")
            showAlert(title: "파일 크기 초과", message: "50MB 이하의 파일만 업로드 가능합니다.\n현재 파일 크기: \(String(format: "%.2f", validation.sizeInMB))MB")
            return
        }
        
        print("✅ File size OK: \(String(format: "%.2f", validation.sizeInMB)) MB")
        
        guard let copiedFileURL = copyFileToDocuments(from: url) else {
            showAlert(title: "파일 처리 오류", message: "파일을 처리하는 중 오류가 발생했습니다.")
            return
        }
        
        selectedFileURL = copiedFileURL
        
        let fileName = url.lastPathComponent.removingPercentEncoding ?? url.lastPathComponent
        updateUIForSelectedFile(fileName: fileName, fileSize: validation.sizeInMB)
        updateEndButtonState()
        
        print("🎉 File successfully processed and ready for upload")
    }
    
    private func updateUIForSelectedFile(fileName: String, fileSize: Double) {
        DispatchQueue.main.async { [weak self] in
            let displayName = fileName.count > 20 ? String(fileName.prefix(17)) + "..." : fileName
            self?.loadDetailLabel.text = "크기: \(String(format: "%.2f", fileSize))MB | 업로드 준비 완료"
            self?.loadDetailLabel.textColor = UIColor.systemGreen
            
            print("📱 UI updated for selected file")
        }
    }
    
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
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                completion?()
            })
            self?.present(alert, animated: true)
        }
    }
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let fileURL = selectedFileURL,
           fileURL.path.contains(getDocumentsDirectory().path) {
            try? FileManager.default.removeItem(at: fileURL)
            print("🧹 Temporary file cleaned up")
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension MainViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("📎 Document picker returned \(urls.count) files")
        guard let selectedURL = urls.first else {
            print("❌ No file selected")
            return
        }
        
        print("📄 Selected file URL: \(selectedURL)")
        print("📍 File path: \(selectedURL.path)")
        print("🏷️ File name: \(selectedURL.lastPathComponent)")
        
        handleSelectedFile(selectedURL)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("📋 Document picker was cancelled")
    }
}
