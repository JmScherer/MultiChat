//
//  SpeechToTextViewController.swift
//  SeniorDesignProject2
//
//  Created by James Scherer on 11/1/17.
//  Copyright © 2017 James Scherer. All rights reserved.
//

import UIKit
import Firebase
import googleapis
import AVFoundation
import ROGoogleTranslate

let API_KEY = "AIzaSyDwfbLIPRIBeWUS5z9BaYVtb9NBOQ95_Lw"

let SAMPLE_RATE = 16000

class SpeechToTextViewController: UIViewController, langSelectProtocol, AudioControllerDelegate {
    
    @IBOutlet weak var microphoneButtonPressed: UIButton!
    @IBOutlet weak var translatedTextView: UITextView!
    @IBOutlet weak var selectedLanguageLabel: UILabel!
    
    var channelRef: DatabaseReference?
    var channel: Channel?
    var voiceMessages: Array<Any>!
    var senderId: String!
    var selectedLanguage: String = "English"
    var selectedSynthLanguage: String = "en-US"
    var selectedTransLanguage: String = "en"
    
    var audioData: NSMutableData!
    
    private var userTalking = false
    private var voiceMessageRefHandle: DatabaseHandle?
    
    private lazy var voiceMessageRef: DatabaseReference = self.channelRef!.child("voiceMessage")
    private lazy var userIsTalkingRef: DatabaseReference = self.channelRef!.child("talkingIndicator").child(self.senderId)
    private lazy var usersTalkingQuery: DatabaseQuery = self.channelRef!.child("talkingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    var isTalking: Bool {
        get {
            return userTalking
        }
        set {
            userTalking = newValue
            userIsTalkingRef.setValue(newValue)
        }
    }
    
    func setLanguage(lang: String, synthLang: String, transLang: String) {
        selectedLanguage = lang
        selectedSynthLanguage = synthLang
        selectedTransLanguage = transLang
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.selectedLanguageLabel.text = "English"
        AudioController.sharedInstance.delegate = self
        observeVoiceMessage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        self.selectedLanguageLabel.text = selectedLanguage
        
        observeTalking()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func microphoneButtonPressed(_ sender: Any) {
        isTalking = true
        print(isTalking)
        
        microphoneButtonPressed.tintColor = UIColor.blue
        
        
        // Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    @IBAction func microphoneButtonTouchUp(_ sender: Any) {
        isTalking = false
        print(isTalking)
        
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        
        microphoneButtonPressed.tintColor = UIColor.white
        
    }
    
    private func observeTalking() {
        let talkingIndicatorRef = channelRef!.child("talkingIndicator")
        userIsTalkingRef = talkingIndicatorRef.child(senderId)
        userIsTalkingRef.onDisconnectRemoveValue()
        
        usersTalkingQuery.observe(.value) { (data: DataSnapshot) in
            if data.childrenCount == 1 && self.isTalking {
                return
            }
        }
    }
    
    private func observeVoiceMessage() {
        voiceMessageRef = channelRef!.child("voiceMessage")
        
        let voiceMessageQuery = voiceMessageRef.queryLimited(toLast: 2)
        
        voiceMessageRefHandle = voiceMessageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let voiceMessageData = snapshot.value as! Dictionary<String, String>
            
            if let id = voiceMessageData["senderId"] as String?, let voiceMessage = voiceMessageData["voiceMessage"] as String?, voiceMessage.characters.count > 0, let messageLang = voiceMessageData["language"] as String? {
                
                if(id != self.senderId) {
                    
                    self.translatedTextView.text = voiceMessage
                    
                    if (messageLang == self.selectedTransLanguage) {
                    
                        self.translatedTextView.text = voiceMessage
                    }
                    else {
                        
                        let translator = ROGoogleTranslate()
                        translator.apiKey = API_KEY
                    
                        var params = ROGoogleTranslateParams()
                    
                        params.source = messageLang
                        params.target = self.selectedTransLanguage
                        params.text = self.translatedTextView.text
                        
                        translator.translate(params: params) { (result) in
                            DispatchQueue.main.async {
                                self.translatedTextView.text = "\(result)"
                                print("Translation Result Finished")
                            }
                        }
                    
                    print("Observe Finished")
                        
                    }
                }
            }
        })
        
        print("I am outside all together")
    }
    
    @IBAction func synthesizeVoiceButtonPressed(_ sender: Any) {
        
        let string = translatedTextView.text
        let utterance = AVSpeechUtterance(string: string!)
        utterance.voice = AVSpeechSynthesisVoice(language: selectedSynthLanguage)
        utterance.preUtteranceDelay = 0.5
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func languageButtonPressed(_ sender: Any) {
        //performSegue(withIdentifier: "langueSelectSegue", sender: Any?)
        
        let langSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "LanguageSelectTableViewController") as! LanguageSelectTableViewController
        
        langSelectVC.delegate = self
        
        self.navigationController?.pushViewController(langSelectVC, animated: true)
        
    }
    
    @IBAction func recordAudio(_ sender: NSObject) {
        
    }
    
    @IBAction func stopAudio(_ sender: NSObject) {
       
    }
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                    completion:
                { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        strongSelf.translatedTextView.text = error.localizedDescription
                    } else if let response = response {
                        var finished = false
                        print(response)
                        for result in response.resultsArray! {
                            if let alternative = result as? StreamingRecognitionResult {
                                for a in alternative.alternativesArray{
                                    if let ai = a as? SpeechRecognitionAlternative{
                                        print("alternative i: ")  //log to console
                                        print(ai)
                                        if(alternative.isFinal){
                                            //print("*** FINAL ASR result: "+ai.transcript)
                                            
                                            self?.translatedTextView.text = ai.transcript
                                            //strongSelf.stopGoogleStreamingASR(strongSelf)
                                            
                                            let itemRef = self?.voiceMessageRef.childByAutoId()
                                            let voiceMessageItem = ["senderId": self?.senderId!,
                                                                    "voiceMessage": self?.translatedTextView.text!,
                                                                    "language":  self?.selectedTransLanguage]
                                            
                                            itemRef?.setValue(voiceMessageItem)
                                        }
                                        else{
                                            print("*** PARTIAL ASR result: "+ai.transcript)
                                        }
                                    }
                                }

                                    
                                //if result.isFinal {
                                  //  finished = true
                                //}
                            }
                        }
                        
                            //self?.updateText(jsonResponse: response.resultsArray)
                            //strongSelf.translatedTextView.text = response.description
                            //self?.updateText(jsonResponse: response.description)
                        if finished {
                            strongSelf.stopAudio(strongSelf)
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }
    
    func updateText(jsonResponse: NSMutableArray) {
        print(jsonResponse)
    }
    
}
