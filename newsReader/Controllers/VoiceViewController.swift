//
//  VoiceViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 26.01.22.
//

import UIKit
import Speech

class VoiceViewController: UIViewController {

    
    @IBOutlet weak var lb_speech: UILabel!
    @IBOutlet weak var btn_start: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speechReconizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    let speechReconizer1: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier:  "en-US"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isStart : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestPermission()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btn_start_stop(_ sender: Any) {
        
        isStart = !isStart
        
        if isStart {
            startSpeechRecognization()
            btn_start.setTitle("start", for: .normal)
            btn_start.backgroundColor = .systemGreen
           
        } else {
            cancelSpeechRecognization()
            btn_start.setTitle("stop", for: .normal)
            btn_start.backgroundColor = .systemRed
          
        }
    }
    
    func requestPermission() {
        self.btn_start.isEnabled = false
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    self.btn_start.isEnabled = true

                } else if authState == .denied {
                    self.alertView(message: "User denied the Permission")
                }else if authState == .notDetermined {
                    self.alertView(message: "In user phone there is no speech recognization")
                }else if authState == .restricted {
                    self.alertView(message: "User has been restricted for using the speech recognization")
                }
            }
            
        }
    }
    
    
    func startSpeechRecognization() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){ (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            alertView(message: "\(error)")
        }
        
        
        guard let myRecognization = SFSpeechRecognizer() else {
            self.alertView(message: "Recognization is not allow now")
            return
        }
        if !myRecognization.isAvailable {
            self.alertView(message: "Recognization is free right now")
        }
        
        task = speechReconizer?.recognitionTask(with: request, resultHandler: { (response, error) in
            
            guard let response = response else{
                if error != nil{
                   // self.alertView(message: error.debugDescription)
                }
                else{
                    self.alertView(message: "problem is giving")
                }
                return
            }
        
            var message = response.bestTranscription.formattedString
           
            
            if message == "Клюква"{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
                
                self.show(secondViewController, sender: nil)
            }
            
            
            var lastSring: String = ""
            for segment in response.bestTranscription.segments {
                let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                lastSring = String(message[indexTo...])
            }
  
            print(message)
            message = message.lowercased()
            
            self.lb_speech.text = message
            
            
        })
        
    }
    
    func cancelSpeechRecognization(){
        
        task.finish()
        task.cancel()
        task = nil
        
        request.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    func alertView(message: String) {
        let controller = UIAlertController.init(title: "Error ocured...!", message: message ,
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }
  

}
