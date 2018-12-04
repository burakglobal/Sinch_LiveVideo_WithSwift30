
import UIKit
import SwiftyJSON

class activityCell: UITableViewCell {
    
    
    @IBOutlet weak var lab: UILabel!
    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var callinfo: UILabel!
    
}

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var myTableView: UITableView!
    
     var settings = GlobalViewController()
    var fruits  =  [String]()
    var fruits1  =  [String]()
    
    var fromname  =  [String]()
    var toname  =  [String]()
    
    
    var newFruits  =  [String]()
    var newFruits1  =  [String]()
     var rating  =  [String]()
    var pictures  =  [String]()
    var fbid  =  [String]()
    var id  =  [String]()
    
    
    var xid:String = ""
    var xfbid:String = ""
    var xpicture:String = ""
    var xlocation:String = ""
    var xrating:String = ""
    var xvalueToPass:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        LoadData("")
        
        
        
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
    
    func LoadData(_ filter:String)
    {
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        
        
        
        
        fruits.removeAll()
        fruits1.removeAll()
        let localProfile = settings.getDefaults(isim: "facebookID")
        var makeURL = ""
             makeURL = settings.serverip + "/_table/activity?related=member_by_fromuserid,member_by_userid&filter=((userid=" +  localProfile   + ") or (fromuserid=" + localProfile + "))&order=date desc&fields=*&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
            
       
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
                    for item in json["resource"].arrayValue  {
                        print(item)
                        self.fruits.append(item["desc"].string!)
                        self.fruits1.append(item["date"].string!)
                        
                        
                        let x = item["member_by_fromuserid"]
                        let y = item["member_by_userid"]
                        
                       if y["name"].stringValue == self.settings.getDefaults(isim: "facebookName")
                       {
                        self.fruits1.append(item["date"].string!)
                        
                        
                        self.toname.append("You")
                        self.fromname.append(x["name"].stringValue)
                      
                        
                        
                        self.newFruits.append(x["name"].stringValue)
                        self.newFruits1.append(x["lastaddress"].stringValue)
                        self.rating.append(x["rating"].stringValue)
                        self.pictures.append(x["picture"].stringValue)
                        self.fbid.append(x["fbid"].stringValue)
                        self.id.append(x["id"].stringValue)
                        
                        

                        }
                       else{
                        self.newFruits.append(y["name"].stringValue)
                        self.newFruits1.append(y["lastaddress"].stringValue)
                        self.rating.append(y["rating"].stringValue)
                        self.pictures.append(y["picture"].stringValue)
                        self.fbid.append(y["fbid"].stringValue)
                        self.id.append(y["id"].stringValue)
                        
                        self.toname.append(y["name"].stringValue)
                        self.fromname.append("You")
                        
                        }
                        
                            
                        
                        
                        
                        print(self.toname)
                    }
                    
                    }
                    
                    self.myTableView.reloadData()
                    LoadingOverlay.shared.hideOverlayView()

                    print("tablo guncellendi")
                }
                
                
                
            }
        }
        task.resume()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        returnValue = fruits.count
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "td", for: indexPath) as! activityCell
        
        
        
        
        let from = fromname[indexPath.row]
        let to = toname[indexPath.row]
        let fruitName = fruits[indexPath.row]
        
        cell.lab?.text =  fruitName
        cell.callinfo?.text = "From:\(from) - To:\(to)"
        
        let fruitName1 = fruits1[indexPath.row]
        cell.lab2?.text = fruitName1 as? String
        
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        if self.myTableView.indexPathForSelectedRow != nil {
            
            xvalueToPass = newFruits[indexPath.row]
            xlocation = newFruits1[indexPath.row]
            xpicture = pictures[indexPath.row]
            xid = id[indexPath.row]
            xfbid = fbid[indexPath.row]
            xrating = rating[indexPath.row]
            
            print(xvalueToPass)
            print(xpicture)
            if xvalueToPass != "" {
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

        
        
        
     
    }

    
    
}
