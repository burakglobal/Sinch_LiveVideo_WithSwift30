
import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import KDCircularProgress

class MainViewController: UIViewController,CLLocationManagerDelegate,SINCallDelegate,SINCallClientDelegate,SINClientDelegate {
    
    
    @IBOutlet weak var monthLabel: UILabel!
    var locationManager = CLLocationManager()
    var durationTimer: Timer!
    var settings = GlobalViewController()
    @IBOutlet weak var viewProfileBox: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var attributeOne: UILabel!
    @IBOutlet weak var attributeTwo: UILabel!
    @IBOutlet weak var attributeThree: UILabel!
    
    @IBOutlet weak var buttonSettings: UIButton!
    var progress: KDCircularProgress!
    var progress1: KDCircularProgress!
    var progress2: KDCircularProgress!
    
    @IBOutlet weak var dotAttributeOne: UIView!
    @IBOutlet weak var dotAttributeTwo: UIView!
    @IBOutlet weak var dotAttributeThree: UIView!

    var fruits  =  [String]()
    var fruits1  =  [String]()
    var rating  =  [String]()
    var pictures  =  [String]()
    var fbid  =  [String]()
    var id  =  [String]()
    var uzaklik  =  [Double]()
    var getcalls  =  [String]()
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("location paused")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("location resumed")
    }

    
    @IBAction func settingsButtonTouchDown(_ sender: Any) {
        performSegue(withIdentifier: "Settings", sender: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
       
        
        
        CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) in
            
            // Check for errors
            if error != nil {
                
                print(error ?? "Unknown Error")
                
            } else {
                
                // Get the first placemark from the placemarks array.
                // This is your address object
                if let placemark = placemarks?[0] {
                    
                    // Create an empty string for street address
                    var streetAddress = ""
                    
                    // Check that values aren't nil, then add them to empty string
                    // "subThoroughfare" is building number, "thoroughfare" is street
                    if placemark.subThoroughfare != nil && placemark.thoroughfare != nil {
                        
                        streetAddress = placemark.subThoroughfare! + " " + placemark.thoroughfare!
                        
                    } else {
                        
                        print("Unable to find street address")
                        
                    }
                    
                    // Same as above, but for city
                    var city = ""
                    
                    // locality gives you the city name
                    if placemark.locality != nil  {
                        
                        city = placemark.locality!
                        
                    } else {
                        
                        print("Unable to find city")
                        
                    }
                    
                    // Do the same for state
                    var state = ""
                    
                    // administrativeArea gives you the state
                    if placemark.administrativeArea != nil  {
                        
                        state = placemark.administrativeArea!
                        
                    } else {
                        
                        print("Unable to find state")
                        
                    }
                    
                    // And finally the postal code (zip code)
                    var zip = ""
                    
                    if placemark.postalCode != nil {
                        
                        zip = placemark.postalCode!
                        
                    } else {
                        
                        print("Unable to find zip")
                        
                    }
                    
                    print("\(streetAddress)\n\(city), \(state) \(zip)")
                    
                 //   self.updateLocation(locationText: String(describing: locations),adr: "\(streetAddress),\(city), \(state) \(zip)")
                    self.updateLocation(locationText: String(describing: locations),adr: "\(city), \(state)",latitude: String(userLocation.coordinate.latitude),longitude: String(userLocation.coordinate.longitude))
                    self.settings.saveDefaults(deger: "\(city), \(state)", isim: "currentaddress")
                
                
                
                }
                
            }
        }
        
        
}
        
        
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func client(_ client: SINCallClient, didReceiveIncomingCall call: SINCall) {
        print("cagri geldi")
        
        if settings.getDefaults(isim: "gorundu")=="0" {
            
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! ProfileDetailViewController
        self.present(vc, animated: true, completion: nil)
        vc.nereden=1
        vc.client(client, didReceiveIncomingCall: call)
    }
    
    
    
    private func client(_ client: SINClient, localNotificationForIncomingCall call: SINCall) -> SINLocalNotification {
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

    
    
    override func viewDidLoad() {
        
        let newDate =  Date()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "house-black-building-shape-2")
        imageView.image = image
        navigationItem.titleView = imageView
        

        
        monthLabel.text = newDate.monthMedium
        
        let x = AppDelegate()
        x.initSinchClient()
        _call?.delegate = self
        _client?.call().delegate = self
        _client?.delegate = self

        let navigationBarAppearace = UINavigationBar.appearance()
        
        //navigationBarAppearace.tintColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        //navigationBarAppearace.barTintColor = UIColor(red:0.76, green:0.40, blue:0.40, alpha:1.0)
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
       
        
        profileImage.downloadedFrom(link: settings.getDefaults(isim: "picture"))
        profileImage.setRounded()
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.borderWidth = 1
        
        //Dots
        dotAttributeOne.roundCorners([.topLeft,.topRight,.bottomRight,.bottomLeft], radius: 20)
        dotAttributeTwo.roundCorners([.topLeft,.topRight,.bottomRight,.bottomLeft], radius: 20)
        dotAttributeThree.roundCorners([.topLeft,.topRight,.bottomRight,.bottomLeft], radius: 20)
        
        viewProfileBox.roundCorners([.topLeft,.topRight], radius: 20)

    
       
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            
            if ((UIDevice.current.systemVersion as NSString).floatValue >= 8)
            {
                locationManager.requestWhenInUseAuthorization()
            }
            
        }
        else
        {
            #if debug
                println("Location services are not enabled");
            #endif
        }
          durationTimer = Timer.scheduledTimer(timeInterval: 30000, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        getData()
        
        
        
        if let x:String = settings.getDefaults(isim: "t") {
            print(x)
            if x == "" {
                settings.saveDefaults(deger: "1", isim: "t")
                tutorialButton(self)
            }
        }

    }
    
    
    func getprogress()
    {
        
        //_ =  profileImage.frame.maxX-profileImage.frame.origin.x
       // _ =  profileImage.frame.maxY-profileImage.frame.origin.y
        
        
        let y1 = profileImage.frame.maxX-65
        let y2 = profileImage.frame.maxY-65
        
        
        var acalc = 360.0
        var bcalc = 360.0
        var ccalc = 360.0
        
        
        acalc = 3.6 * Double(settings.getDefaults(isim: "attributeone"))!
        bcalc = 3.6 * Double(settings.getDefaults(isim: "attributetwo"))!
        ccalc = 3.6 * Double(settings.getDefaults(isim: "attributethree"))!
        
        
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 170, height: 170))
        progress.startAngle = -90
        progress.progressThickness = 0.1
        progress.trackThickness = 0.1
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = false
        progress.glowMode = .forward
        progress.glowAmount = 0.1
        //progress.set(colors: UIColor.cyan ,UIColor.white, UIColor.magenta, UIColor.white, UIColor.orange)
        progress.set(colors: hexStringToUIColor(hex: "#F0AE63"))
        progress.center = CGPoint(x: y1, y: y2)
        viewProfileBox.addSubview(progress)
        
        progress.animate(fromAngle: 0, toAngle: acalc, duration: 5) { completed in
            if completed {
                self.attributeOne.text = "%\(self.settings.getDefaults(isim: "attributeone"))"
            } else {
                print("animation stopped, was interrupted")
            }
        }
        
        
        progress1 = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 205, height: 205))
        progress1.startAngle = -90
        progress1.progressThickness = 0.1
        progress1.trackThickness = 0.1
        progress1.clockwise = true
        progress1.gradientRotateSpeed = 2
        progress1.roundedCorners = false
        progress1.glowMode = .forward
        progress1.glowAmount = 0.1
        progress1.set(colors: hexStringToUIColor(hex: "#76CFC2"))
        progress1.center = CGPoint(x: y1, y: y2)
        viewProfileBox.addSubview(progress1)
        
        progress1.animate(fromAngle: 0, toAngle: bcalc, duration: 6) { completed in
            if completed {
                self.attributeTwo.text = "%\(self.settings.getDefaults(isim: "attributetwo"))"
            } else {
                print("animation stopped, was interrupted")
            }
        }
        
        
        progress2 = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
        progress2.startAngle = -90
        progress2.progressThickness = 0.1
        progress2.trackThickness = 0.1
        progress2.clockwise = true
        progress2.gradientRotateSpeed = 2
        progress2.roundedCorners = false
        progress2.glowMode = .forward
        progress2.glowAmount = 0.1
        progress2.set(colors: hexStringToUIColor(hex: "#8C88F7"))
        progress2.center = CGPoint(x: y1, y: y2)
        viewProfileBox.addSubview(progress2)
        
        progress2.animate(fromAngle: 0, toAngle: ccalc, duration: 8) { completed in
            if completed {
                self.attributeThree.text = "%\(self.settings.getDefaults(isim: "attributethree"))"
            } else {
                print("animation stopped, was interrupted")
            }
        }
        
        
        for i in 0 ..< Int(settings.getDefaults(isim: "attributeone"))! {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                self.attributeOne.text = "%\(i)"
            })
        }
        
        for i in 0 ..< Int(settings.getDefaults(isim: "attributetwo"))! {
           DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.attributeTwo.text = "%\(i)"
           })

        }
        
        for i in 0 ..< Int(settings.getDefaults(isim: "attributethree"))! {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                self.attributeThree.text = "%\(i)"
            })

        }
        

    }
    
    func runTimedCode() {
       
        getData()
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            self.view.rightToLeftAnimation(duration: 2.5, completionDelegate: nil)
            
            performSegue(withIdentifier: "NewRedViewController", sender: nil)
           
            
            
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            self.view.leftToRightAnimation(duration: 2.5, completionDelegate: nil)
            
            performSegue(withIdentifier: "GreenViewController", sender: nil)
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.up {
            
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.down {
            
           getRandomPerson()
            
            
            
        }
    }
    
    
    func getRandomPerson()
    {
        
       
        
        
        let localProfile = settings.getDefaults(isim: "facebookID")
        var makeURL = ""
 
            makeURL = settings.serverip + "/_table/member?limit=1&filter=(status=1) and (online=1) and (fbid <> " +  localProfile   + ")&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        
        
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                LoadingOverlay.shared.hideOverlayView()
                
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                LoadingOverlay.shared.hideOverlayView()
                
            }
            
            
            if response != nil {
                DispatchQueue.main.async {
                    let json = JSON(data: data)
                    
                    for item in json["resource"].arrayValue {
                        
                        self.fruits.append(item["name"].stringValue)
                        self.fruits1.append(item["lastaddress"].stringValue)
                        self.pictures.append(item["picture"].stringValue)
                        self.id.append(item["id"].stringValue)
                        self.fbid.append(item["fbid"].stringValue)
                        self.getcalls.append(item["getcalls"].stringValue)
                        
                        let xvalueToPass = self.fruits[0]
                        let xlocation = self.fruits1[0]
                        let xpicture = self.pictures[0]
                        let xid = self.id[0]
                        let xfbid = self.fbid[0]
                        
                        self.view.toBottomAnimation(duration: 2.5, completionDelegate: nil)
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! ProfileDetailViewController
                        
                            self.present(vc, animated: true, completion: nil)
                            vc.nereden = 0
                            vc.passedvalue = xvalueToPass
                            vc.location = xlocation
                            vc.id = xid
                            vc.fbid = xfbid
                            vc.picture = xpicture
                            vc.tableviewdengeldi()
                    }
                    
                    LoadingOverlay.shared.hideOverlayView()
                    
                }
                
                
                
            }
        }
        task.resume()
        
    }

    
    
    
    func tutorialButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowViewController") as! HowViewController
        self.present(vc, animated: true, completion: nil)
        //vc.close.isHidden = false
    }

    
    func hideKeyboard() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }

    
    func getData()
    {
       
        
        settings.loginToServer()
        locationManager.requestLocation()
        return
        
        
        
        
    }
    
    func updateLocation(locationText:String, adr:String, latitude:String, longitude:String)
    {
        let makeURL = settings.serverip + "/_table/member?filter=fbid=" + settings.getDefaults(isim: "facebookID") + "&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        
        let json = [
            "resource": [
                "online":"1",
                "lastlocation": locationText,
                "lastaddress": adr,
                "token": settings.getDefaults(isim: "token"),
                "longitude": longitude,
                "latitude": latitude
            ],
            ] as [String: Any]
        
        settings.saveDefaults(deger: longitude, isim: "longitude")
        settings.saveDefaults(deger: latitude, isim: "latitude")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        
        
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
                    
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                
                let lazyMapCollection = json.values
                
                let stringArray = Array(lazyMapCollection.map { String(describing: $0) })
                
                print(stringArray)
               
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
                }
                
            }
        }
        task.resume()
    }
 
    
    func goofline()
    {
        let makeURL = settings.serverip + "/_table/member?filter=fbid=" + settings.getDefaults(isim: "facebookID") + "&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        
        let json = [
            "resource": [
                "online":"0"
            ],
            ] as [String: Any]
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        
        
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
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                        
                        let lazyMapCollection = json.values
                        
                        let stringArray = Array(lazyMapCollection.map { String(describing: $0) })
                        
                        print(stringArray)
                        
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
                
            }
        }
        task.resume()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        settings.saveDefaults(deger: "1", isim: "gorundu")
        getprogress()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        settings.saveDefaults(deger: "0", isim: "gorundu")
        goofline()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
}

extension CGRect {
    
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        
        self.init(x:x, y:y, width:w, height:h)
    }
}
extension Formatter {
    static let monthMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    static let hour12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    static let minute0x: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    static let amPM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
}
extension Date {
    var monthMedium: String  { return Formatter.monthMedium.string(from: self) }
    var hour12:  String      { return Formatter.hour12.string(from: self) }
    var minute0x: String     { return Formatter.minute0x.string(from: self) }
    var amPM: String         { return Formatter.amPM.string(from: self) }
}
class SegueFromLeft: UIStoryboardSegue
{
    override func perform() {
        let src = self.source       //new enum
        let dst = self.destination  //new enum
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0) //Method call changed
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (finished) in
            src.present(dst, animated: false, completion: nil) //Method call changed
        }
    }
}
class SegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width*2, y: 0) //Double the X-Axis
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (finished) in
            src.present(dst, animated: false, completion: nil)
        }
    }
}
