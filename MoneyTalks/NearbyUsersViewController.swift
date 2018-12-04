

import UIKit
import SwiftyJSON
import CoreLocation

class NearByUsersTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lab: UILabel!
    @IBOutlet weak var ima: UIImageView!
    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var phoneaktif: UIImageView!
    
        
    
}


class NearbyUsersViewController: UITableViewController {
    
   
    @IBOutlet var myTableView: UITableView!
    var xvalueToPass:String = ""
    var settings = GlobalViewController()
    
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
    
      @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBAction func menuGoster(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "backgroundm")
        self.tableView.backgroundView = backgroundImage
        
        NotificationCenter.default.addObserver(self, selector: #selector(kapatme), name: notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(aramayap), name: NSNotification.Name(rawValue: "aramayap"), object: nil)
        
        
      
         LoadData("online=1")
      
        
        
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
    
    
    @IBAction func aramab(_ sender: Any) {
      
        if popped==0 {
         self.myTableView.setContentOffset(CGPoint.zero, animated: true)
      
            
        let vc =  UIStoryboard(name:"Main",bundle:nil).instantiateViewController(withIdentifier: "AramaViewController") as! ProfileViewController
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        popped=1
        
        }
        
        
        
          }
 
 
    func aramayap(){
        LoadData("")
        
    }
    func kapatme(){
        dismiss(animated: false, completion: nil)
    }
    func LoadData(_ filter:String)
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
        var gl = settings.getDefaults(isim: "lookingfor")
        
        if gl == "" {
            gl = "1"
        }
        
        
        
         var makeURL = ""
        
        if popped==3 {
            var filt = ""
            if startage != 0 {
                filt = " and (age >=\(startage))"
            }
            if finishage != 0 {
                filt = filt + " and (age <=\(finishage))"
            }
            if slookingfor != 2 {
                filt = filt + " and (sex=\(slookingfor))"
            }
                makeURL = settings.serverip + "/_table/member?limit=100&related=block_by_blockeduserid,block_by_userid&filter=(status=1) and (fbid <> " +  localProfile   + ")" + filt + "&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        }
        else
        {
        if filter == "" {
            
            if (gl=="2")
            {
                
           makeURL = settings.serverip + "/_table/member?limit=100&related=block_by_blockeduserid,block_by_userid&filter=(status=1) and (fbid <> " +  localProfile   + ")&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
            }
            else
            {
                makeURL = settings.serverip + "/_table/member?limit=100&related=block_by_blockeduserid,block_by_userid&filter=(sex=\(gl)) and (status=1) and (fbid <> " +  localProfile   + ")&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"

            }
            
        }else{
            
            if (gl=="2")
            {
            
                
            makeURL = settings.serverip + "/_table/member?limit=100&related=block_by_blockeduserid,block_by_userid&filter=(status=1) and (" + filter + ") and (fbid <> " +  localProfile   + ")&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
                
            }
            else
            {
                
                makeURL = settings.serverip + "/_table/member?limit=100&related=block_by_blockeduserid,block_by_userid&filter=(sex=\(gl)) and (status=1) and (" + filter + ") and (fbid <> " +  localProfile   + ")&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"

            }
            
        }
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
                        print(Int(self.nuzaklik[justIndices[i]]))
                        
                        if Int(self.nuzaklik[justIndices[i]]) < mileage || mileage==100 {
                            
                        self.fruits.append(self.nfruits[justIndices[i]])
                        self.fruits1.append(self.nfruits1[justIndices[i]])
                        self.pictures.append(self.npictures[justIndices[i]])
                        self.id.append(self.nid[justIndices[i]])
                        self.fbid.append(self.nfbid[justIndices[i]])
                        self.rating.append(self.nrating[justIndices[i]])
                        self.uzaklik.append(self.nuzaklik[justIndices[i]])
                        self.getcalls.append(self.ngetcalls[justIndices[i]])
                        
                        }
                        }

                    }
                    
                    print(self.fruits)
                    print(self.fruits1)
                    print(self.fbid)
                    print(self.uzaklik)
                    
                self.tableView.reloadData()
                    LoadingOverlay.shared.hideOverlayView()

                print("tablo guncellendi")
                    popped=0
                }
                
                
                
            }
        }
        task.resume()
        
    }
    
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            var returnValue = 0
             returnValue = fruits.count
           return returnValue
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "td", for: indexPath) as! NearByUsersTableViewCell
            
            
            let isIndexValid = fruits.indices.contains(indexPath.row)
            
            
            if isIndexValid   {
                
                let fruitName = fruits[indexPath.row]
                cell.lab?.text = fruitName as? String
                
                let fruitName1 = fruits1[indexPath.row]
                cell.lab2?.text = fruitName1 as? String
                let picture = pictures[indexPath.row]
                let ratingdeger = rating[indexPath.row]
                let km = uzaklik[indexPath.row]
                let phoneaktifmi  = getcalls[indexPath.row]
            
                cell.rating?.text = ratingdeger //+ " Distance:" + String(Int(km))
            if (phoneaktifmi=="1")
            {
                cell.phoneaktif.isHidden = false
            }
            else
            {
                cell.phoneaktif.isHidden = true

            }
            
            
            
            
            cell.ima.image = nil
            DispatchQueue.main.async {
                
                let updateCell = tableView .cellForRow(at: indexPath)
                if updateCell != nil {

                    
                                cell.ima.downloadedFrom(link: picture)
                                cell.ima.layer.cornerRadius = 50
                                cell.ima.layer.borderWidth = 1
                                cell.ima.layer.borderColor = UIColor.gray.cgColor
                                cell.ima.contentMode = UIViewContentMode.scaleAspectFill
                                cell.ima.setRounded()
                    
                    
                    
                }
                    }
          
            
         
            
            
            }
            
            
            
                    return cell
        }
    
    
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("You selected cell #\(indexPath.row)!")
            if self.tableView.indexPathForSelectedRow != nil {
                
            xvalueToPass = fruits[indexPath.row]
            xlocation = fruits1[indexPath.row]
            xpicture = pictures[indexPath.row]
            xid = id[indexPath.row]
            xfbid = fbid[indexPath.row]
            xrating = rating[indexPath.row]
            
            print(xvalueToPass)
            print(xpicture)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! CallDetailViewController
            
            self.present(vc, animated: true, completion: nil)
            vc.nereden = 0
            vc.passedvalue = xvalueToPass
            vc.location = xlocation
            vc.id = xid
            vc.fbid = xfbid
            vc.picture = xpicture
            vc.rating = xrating
            vc.tableviewdengeldi()
                
                
            }
            
        }
    
  
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch(mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            
             LoadData("online=1")
             break
        case 1:
            
            LoadData("")
            
            break
        case 2:
            
            LoadData("rating > 4")
            
            
            break
            
            
        default:
            break
            
        }
       
    }
     
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

