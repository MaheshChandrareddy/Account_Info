//
//  VoiceInputViewController.swift
//  AacountInfo
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

import UIKit
import Speech
import AVFoundation

protocol VoiceInputDelegate: AnyObject {
    func didFinishVoiceInput(forId: Int, with: String)

}

class VoiceInputViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var transcriptionTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var recordingStatusLabel: UILabel!

    // MARK: - Speech & Audio
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRecording = false
    var accountID: Int = 0

    weak var delegate: VoiceInputDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
//        configureUI()
        requestPermissions()
    }

    private func configureUI() {
        recordingStatusLabel.text = "Tap mic to start"
        transcriptionTextField.placeholder = "Alternate Name"
    }

    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self.recordingStatusLabel.text = "Speech permission denied"
                    self.micButton.isEnabled = false
                }
            }
        }


        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.recordingStatusLabel.text = "Mic permission denied"
                        self.micButton.isEnabled = false
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }

    }

    @IBAction func micButtonTapped(_ sender: UIButton) {
        isRecording ? stopRecording() : startRecording()
    }

private func startRecording() {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            recordingStatusLabel.text = "Permission not granted"
            return
        }

        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
               try AVAudioSession.sharedInstance().setActive(true)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            let inputNode = audioEngine.inputNode
            guard let recognitionRequest = recognitionRequest else { return }

            recognitionRequest.shouldReportPartialResults = true

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.transcriptionTextField.text = result.bestTranscription.formattedString
                }

                if error != nil || (result?.isFinal ?? false) {
                    self.stopRecording()
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            isRecording = true
            updateMicUI(isRecording: true)

        } catch {
            recordingStatusLabel.text = "Recording failed"
        }
    }


    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()

        isRecording = false
        updateMicUI(isRecording: false)
    }

    private func updateMicUI(isRecording: Bool) {
        let imageName = isRecording ? "mic.circle.fill" : "mic.fill"
        micButton.setImage(UIImage(systemName: imageName), for: .normal)
        micButton.tintColor = isRecording ? .systemRed : .systemBlue
        recordingStatusLabel.text = isRecording ? "Listening..." : "Tap mic to start"
    }

    private func animatePulse(view: UIView) {
        view.alpha = 1.0
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction]) {
            view.alpha = 0.1
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = transcriptionTextField.text, !name.isEmpty else {
            showAlert(title: "Oops", message: "Please enter or speak a name")
            return
        }
        delegate?.didFinishVoiceInput(forId: accountID, with: name)

        dismiss(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        present(alert, animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        stopRecording()
        dismiss(animated: true)
    }
}
