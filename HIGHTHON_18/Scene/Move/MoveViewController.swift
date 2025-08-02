    import UIKit
    import SnapKit
    import Then

    class MoveViewController: UIViewController {
        private let daeImageView = UIImageView().then {
            $0.image = UIImage(named: "mainDa")?.withRenderingMode(.alwaysOriginal)
        }
        private let aiFeedLabel = UIImageView().then {
            $0.image = UIImage(named: "qwer3")?.withRenderingMode(.alwaysOriginal)
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
        
        // MARK: - Feedback Status Polling Properties
        private var feedbackId: String?
        private var accessToken: String?
        private var statusCheckTimer: Timer?
        private var pollCount = 0
        private let maxPollCount = 40 // 3초 * 40 = 최대 2분
        
        override func viewDidLoad() {
           super.viewDidLoad()
           view.backgroundColor = .backGround
           navigationItem.hidesBackButton = true
           addView()
           layout()
           setupGestures()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            stopStatusPolling()
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
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(350)
            }
            tabBarBackView.snp.makeConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(72)
            }
            rankImageView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalToSuperview().offset(65)
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

        private func setupGestures() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(plusImageViewTapped))
            plusImageView.addGestureRecognizer(tapGesture)
        }

        @objc private func plusImageViewTapped() {
            stopStatusPolling()
            navigationController?.popViewController(animated: true)
        }

        // MARK: - Feedback Status Polling Methods
        
        /// 피드백 상태 폴링을 시작하는 메서드 (MainViewController에서 호출)
        func startFeedbackStatusPolling(feedbackId: String, accessToken: String) {
            print("🔄 Starting feedback status polling...")
            print("🆔 Feedback ID: \(feedbackId)")
            
            self.feedbackId = feedbackId
            self.accessToken = accessToken
            self.pollCount = 0
            
            // 즉시 첫 번째 상태 확인
            checkFeedbackStatus()
            
            // 3초마다 상태 확인 타이머 시작
            statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                self?.checkFeedbackStatus()
            }
        }
        
        private func checkFeedbackStatus() {
            guard let feedbackId = feedbackId,
                  let accessToken = accessToken else {
                print("❌ Missing feedbackId or accessToken")
                stopStatusPolling()
                return
            }
            
            pollCount += 1
            print("🔍 Checking feedback status... Poll count: \(pollCount)/\(maxPollCount)")
            
            // 최대 폴링 횟수 초과 시 타임아웃 처리
            if pollCount > maxPollCount {
                print("⏰ Feedback status polling timeout")
                stopStatusPolling()
                handleFeedbackTimeout()
                return
            }
            
            NetworkManager.shared.getFeedbackDetail(feedbackId: feedbackId, accessToken: accessToken) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let feedbackDetail):
                        self?.handleFeedbackStatusResponse(feedbackDetail)
                        
                    case .failure(let error):
                        print("❌ Feedback Status Check Error: \(error.localizedDescription)")
                        // 에러가 발생해도 계속 폴링을 시도함 (일시적 네트워크 오류 대응)
                        if let networkError = error as? NetworkError,
                           case .apiError(let code, let message) = networkError {
                            print("📋 Status Check Error Code: \(code)")
                            print("💬 Status Check Error Message: \(message)")
                        }
                    }
                }
            }
        }
        
        // MoveViewController.swift의 수정된 부분

        private func handleFeedbackStatusResponse(_ response: FeedbackDetailResponse) {
            let feedback = response.feedback
            
            print("📊 Feedback Status Update:")
            print("   Overall Status: \(feedback.overallStatus)")
            print("   Project Status: \(feedback.projectStatus)")
            print("   Title: \(feedback.title)")
            
            // 두 상태 모두 COMPLETE인지 확인
            if feedback.overallStatus == "COMPLETE" && feedback.projectStatus == "COMPLETE" {
                print("✅ Feedback completed! Moving to RateViewController...")
                stopStatusPolling()
                navigateToRateViewController(with: feedback) // 피드백 데이터 전달
            } else {
                print("⏳ Feedback still in progress...")
                updateProgressUI(overallStatus: feedback.overallStatus, projectStatus: feedback.projectStatus)
            }
        }

        private func navigateToRateViewController(with feedbackDetail: FeedbackDetail) {
            print("🚀 Navigating to RateViewController...")
            
            DispatchQueue.main.async { [weak self] in
                guard let navigationController = self?.navigationController else {
                    print("❌ NavigationController is nil")
                    return
                }
                
                let rateViewController = RateViewController()
                
                // 피드백 데이터 전달
                print("📦 Passing feedback data to RateViewController")
                print("🆔 Feedback ID: \(feedbackDetail.id)")
                
                if let overallEval = feedbackDetail.overallEvaluation {
                    print("📊 Scores being passed:")
                    print("   Job Fit: \(overallEval.jobFit.score)")
                    print("   Logical Thinking: \(overallEval.logicalThinking.score)")
                    print("   Writing Clarity: \(overallEval.writingClarity.score)")
                    print("   Layout Readability: \(overallEval.layoutReadability.score)")
                }
                
                rateViewController.updateWithFeedbackDetail(feedbackDetail)
                
                navigationController.pushViewController(rateViewController, animated: true)
            }
        }

        // 기존의 navigateToRateViewController() 메서드는 이제 사용하지 않음
        
        private func updateProgressUI(overallStatus: String, projectStatus: String) {
            // UI 업데이트 (필요한 경우)
            DispatchQueue.main.async { [weak self] in
                // 상태에 따른 UI 업데이트 로직 추가 가능
                // 예: 진행 상태 표시, 라벨 텍스트 변경 등
                if overallStatus != "COMPLETE" || projectStatus != "COMPLETE" {
                    self?.feedDetailLabel.text = "피드백 분석 중... (\(self?.pollCount ?? 0)/\(self?.maxPollCount ?? 40))"
                }
            }
        }
        
        private func stopStatusPolling() {
            print("🛑 Stopping feedback status polling...")
            statusCheckTimer?.invalidate()
            statusCheckTimer = nil
        }
        
        private func navigateToRateViewController() {
            print("🚀 Navigating to RateViewController...")
            
            DispatchQueue.main.async { [weak self] in
                guard let navigationController = self?.navigationController else {
                    print("❌ NavigationController is nil")
                    return
                }
                
                let rateViewController = RateViewController()
                // 필요한 경우 RateViewController에 데이터 전달
                // rateViewController.feedbackId = self?.feedbackId
                
                navigationController.pushViewController(rateViewController, animated: true)
            }
        }
        
        private func handleFeedbackTimeout() {
            print("⏰ Feedback processing timeout")
            
            DispatchQueue.main.async { [weak self] in
                let alert = UIAlertController(
                    title: "피드백 처리 지연",
                    message: "피드백 처리가 예상보다 오래 걸리고 있습니다.\n잠시 후 다시 시도해주세요.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "재시도", style: .default) { [weak self] _ in
                    self?.pollCount = 0
                    if let feedbackId = self?.feedbackId,
                       let accessToken = self?.accessToken {
                        self?.startFeedbackStatusPolling(feedbackId: feedbackId, accessToken: accessToken)
                    }
                })
                
                alert.addAction(UIAlertAction(title: "돌아가기", style: .cancel) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })
                
                self?.present(alert, animated: true)
            }
        }

        // MARK: - Error Alert Methods
        func showUploadErrorAlert(message: String) {
            let alert = UIAlertController(
                title: "업로드 실패",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "재시도", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            present(alert, animated: true)
        }
        
        // MARK: - Feedback Start Error Alert
        func showFeedbackStartErrorAlert(message: String) {
            let alert = UIAlertController(
                title: "피드백 시작 실패",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "재시도", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            present(alert, animated: true)
        }
    }
