//
//  Tune.swift
//  Autune
//
//  Created by Cordova Putra on 19/02/19.
//  Copyright © 2019 Cordova Putra. All rights reserved.
//

import UIKit
import Speech
import ARKit
import SceneKit

class Tune: UIViewController,ARSCNViewDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var tunebutton: UIButton!
    @IBOutlet weak var colorView: UIView!
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    
    //Box Test
    var box = UIView()
    
    @IBOutlet var sceneView: ARSCNView!
    var sceneController = MainScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
        automaticTune()
        
//        self.box.center = self.view.center
//        self.box.backgroundColor = UIColor.black     //give color to the view
//        self.box.frame = CGRect.init(x: 120, y: 150, width: 100, height: 100)
//        self.view.addSubview(box)
        sceneView.delegate = self
        
        if let scene = sceneController.scene {
            sceneView.scene = scene
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapScreen))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if let camera = sceneView.session.currentFrame?.camera {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -5.0
            let transform = camera.transform * translation
            let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            sceneController.addSphere(parent: sceneView.scene.rootNode, position: position)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.delegate = self as? ARSessionDelegate
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func automaticTune(){
        if isRecording == true {
            audioEngine.stop()
            recognitionTask?.cancel()
            isRecording = false
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
        }
    }
    
    func cancelRecording(){
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
    }
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                //                self.detectedTextLabel.text = bestString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                }
                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                self.sendAlert(message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.tunebutton.isEnabled = true
                case .denied:
                     self.tunebutton.isEnabled = false

                //                self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.tunebutton.isEnabled = false
                case .notDetermined:
                    self.tunebutton.isEnabled = false

                }
            }
        }
    }
    
    //MARK: - UI / Set view color.
    
    func checkForColorsSaid(resultString: String) {
     guard let childNode = self.sceneView.scene.rootNode.childNode(withName: "Sphere", recursively: true), let sphere = childNode as? Sphere else { return }
//        let animatorRight = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.7){
//            self.box.frame = CGRect.init(x: 120, y: 150, width: 100, height: 100)
//        }
//        let animatorLeft = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.7){
//            self.box.frame = CGRect.init(x: 30, y: 150, width: 100, height: 100)
//        }
        switch resultString {
            
            
        case "move":
//            animatorRight.startAnimation()
            sphere.animate()
//            sphere.animate()
           
//            colorView.backgroundColor = UIColor.red
        case "stop":
//            animatorLeft.startAnimation()
            sphere.stopAnimating()
//            colorView.backgroundColor = UIColor.orange
        case "yellow":
            colorView.backgroundColor = UIColor.yellow
        case "green":
            colorView.backgroundColor = UIColor.green
        case "blue":
            colorView.backgroundColor = UIColor.blue
        case "purple":
            colorView.backgroundColor = UIColor.purple
        case "black":
            colorView.backgroundColor = UIColor.black
        case "white":
            colorView.backgroundColor = UIColor.white
        case "gray":
            colorView.backgroundColor = UIColor.gray
        default: break
     
        }
    }
    
    //MARK: - Alert
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


}
