

import UIKit
let mySpecialNotificationKey = "kapat"

class MainNavigationController: UINavigationController,SINCallDelegate,SINCallClientDelegate,SINClientDelegate {
    let settings = GlobalViewController()
    
    fileprivate var mainSelectedObserver: NSObjectProtocol?
    fileprivate var redSelectedObserver: NSObjectProtocol?
    fileprivate var greenSelectedObserver: NSObjectProtocol?
    fileprivate var searchSelectedObserver: NSObjectProtocol?
    fileprivate var callSelectedObserver: NSObjectProtocol?
    fileprivate var howSelectedObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    override func viewDidLoad() {
        let x = AppDelegate()
        x.initSinchClient()
        _call?.delegate = self
        _client?.call().delegate = self
        _client?.delegate = self

    }
    fileprivate func addObservers() {
        let center = NotificationCenter.default
        
       
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        mainSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.MainSelected), object: nil, queue: nil) { (notification: Notification!) in
            let mvc = storyboard.instantiateViewController(withIdentifier: "MainViewController") 
            self.setViewControllers([mvc], animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)

        }
        
        redSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.RedSelected), object: nil, queue: nil) { (notification: Notification!) in
            let rvc = storyboard.instantiateViewController(withIdentifier: "RedViewController") 
            self.setViewControllers([rvc], animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)

        }
        
        greenSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.GreenSelected), object: nil, queue: nil) { (notification: Notification!) in
            let gvc = storyboard.instantiateViewController(withIdentifier: "GreenViewController") 
            self.setViewControllers([gvc], animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)

        }
        
        searchSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.SearchSelected), object: nil, queue: nil) { (notification: Notification!) in
            let gvc = storyboard.instantiateViewController(withIdentifier: "SearchViewController")
            self.setViewControllers([gvc], animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)

        }
        callSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.CallSelected), object: nil, queue: nil) { (notification: Notification!) in
            let gvc = storyboard.instantiateViewController(withIdentifier: "ProfileDetailViewController")
            self.setViewControllers([gvc], animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)

        }
        howSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.howSelected), object: nil, queue: nil) { (notification: Notification!) in
            let gvc = storyboard.instantiateViewController(withIdentifier: "HowViewController")
            self.setViewControllers([gvc], animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)
            
        }

        
    }
    
    fileprivate func removeObservers(){
        let center = NotificationCenter.default
        
        if mainSelectedObserver !=  nil {
            center.removeObserver(mainSelectedObserver!)
        }
        if redSelectedObserver != nil {
            center.removeObserver(redSelectedObserver!)
        }
        if greenSelectedObserver != nil {
            center.removeObserver(greenSelectedObserver!)
        }
        if searchSelectedObserver != nil {
            center.removeObserver(searchSelectedObserver!)
        }
        if howSelectedObserver != nil {
            center.removeObserver(howSelectedObserver!)
        }
    }

    
    
    
    
    
    
    func client(_ client: SINCallClient, didReceiveIncomingCall call: SINCall) {
        print("cagri geldi")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closecall"), object: nil)

        if settings.getDefaults(isim: "gorundu")=="0" {
            
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! CallDetailViewController
        self.present(vc, animated: true, completion: nil)
        vc.nereden=1
        vc.client(client, didReceiveIncomingCall: call)
    }
    
      
    
    func client(_ client: SINClient, localNotificationForIncomingCall call: SINCall) -> SINLocalNotification {
        let notification = SINLocalNotification()
        notification.alertAction = "Answer"
        notification.alertBody = "Incoming call from \(call.remoteUserId)"
        return notification
    }
     
      func client(_ client: SINClient!, logMessage message: String!, area: String!, severity: SINLogSeverity, timestamp: Date!) {
        if _call?.state == SINCallState.ended {
            settings.saveDefaults(deger: "1", isim: "kapat")
        }
    }
    
    func clientDidStop(_ client: SINClient!) {
        print("client stop")
        
    }
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("sinch fail" + error.localizedDescription)
        
    }
    func clientDidStart(_ client: SINClient!) {
        print("sinch start)")
        
    }
    func  callDidEstablish(_ call: SINCall!) {
        print("callestanblished")
    }
    func callDidEnd(_ call: SINCall!) {
        print("call end")
    }
    func callDidProgress(_ call: SINCall!) {

    }
    func callDidAddVideoTrack(_ call: SINCall!) {
        print("call video added")
    }

    
}
