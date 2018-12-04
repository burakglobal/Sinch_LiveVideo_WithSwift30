//
//  CallDetailViewController
//
//  Created by BURAK KEBAPCI on 3/6/17. 
//

import UIKit
import SwiftyJSON
import PushKit

class CallDetailViewController: UIViewController,SINCallDelegate,SINCallClientDelegate {
    
  
    @IBOutlet weak var reportme: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var answer: UIButton!
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
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

    enum FileTransferError: Error {
        case noConnection
        case lowBandwidth
        case fileNotFound
    }
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
        

    }
    
    
    @IBAction func reportblock(_ sender: Any) {
        
        let alert = UIAlertController(title: "Report & Block", message: "Would you like to report & block this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes!", style: .default) { action in
            self.settings.blockthisprofile( userid: self.fbid)
            self.closeme(self)
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MainViewController"), object: nil)
            return

        })
        
        alert.addAction(UIAlertAction(title: "No", style: .default) { action in
            return
        })
        self.present(alert, animated: true)

        
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        settings.updategetcalls(status: "1")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "backgroundm")
        self.view.insertSubview(backgroundImage, at: 0)
       
        
        
        settings.updategetcalls(status: "0")
        NotificationCenter.default.addObserver(self, selector: #selector(closeme(_:)), name: NSNotification.Name(rawValue: "closecall"), object: nil)
        
         _call?.delegate = self
        remoteVideoView.contentMode = .scaleAspectFit
        
        videoController?.remoteView().contentMode = .scaleAspectFit
        audioController = _client?.audioController()
        videoController  = _client?.videoController()
        self.localVideoView.addSubview((videoController?.localView())!)

        callButton.bringSubview(toFront: self.view)
        hangupButton.bringSubview(toFront: self.view)
        speakerButton.bringSubview(toFront: self.view)
        ssdetail.bringSubview(toFront: self.view)
        sstitle.bringSubview(toFront: self.view)
        
        reportme.layer.cornerRadius = 10
        reportme.layer.borderWidth = 1
        reportme.layer.borderColor = UIColor.red.cgColor
        
    }
    func tableviewdengeldi() {
        sstitle.text = passedvalue
        ssdetail.text = location
        
        
        imageView.downloadedFrom(link: picture)
        
         
        
        imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        imageView.layer.cornerRadius = 45
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        
        
        ratingLabel.text = rating
    }
    func runTimedCode() {
        
        seconds += 1
   
        if seconds > 15 {
        if incoming != 1 {
            let z = Double(settings.getDefaults(isim: "credit"))
            print(z)
            if  (z! < callprice) {
                durationTimer.invalidate()
                hangup(self)
                settings.updatecredit(status: callprice, kac: "2")
                let uiAlert = UIAlertController(title: "Video Chat", message: "You have not enough credit to continue, Please add credit just $0.99!", preferredStyle: UIAlertControllerStyle.alert)
                self.present(uiAlert, animated: true, completion: nil)
                uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    print("Click of cancel button")
                }))
                return
            }
            settings.updatecredit(status: callprice, kac: "-")
            
        }
        }
        
        
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
                        imageView.contentMode = .scaleAspectFill
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
        settings.updategetcalls(status: "0")
        settings.addactivity(fromuserid: ssdetail.text!, userid:settings.getDefaults(isim: "facebookID") ,  desc: "Incoming Call...")
        self.sstitle.text =  settings.getUserDetails(call.remoteUserId) + " Is Calling..."
        let soundFilePath: String? = Bundle.main.path(forResource: "incoming", ofType: "wav")
        audioController?.startPlayingSoundFile(soundFilePath, loop: false)
        print(call.callId)
        
        _call = call
        self.remoteVideoView.addSubview((videoController?.remoteView())!)
        videoController?.remoteView().contentMode = .scaleAspectFit
        
        durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        seconds=0
        ratingLabel.isHidden = true
        
        //imageView.isHidden = true
        imageView.image = nil
        incoming = 1
        
        answer.isHidden=false
        hangupButton.isEnabled=true
        callButton.isEnabled = false
      
        
    }
    
    @IBAction func hangup(_ sender: Any) {
        
        if hangupButton.isEnabled == true  {
      
        do {
            try reset()
        } catch {
           print("error")
        }
            
        }
        
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
        hangupButton.isEnabled=false
        callButton.isEnabled = true
        speakerButton.isHidden = true
        ratingLabel.isHidden = false
        
     
        if callButton.titleLabel?.text == " Close " {
            imageView.image = nil
            imageView.downloadedFrom(link: settings.getDefaults(isim: "picture"))
            imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            imageView.layer.cornerRadius = 45
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderWidth = 2
            
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
        var getme = "0"
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
                    
                    if let json = try? JSON(data: data) {
                    let getDict = json["resource"]
                    let fbidd = getDict[0]["fbid"]
                    
                    
                    if fbidd != JSON.null {
                        if getDict[0]["status"]==1 {
                            
                            
                            if let getcx = getDict[0]["getcalls"].string {
                                getc = getcx
                     
                                self.checkstatuscompleted()
                            }
                        }
                        
                    }
                }
                    
                }
                
            }
            
        }
        task.resume()
        
    }

    
    
    @IBAction func call(_ sender: Any) {
        print(settings.getDefaults(isim: "credit"))
        var x = Double(settings.getDefaults(isim: "credit"))
        
        if x==nil || x==0 {
            let uiAlert = UIAlertController(title: "Video Chat", message: "You have not enough credit to call, Please add credit just $0.99!", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            
            return
        }
        self.checkstatus(self.fbid)
    }
    
    func checkstatuscompleted()
    {
    
        if (getc=="0"){
            
            settings.addactivity(fromuserid: settings.getDefaults(isim: "facebookID"), userid:self.fbid,  desc: "Missed Call!")

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
        //remoteVideoView.sizeToFit()
        videoController?.remoteView().contentMode = .scaleAspectFit
            
        durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        seconds=0
        localVideoView.isHidden = false
        remoteVideoView.isHidden = false
        answer.isHidden=true
        hangupButton.isEnabled=true
        callButton.isEnabled = false
        speakerButton.isHidden = false
        imageView.isHidden = true
        ratingLabel.isHidden = true
        
        
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
                
                if let json = try? JSON(data: data) {
                let getDict = json["resource"]
                let fbidd = getDict[0]["fbid"]
                
                
                if fbidd != JSON.null {
                    
                  
                }
                }
                
                
                
            }
        }
        task.resume()
        
    }

}
