//
//  ViewController.swift
//  VRTEst
//
//  Created by Andrei Kirilenko on 02.06.2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    var recordButton: UIButton!
    var setSpeaker: UIButton!
    var setBluetooth: UIButton!
    var tv: UITextView!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var name: String = "record"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        recordingSession = AVAudioSession.sharedInstance()

        do {
            // .record not works!
            //try recordingSession.setCategory(.record, options: AVAudioSession.CategoryOptions.allowBluetooth)
            try recordingSession.setCategory(.playAndRecord, options: AVAudioSession.CategoryOptions.allowBluetooth)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                        checkDevice(audioSession: recordingSession)
                    } else {
                        print("failed to record!")
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
        
    }
    
    func checkDevice(audioSession: AVAudioSession) {
        var bluetoothExist = false

        for output in audioSession.currentRoute.outputs {
            if output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP {
                bluetoothExist = true
            }
        }
        
        tv.text = "bluetooth: " + String(bluetoothExist)
    }

    func loadRecordingUI() {
        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 256, height: 64))
        recordButton.setTitleColor(.black, for: .normal)
        recordButton.backgroundColor = .green
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        tv = UITextView(frame: CGRect(x: 64, y: 150, width: 400, height: 64))
        tv.text = "none"
        view.addSubview(recordButton)
        view.addSubview(tv)
    }

    func startRecording(name: String) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(name + ".m4a")
        let settings2 = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings2)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            
            let fileURL = NSURL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name + ".m4a").absoluteString)
            var filesToShare = [Any]()
            filesToShare.append(fileURL)
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
        }
    }
    
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording(name: name)
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

