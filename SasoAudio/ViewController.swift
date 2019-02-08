//
//  ViewController.swift
//  SasoAudio
//
//  Created by Henze Federico on 08.02.19.
//  Copyright © 2019 Henze Federico. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordBtn: UIButton!
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    self.recordBtn.isEnabled = allowed;
                    self.recordBtn.setTitle("Grabar", for: .normal)
                }
            }
        } catch {
            // failed to record!
        }
    }

    @IBAction func recordTapped(_ sender: Any) {
        audioRecorder == nil ? startRecording() : finishRecording(success: true)
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            self.recordBtn.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            self.recordBtn.setTitle("Grabar otra", for: .normal)
        } else {
            self.recordBtn.setTitle("Grabar", for: .normal)
            // recording failed :(
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let asset = AVURLAsset(url: recorder.url)
        let a = asset.duration.timeString
        if !flag {
            finishRecording(success: false)
        }
    }
    @IBAction func shareAudio(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [getDocumentsDirectory().appendingPathComponent("recording.m4a")], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
}

extension CMTime {
    var timeString: String {
        let sInt = Int(seconds)
        let s: Int = sInt % 60
        let m: Int = (sInt / 60) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

