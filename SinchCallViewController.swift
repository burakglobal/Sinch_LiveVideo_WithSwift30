//
//  SinchCallViewController.swift
//  Sinch with Swift 3.0
//
//  Created by BURAK KEBAPCI on 3/6/17. 
//

import UIKit
import SwiftyJSON
import PushKit
import Cosmos

class SinchCallViewController: UIViewController,SINCallDelegate,SINCallClientDelegate {
  
    
    @IBOutlet weak var starViewAttributeOne: CosmosView!
    @IBOutlet weak var starViewAttributeTwo: CosmosView!
    @IBOutlet weak var starViewAttributeThree: CosmosView!

    @IBOutlet weak var ratingView: UIVisualEffectView!
    @IBOutlet var starView: UIView!
    @IBOutlet weak var startViewSkip: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var answer: UIButton!
    @IBOutlet weak var hangupButton: UIButton!

    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ssdetail: UILabel!
    @IBOutlet weak var sstitle: UILabel!
    

    var nereden = 0
    var incoming = 0
    var passedvalue:String = ""
    var id:String = ""
    var fbid:String = ""
    var picture:String = ""
    var location:String = ""
    var seconds:Int = 0
    var rating:String = ""
    var settings = GlobalViewController()
    var durationTimer: Timer!
    var effect:UIVisualEffect!
    
    enum FileTransferError: Error {
        case noConnection
        case lowBandwidth
        case fileNotFound
    }
    
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
     
