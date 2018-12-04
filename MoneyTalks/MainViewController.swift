
import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import PermissionScope

class MainViewController: UIViewController, UITabBarDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var menubutton: UIBarButtonItem!
    @IBOutlet weak var gKutu: UIView!
    @IBOutlet weak var gResim: UIImageView!
    @IBOutlet weak var gAd: UILabel!
    @IBOutlet weak var gLocation: UILabel!
    @IBOutlet weak var gRating: UILabel!
    @IBOutlet weak var gCall: UIImageView!
    
    
    @IBOutlet weak var aKutu: UIView!
    @IBOutlet weak var aResim: UIImageView!
    
    var pozisyon = 0
    var nfruits  =  [String]()
    var nfruits1  =  [String]()
    var nrating  =  [String]()
    var npictures  =  [String]()
    var nfbid  =  [String]()
    var nid  =  [String]()
    var nuzaklik  =  [Double]()
    var ngetcalls  =  [String]()
    
    var fruits  =  [String]()
    var fruits1  =  [String]()
    var rating  =  [String]()
    var pictures  =  [String]()
    var fbid  =  [String]()
    var id  =  [String]()
    var uzaklik  =  [Double]()
    var getcalls  =  [String]()
    
    
    var xid:String = ""
    var xfbid:String = ""
    var xpicture:String = ""
    var xlocation:String = ""
    var xrating:String = ""
    let pscope = PermissionScope()

    
    
     var locationManager = CLLocationManager()
     var settings = GlobalViewController()
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var tabBarUpdate: UITabBarItem!
    
    var seconds = 0
         
    @IBAction func menuGoster(_ sender: Any) {
        
        }
    
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("location paused")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("location resumed")
    }

  
    @IBAction func menubuttonclicked(_ sender: Any) {
        if menuShown {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)
            return
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yapac"), object: nil)
            return
        }
    }
    
    @IBAction func goLeft(_ sender: Any) {
        if menuShown {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)
            return
        }
        pozisyon=pozisyon+1
        print(pozisyon)
        print(self.fruits.count)
        
        if pozisyon > self.fruits.count-1 {
           //self.gKutu.removeFromSuperview()
           //self.aKutu.removeFromSuperview()
            pozisyon = 0
        }
        if self.fruits.count == 0 {
            return
        }
             aResim.rightToLeftAnimation()
            gResim.leftToRightAnimation()

        self.gAd.text = self.fruits[self.pozisyon]
        self.gLocation.text = self.fruits1[self.pozisyon]
        let picture = self.pictures[self.pozisyon]
        self.gRating.text =  self.rating[self.pozisyon]
        self.gResim.image = nil
        
        DispatchQueue.main.async {
            self.gResim.downloadedFrom(link: picture)
            self.gResim.contentMode = UIViewContentMode.scaleAspectFill
            self.gResim.layer.borderWidth = 1
            self.gResim.layer.borderColor = UIColor.black.cgColor
            
            self.gResim.layer.cornerRadius = 10
            self.gResim.layer.borderWidth = 1
            
        }
        
        if  self.fruits.count-1 > pozisyon  {
            let picture = self.pictures[self.pozisyon+1]
            self.aResim.downloadedFrom(link: picture)
            self.aResim.contentMode = UIViewContentMode.scaleAspectFill
            self.aResim.layer.borderWidth = 1
            self.aResim.layer.borderColor = UIColor.black.cgColor
            self.aResim.layer.cornerRadius = 10
            self.aResim.layer.borderWidth = 1
           
            
        }
         
        
        
        
        
        
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
    

    
    
    override func viewDidLoad() {
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "backgroundm")
        self.view.insertSubview(backgroundImage, at: 0)
        
        self.updateLocation(locationText: "Anywhere, US",adr: "Anywhere, US",latitude: "0",longitude: "0")
        
        pscope.addPermission(CameraPermission(),
                             message: "We need your permission for video")
        pscope.addPermission(MicrophonePermission(),
                             message: "We need your permission for audio")
        pscope.addPermission(NotificationsPermission(notificationCategories: nil),
                             message: "We need your permission to send you video calls")
        // Show dialog with callbacks
        pscope.show({ finished, results in
            print("got results \(results)")
        }, cancelled: { (results) -> Void in
            print("thing was cancelled")
        })
        
        
     
        //self.pscope.addPermission(LocationWhileInUsePermission(),
         //                         message: "We need your permission to show users nearby")
        // Show dialog with callbacks
        //self.pscope.show({ finished, results in
        //    print("got results \(results)")
        //}, cancelled: { (results) -> Void in
       //     print("thing was cancelled")
        //})
        

        
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if ((UIDevice.current.systemVersion as NSString).floatValue >= 8)
            {
                locationManager.requestWhenInUseAuthorization()
            }
            
            durationTimerx = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
            
        }
        else
        {
            #if debug
                println("Location services are not enabled");
            #endif
        }

        
        
        
        
        
        tabBar.delegate = self
        getData()
        LoadData()

    }
    
       func runTimedCode() {
        if seconds > 30 {
        getData()
            seconds = 0
        }
        else
        {
            seconds = seconds + 1
        }
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

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        let center = NotificationCenter.default
        
        
        if(item.tag == 0) {
            center.post(Notification(name: Notification.Name(rawValue: MenuViewController.Notifications.RedSelected), object: self))
            
        }
        else if(item.tag == 1) {
            center.post(Notification(name: Notification.Name(rawValue: MenuViewController.Notifications.GreenSelected), object: self))
            
        }
        else if(item.tag == 2) {
            center.post(Notification(name: Notification.Name(rawValue: MenuViewController.Notifications.MainSelected), object: self))
            
        }
        else if(item.tag == 3) {
          
             center.post(Notification(name: Notification.Name(rawValue: MenuViewController.Notifications.SearchSelected), object: self))
            
        }
        }

    func getData()
    {
       
        
        locationManager.requestLocation()
        settings.getjustcredit()
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        settings.saveDefaults(deger: "0", isim: "gorundu")
        goofline()
    }
    
    
    
    func LoadData()
    {
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        
        
        
        
        fruits.removeAll()
        fruits1.removeAll()
        pictures.removeAll()
        id.removeAll()
        fbid.removeAll()
        rating.removeAll()
        uzaklik.removeAll()
        nfruits.removeAll()
        nfruits1.removeAll()
        npictures.removeAll()
        nid.removeAll()
        nfbid.removeAll()
        nrating.removeAll()
        nuzaklik.removeAll()
        getcalls.removeAll()
        ngetcalls.removeAll()
        
        
        let localProfile = settings.getDefaults(isim: "facebookID")
        var makeURL = ""
   var gl = settings.getDefaults(isim: "lookingfor")
        
        if gl == "" {
            gl = "1"
        }
        
        if (gl=="2")
        {
            makeURL = settings.serverip + "/_table/member?limit=100&related=block_by_blockeduserid,block_by_userid&filter=(getcalls=1) and (online=1) and (status=1) and (fbid <> " +  localProfile   + ")&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
            

        }
        else
        {
            makeURL = settings.serverip + "/_table/member?limit=100&related=block_by_blockeduserid,block_by_userid&filter=(sex=\(gl)) and (getcalls=1) and (online=1) and (status=1) and (fbid <> " +  localProfile   + ")&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
            

        }
        
        print(makeURL)
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
                    if let json = try? JSON(data: data) {
                    print(json)
                    for item in json["resource"].arrayValue {
                        var atla = 0
                        
                        let y = item["block_by_blockeduserid"]
                        for itemx in y.arrayValue {
                            
                            print(itemx)
                            if itemx["userid"].string == self.settings.getDefaults(isim: "facebookID")
                            {
                                atla = 1
                            }
                            
                            if itemx["blockeduserid"].string == self.settings.getDefaults(isim: "facebookID")
                            {
                                atla = 1
                            }
                        }
                        
                        let z = item["block_by_userid"]
                        for itemv in z.arrayValue {
                            
                            print(itemv)
                            if itemv["userid"].string == self.settings.getDefaults(isim: "facebookID")
                            {
                                atla = 1
                            }
                            
                            if itemv["blockeduserid"].string == self.settings.getDefaults(isim: "facebookID")
                            {
                                atla = 1
                            }
                        }
                        
                        
                        if atla==0 {
                            
                            
                            
                            self.nfruits.append(item["name"].stringValue)
                            self.nfruits1.append(item["lastaddress"].stringValue)
                            self.npictures.append(item["picture"].stringValue)
                            self.nid.append(item["id"].stringValue)
                            self.nfbid.append(item["fbid"].stringValue)
                            self.nrating.append(item["rating"].stringValue)
                            self.ngetcalls.append(item["getcalls"].stringValue)
                            var userLocation:CLLocation
                            var priceLocation:CLLocation
                            
                            guard let userLocationx:CLLocation = CLLocation(latitude: Double(self.settings.getDefaults(isim: "latitude"))!, longitude: Double(self.settings.getDefaults(isim: "longitude"))!) else
                            {
                                return
                            }
                            userLocation = CLLocation(latitude: Double(self.settings.getDefaults(isim: "latitude"))!, longitude: Double(self.settings.getDefaults(isim: "longitude"))!)
                            
                            
                            guard let priceLocationx:CLLocation = CLLocation(latitude: Double(item["latitude"].stringValue)!, longitude: Double(item["longitude"].stringValue)!)
                                else
                            {
                                return
                            }
                            priceLocation = CLLocation(latitude: Double(item["latitude"].stringValue)!, longitude: Double(item["longitude"].stringValue)!)
                            
                            
                            self.nuzaklik.append(userLocation.distance(from: priceLocation)/1000)
                        }
                        
                    }
                    let sorted = self.nuzaklik.enumerated().sorted(by: {$0.element < $1.element})
                    let justIndices = sorted.map{$0.offset}
                    print(justIndices)
                    
                    
                    for i in 0 ..< justIndices.count  {
                        
                        self.fruits.append(self.nfruits[justIndices[i]])
                        self.fruits1.append(self.nfruits1[justIndices[i]])
                        self.pictures.append(self.npictures[justIndices[i]])
                        self.id.append(self.nid[justIndices[i]])
                        self.fbid.append(self.nfbid[justIndices[i]])
                        self.rating.append(self.nrating[justIndices[i]])
                        self.uzaklik.append(self.nuzaklik[justIndices[i]])
                        self.getcalls.append(self.ngetcalls[justIndices[i]])
                        
                        
                        
                    }
                    LoadingOverlay.shared.hideOverlayView()
                    if self.fruits.count == 0 {
                        self.gKutu.removeFromSuperview()
                        self.aKutu.removeFromSuperview()

                        return
                    
                    }
                    
                    self.gAd.text = self.fruits[self.pozisyon]
                    self.gLocation.text = self.fruits1[self.pozisyon]
                    let picture = self.pictures[self.pozisyon]
                    self.gRating.text =  self.rating[self.pozisyon]
                    let km = self.uzaklik[self.pozisyon]
                    
                    
                    
                    
                    self.gResim.image = nil
                    DispatchQueue.main.async {
                        
                            
                            self.gResim.downloadedFrom(link: picture)
                            self.gResim.contentMode = UIViewContentMode.scaleAspectFill
                            self.gResim.layer.borderWidth = 1
                            self.gResim.layer.borderColor = UIColor.black.cgColor
                        self.gResim.layer.cornerRadius = 10
                        self.gResim.layer.borderWidth = 1
                        
                    }
                    if  self.fruits.count > 1 {
                        let picture = self.pictures[self.pozisyon+1]
                        
                        self.aResim.downloadedFrom(link: picture)
                        self.aResim.contentMode = UIViewContentMode.scaleAspectFill
                        self.aResim.layer.borderWidth = 1
                        self.aResim.layer.borderColor = UIColor.black.cgColor
                        self.aResim.layer.cornerRadius = 10
                        self.aResim.layer.borderWidth = 1

                    }

                    self.gKutu.isHidden = false
                    self.aKutu.isHidden = false
                    
                    print("tablo guncellendi")
                }
                
                }
                
            }
        }
        task.resume()
        
    }

    
    @IBAction func gAra(_ sender: Any) {
        
        
        if pozisyon != nil {
            
            xlocation = fruits1[pozisyon]
            xpicture = pictures[pozisyon]
            xid = id[pozisyon]
            xfbid = fbid[pozisyon]
            xrating = rating[pozisyon]
            
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! CallDetailViewController
            
            self.present(vc, animated: true, completion: nil)
            vc.nereden = 0
            vc.passedvalue = fruits[pozisyon]
            vc.location = xlocation
            vc.id = xid
            vc.fbid = xfbid
            vc.picture = xpicture
            vc.rating = xrating
            vc.tableviewdengeldi()
            
            
        }

        
    }
    
       

    
}