    @IBAction func speakerButtonClicked(_ sender: Any) {
        
        if (speakerButton.currentImage?.isEqual(UIImage(named: "101-speaker-2")))! {
        
            if let image = UIImage(named: "101-speaker-1") {
            speaker()
            
            self.speakerButton.setImage(image, for: .normal)
            
        }
        }
            else
        {
            if let image = UIImage(named: "101-speaker-2") {
                speakerOff()
                
                self.speakerButton.setImage(image, for: .normal)
                
            }
            
        }
        
    }
    @IBAction func Answer(_ sender: Any) {
        audioController?.stopPlayingSoundFile()
        ssdetail.text = "In Conversation"
        imageView.isHidden = true
        _call?.answer()
        localVideoView.isHidden = false
        remoteVideoView.isHidden = false
        sstitle.text = "Answered"
        answer.isHidden=true
        hangupButton.isEnabled=true
        callButton.isEnabled = false
        speakerButton.isHidden = false
        captureSession.stopRunning()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        settings.updategetcalls(status: "1")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
               
        
        //settings.updategetcalls(status: "0")
        NotificationCenter.default.addObserver(self, selector: #selector(closeme(_:)), name: NSNotification.Name(rawValue: "closecall"), object: nil)
        
         _call?.delegate = self
        remoteVideoView.layer.borderColor = UIColor(red: 2, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        remoteVideoView.layer.cornerRadius = 5.0
        remoteVideoView.contentMode = .scaleAspectFit
        remoteVideoView.layer.borderWidth = 2
        
        videoController?.remoteView().contentMode = .scaleAspectFill
        audioController = _client?.audioController()
        videoController  = _client?.videoController()
        self.localVideoView.addSubview((videoController?.localView())!)

        
        effect = ratingView.effect
        ratingView.effect = nil
        starView.layer.cornerRadius = 5
        
    }
    
    
    func tableviewdengeldi() {
        sstitle.text = passedvalue
        ssdetail.text = location
        
        
        imageView.downloadedFrom(link: picture)
        callButton.isHidden = false
        
        imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        imageView.layer.cornerRadius = 45
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 2
        homeButton.isHidden = false
        speakerButton.isHidden = false
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice]
        {
            for device in devices
            {
                if (device.hasMediaType(AVMediaTypeVideo))
                {
                    if(device.position == AVCaptureDevicePosition.front)
                    {
                        captureDevice = device
                        if captureDevice != nil
                        {
                            print("Capture device found")
                            beginSession()
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    func beginSession()
    {
        do
        {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput)
            {
                captureSession.addOutput(stillImageOutput)
            }
        }
        catch
        {
            print("error: \(error.localizedDescription)")
        }
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else
        {
            print("no preview layer")
            return
        }
        self.view.layer.addSublayer(previewLayer)
        previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        //self.view.addSubview(imageView)
        self.view.bringSubview(toFront: hangupButton)
        self.view.bringSubview(toFront: callButton)
        self.view.bringSubview(toFront: imageView)
        self.view.bringSubview(toFront: ssdetail)
        self.view.bringSubview(toFront: sstitle)
        self.view.bringSubview(toFront: speakerButton)
        self.view.bringSubview(toFront: homeButton)
        
    }
    
    
    func runTimedCode() {
        
        seconds += 1
        self.ssdetail.text = String(format: "%02d:%02d", Int(seconds / 60), Int(seconds % 60))
        if (settings.getDefaults(isim: "kapat")=="1")
        {
            settings.saveDefaults(deger: "0", isim: "kapat")
            reset()
        }
         if incoming == 1 {
            
    
            if sstitle.text != "Answered" {
               
                self.sstitle.text =  settings.getDefaults(isim: "callerid") + " Is Calling..."
               
            }
            if imageView.image == nil {
                let g:String   = settings.getDefaults(isim: "callerpicture")
                    if g != "" {
                            imageView.downloadedFrom(link: g)
                        imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
                        imageView.layer.cornerRadius = 45
                        imageView.contentMode = .scaleToFill
                        imageView.layer.borderWidth = 2
                        
                    }
            }
        }
             }
    
    
    func internal_updateDuration(_ timer: Timer) {
        let selector: Selector? = NSSelectorFromString(timer.userInfo as! String)
        if self.responds(to: selector) {
            //clang diagnostic push
            //clang diagnostic ignored "-Warc-performSelector-leaks"
            self.perform(selector, with: timer)
            //clang diagnostic pop
        }
    }
    
    
    func speaker() {
        let audio: SINAudioController = _client!.audioController()
        audio.enableSpeaker()
    }
    
    func speakerOff() {
        let audio: SINAudioController = _client!.audioController()
        audio.disableSpeaker()
    }
    
    func path(forSound soundName: String) -> String {
        return URL(fileURLWithPath: (Bundle.main.resourcePath)!).appendingPathComponent(soundName).absoluteString
    }
    
    
    func client(_ client: SINCallClient, didReceiveIncomingCall call: SINCall) {
        //settings.updategetcalls(status: "0")
        ssdetail.text = call.remoteUserId
        settings.addactivity(fromuserid: ssdetail.text!, userid:settings.getDefaults(isim: "facebookID") ,  desc: "Incoming Call...")
        self.sstitle.text =  settings.getUserDetails(call.remoteUserId) + " Is Calling..."
        let soundFilePath: String? = Bundle.main.path(forResource: "incoming", ofType: "wav")
        // get audio controller from SINClient
         audioController?.startPlayingSoundFile(soundFilePath, loop: false)
        print(call.callId)
        
        _call = call
        self.remoteVideoView.addSubview((videoController?.remoteView())!)
        remoteVideoView.sizeToFit()
        
        durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        seconds=0
        
        //imageView.isHidden = true
        imageView.image = nil
        incoming = 1
        
        answer.isHidden=false
        hangupButton.isEnabled=true
        callButton.isEnabled = false
      
        
    }
    
    @IBAction func hangup(_ sender: Any) {
        if hangupButton.isEnabled == true  { reset() }
    }
    
    func reset()
    {
        settings.updategetcalls(status: "1")
        
        try! settings.addactivity(fromuserid: (_call?.remoteUserId)!, userid:settings.getDefaults(isim: "facebookID") ,  desc: "Hang up")
        settings.saveDefaults(deger: "0", isim: "kapat")
        _call?.hangup()
        _call = nil
        audioController?.stopPlayingSoundFile()
        sstitle.text = passedvalue
        ssdetail.text = location
        durationTimer.invalidate()
        imageView.isHidden = false
        localVideoView.isHidden = true
        remoteVideoView.isHidden = true
        incoming = 0
        answer.isHidden=true
        hangupButton.isEnabled = false
        callButton.isEnabled = true
     
        if callButton.titleLabel?.text == " Close " {
            imageView.image = nil
            imageView.downloadedFrom(link: settings.getDefaults(isim: "picture"))
            imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            imageView.layer.cornerRadius = 45
            imageView.contentMode = .scaleToFill
            imageView.layer.borderWidth = 2

        }
        if seconds > 10 {
            animateIn()
            seconds = 0
        }
        if (nereden==1) {
            dismiss(animated: true, completion: nil)
        }
        

    }
    private func client(_ client: SINClient, localNotificationForIncomingCall call: SINCall) -> SINLocalNotification {
        let notification = SINLocalNotification()
        notification.alertAction = "Answer"
        notification.alertBody = "Incoming call"
        return notification
    }
    
    
   
   
    
    
    
    func setCall(_ call: SINCall) {
        _call = call
        _call?.delegate = self
      
    }
    
    
    func checkstatus(_ fbid: String)      {
        _ = "0"
        let makeURL = settings.serverip + "/_table/member?fields=*&filter=fbid=" + fbid + "&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        print("find account :\(makeURL)")
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            if response != nil {
                DispatchQueue.main.async {
                    
                    let json = JSON(data: data)
                    let getDict = json["resource"]
                    let fbidd = getDict[0]["fbid"]
                    
                    
                    if fbidd != JSON.null {
                        if getDict[0]["status"]==1 {
                            
                            
                            if let getcx = getDict[0]["getcalls"].string {
                                getc = getcx
                     
                                self.checkstatuscompleted()
                            }
                        }}}}}
        task.resume()
        
    }

    
    
    @IBAction func call(_ sender: Any) {
        
        self.checkstatus(self.fbid)
    }
    
    func checkstatuscompleted()
    {
    
        if (getc=="0"){
            let uiAlert = UIAlertController(title: "Video Chat", message: "This user not accepting call at this time!, But we notified the user!", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))

            
            return
        }
        else
        {
        
        print(fbid)
        if callButton.titleLabel?.text == " Close " {
            self.dismiss(animated: true, completion: nil)
            return
        }
        _call = _client?.call().callUserVideo(withId: self.fbid)
        self.sstitle.text = "Calling..."
        settings.addactivity(fromuserid: settings.getDefaults(isim: "facebookID"), userid: (_call?.remoteUserId)!,  desc: "Call Out")

        let soundFilePath: String? = Bundle.main.path(forResource: "ringback", ofType: "wav")
        audioController?.startPlayingSoundFile(soundFilePath, loop: false)
        remoteVideoView.addSubview((videoController?.remoteView())!)
        remoteVideoView.sizeToFit()
        
        durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        seconds=0
        localVideoView.isHidden = false
        remoteVideoView.isHidden = false
        answer.isHidden=true
        hangupButton.isEnabled=true
        callButton.isEnabled = false
        speakerButton.isHidden = false
        imageView.isHidden = true 
        
        }
        
    }

    
    func animateIn() {
        self.view.addSubview(starView)
        starView.center = self.view.center
        
        starView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        starView.alpha = 0
        self.view.bringSubview(toFront: ratingView)
        self.view.bringSubview(toFront: starView)
        
        UIView.animate(withDuration: 0.4) {
            self.ratingView.effect = self.effect
            self.starView.alpha = 1
            self.starView.transform = CGAffineTransform.identity
        }
        
    }
    
    @IBAction func starViewSkip(_ sender: Any) {
        
        
      getuserrating(fbid: self.fbid)
        
    }
    
    
    func getuserrating(fbid:String)
    {
        
        let makeURL = settings.serverip + "/_table/member?fields=*&filter=fbid=" + fbid + "&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        print("find account get just credit :\(makeURL)")
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            if response != nil {
                DispatchQueue.main.async {
                    
                    let json = JSON(data: data)
                    let getDict = json["resource"]
                    let fbidd = getDict[0]["fbid"]
                    
                    
                    if fbidd != JSON.null {
                        
                        
                        self.settings.saveDefaults(deger: String(describing: getDict[0]["attributeone"]), isim: "one")
                        self.settings.saveDefaults(deger: String(describing: getDict[0]["attributetwo"]), isim: "two")
                        self.settings.saveDefaults(deger: String(describing: getDict[0]["attributethree"]), isim: "three")
                        
                        
                        var one = getDict[0]["attributeone"].intValue
                        var two = getDict[0]["attributetwo"].intValue
                        var three = getDict[0]["attributethree"].intValue
                        
                        if self.starViewAttributeOne.rating==2 {
                            one=one-1
                        }
                        else if self.starViewAttributeOne.rating==1 {
                            one=one-2
                        }
                        else if self.starViewAttributeOne.rating==4 {
                            one=one+1
                        }
                        else if self.starViewAttributeOne.rating==5 {
                            one=one+2
                        }
                        
                        
                        if self.starViewAttributeTwo.rating==2 {
                            two=two-1
                        }
                        else if self.starViewAttributeTwo.rating==1 {
                            two=two-2
                        }
                        else if self.starViewAttributeTwo.rating==4 {
                            two=two+1
                        }
                        else if self.starViewAttributeTwo.rating==5 {
                            two=two+2
                        }
                        
                        
                        if self.starViewAttributeThree.rating==2 {
                            three=three-1
                        }
                        else if self.starViewAttributeThree.rating==1 {
                            three=three-2
                        }
                        else if self.starViewAttributeThree.rating==4 {
                            three=three+1
                        }
                        else if self.starViewAttributeThree.rating==5 {
                            three=three+2
                        }
                        
                        
                        if one < 0 { one = 0 }
                        if two < 0 { two = 0 }
                        if three < 0 { three = 0 }
                        
                        if one > 100 { one = 100 }
                        if two > 100 { two = 100 }
                        if three > 100 { three = 100 }
                        
                        
                        self.settings.saveDefaults(deger: String(describing: one), isim: "one")
                        self.settings.saveDefaults(deger: String(describing: two), isim: "two")
                        self.settings.saveDefaults(deger: String(describing: three), isim: "three")
                        
                        self.settings.updaterating(fbid: self.fbid)
                        
                        self.animateOut()

                        
                        
                        
                        
                        
                    }}}}
        task.resume()
    }

    
    
    func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.starView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.starView.alpha = 0
            
            self.ratingView.effect = nil
            
        }) { (success:Bool) in
            self.starView.removeFromSuperview()
            self.view.bringSubview(toFront: self.hangupButton)
            self.view.bringSubview(toFront: self.callButton)
            self.view.bringSubview(toFront: self.imageView)
            self.view.bringSubview(toFront: self.ssdetail)
            self.view.bringSubview(toFront: self.sstitle)
            self.view.bringSubview(toFront: self.speakerButton)
            self.view.bringSubview(toFront: self.homeButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeme(_ sender: Any) {
        if hangupButton.isEnabled {
            reset()
            return
        }
        if incoming==1 {
            reset()
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
   
    func findAccount(_ fbid: String)
    {
        let makeURL = settings.serverip + "/_table/member?fields=*&filter=fbid=" + fbid + "&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        print("find account :\(makeURL)")
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            if response != nil {
                
                let json = JSON(data: data)
                let getDict = json["resource"]
                let fbidd = getDict[0]["fbid"]
                
                
                if fbidd != JSON.null {
                    
                  
                }
                
                
                
            }
        }
        task.resume()
        
    }

}
