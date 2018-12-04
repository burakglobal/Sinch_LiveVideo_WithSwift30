import UIKit
import SwiftyJSON
import Foundation
 

class GlobalViewController {
        let serverTokenIp: String = "http://132.148.90.100:81/api/v2/user/session"
        let serverip: String = "http://132.148.90.100:81/api/v2/mysql"
        let apiText: String  = "3bdb2a63e1d68a6183ff0cab3dc7245161207be381b38ad50183eba18478dbd5"
        let apiUserName: String = "xxxxxxxx"
        let apiPassword: String = "xxxxxxxx"
        let activityUrl:String = "http://132.148.90.100:81/api/v2/mysql/_table/activity"
        let fileserveripUrl:String = "http://132.148.90.100:81/api/v2/files?extract=false&clean=false&check_exist=false"
        let pictureURL:String = "http://132.148.90.100/content/moneytalks/"
        let pictureUploadURL:String =  "http://132.148.90.100/uploadz.php"
        //var sessionToken:String = ""
        //var facebookID:String = ""
        //var facebookName:String = ""
        //var facebookEMail:String = ""
      
    // Defining our own custom error type.
    enum MyError: Error {
        case itDidNotWork(String)
        case networkIssue(String)
        case badData(String)
    }
    
    func saveDefaults(deger:String, isim:String)
    {
        //To save the string
        let userDefaults = UserDefaults.standard
        userDefaults.set( deger, forKey: isim)
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
   
    
    func getDefaults(isim: String) -> String
    {
        let userDefaults = UserDefaults.standard
        
        var str:String? = userDefaults.string(forKey: isim)
        if str == nil {
            str = ""
        }
        return str!
    }
    
    
    func methodThatThrows() throws {
        print("After this line, we will throw an error")
        throw MyError.itDidNotWork("Genel")
    }
    
        
    func convertBase64ToImage(base64String: String) -> UIImage {
        
        let decodedData = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0) )
        
        var decodedimage = try! UIImage(data: decodedData! as Data)
        
        return decodedimage!
        
    }// end convertBase64ToImage
    
    
    func updateswitch(status:String)
    {
        let makeURL = serverip + "/_table/member?filter=fbid=" + getDefaults(isim: "facebookID") + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        
        let json = "{\"resource\":[{\"getcalls\":\"" + status + "\"}]}"
        
        
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = json.data(using: .utf8)
        print(json)
        
        
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

    
    
    
    func loginToServer()
    {
        
        var request = URLRequest(url: URL(string: serverTokenIp)!)
        request.httpMethod = "POST"
        let json: [String: Any] = ["email":apiUserName,"password":apiPassword,"duration":3600]
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
                    
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            
            if let dataFromString = dataString?.data(using: .utf8, allowLossyConversion: false) {
                
                if let json = try? JSON(data: data) {

                let sess = json["session_token"].stringValue
                
                
                if sess != "" {
                    self.saveDefaults(deger: sess,isim: "sessionToken")
                    
                }
                    }
                    }
                }
            }
        }
        task.resume()
    }
    
    
    func blockthisprofile(userid:String)
    {
        
        let makeURL = serverip + "/_table/block?api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "POST"
        
        
        let json = [
            "resource": [
                "userid": getDefaults(isim: "facebookID"),
                "blockeduserid": userid
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

    
    
    
    
    func addactivity(fromuserid:String, userid:String, desc:String)
    {
        
        let makeURL = serverip + "/_table/activity?api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "POST"
        
        
        let json = [
            "resource": [
                "fromuserid": fromuserid,
                "userid": userid,
                "desc": desc
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

    
    
    func getUserDetails(_ fbid: String) -> String
    {
        var fbiddd = ""
        let makeURL = serverip + "/_table/member?fields=*&filter=fbid=" + fbid + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        print("find account get user details :\(makeURL)")
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
                  fbiddd = getDict[0]["name"].string!
             
                
                self.saveDefaults(deger: fbiddd, isim: "callerid")
                self.saveDefaults(deger: getDict[0]["picture"].string!, isim: "callerpicture") 
                    
                    
                }
                }
            }
        }
        task.resume()
        
        return (fbiddd)
    }

    func getMyUserDetails(_ fbid: String) -> String
    {
        var fbiddd = ""
        let makeURL = serverip + "/_table/member?fields=*&filter=fbid=" + fbid + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        print("find account get my user details :\(makeURL)")
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
                 
                    fbiddd = getDict[0]["name"].string!
                    let email = getDict[0]["name"].string!
                    let picture = getDict[0]["picture"].string!
                    
                    
                    self.saveDefaults(deger: picture, isim: "picture")
                    self.saveDefaults(deger: fbiddd, isim: "facebookName")
                    self.saveDefaults(deger: email, isim: "facebookEMail")
                    
                    fbiddd = "tamam"
                }
                }
            }
        }
        task.resume()
    
        return (fbiddd)
    }

    
    func updateonline(status:String)
    {
        let makeURL = serverip + "/_table/member?filter=fbid=" + getDefaults(isim: "facebookID") + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        
        let json = "{\"resource\":[{\"online\":\"" + status + "\"}]}"
        
        
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = json.data(using: .utf8)
        print(json)
        
        
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
    
    func updategetcalls(status:String)
    {
        let makeURL = serverip + "/_table/member?filter=fbid=" + getDefaults(isim: "facebookID") + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        
        let json = "{\"resource\":[{\"getcalls\":\"" + status + "\"}]}"
        
        
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = json.data(using: .utf8)
        print(json)
        
        
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

    
    
    func updatecredit(status:Double, kac:String)
    {
     
        getcredit(status: status, kac:kac)
        
        
    }
    func finalizeupdate(status:Double,kac:String)
        {
        let makeURL = serverip + "/_table/member?filter=fbid=" + getDefaults(isim: "facebookID") + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        let x = getDefaults(isim: "credit")
        let z = Double(x)
        var y = 0.0
            
            if kac=="1" {
               y = z!+status
            }
            else if kac=="2" {
                y = 0.0
            }
            else{
                y = z!-status
            }
            
        let json = "{\"resource\":[{\"credit\":\"" + String(y) + "\"}]}"
        
        
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = json.data(using: .utf8)
        print(json)
        
        
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
                        
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "credit"), object: nil)
                        
                        
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
                
            }
        }
        task.resume()
    }

    
    
    func findAccountstatus(_ fbid: String)
    {
        
        let makeURL = serverip + "/_table/member?fields=*&filter=fbid=" + fbid + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        print("find account account status :\(makeURL)")
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
                                
                            }
                        }
                        }
                        
                        }
                        
                    }
                    
                }
                
                
            }
        task.resume()
    }
    
    
    
      
    func getcredit(status:Double, kac:String)
    {
        
        let makeURL = serverip + "/_table/member?fields=*&filter=fbid=" + getDefaults(isim: "facebookID") + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
        print("find account getcredit :\(makeURL)")
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
                        
                            
                            if let getcx = getDict[0]["credit"].string {
                                self.saveDefaults(deger: getcx, isim: "credit")
                                self.finalizeupdate(status: status, kac: kac)
                               
                            
                        }
                        
                        }
                        }
                        
                    }
                    
                }
                
            }
        task.resume()
    }
    

    func getjustcredit()
    {
        
        let makeURL = serverip + "/_table/member?fields=*&filter=fbid=" + getDefaults(isim: "facebookID") + "&api_key="  + apiText + "&`session_id=\(getDefaults(isim: "sessionToken"))&session_token=\(getDefaults(isim: "sessionToken"))"
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
                    
                    if let json = try? JSON(data: data) {
                    let getDict = json["resource"]
                    let fbidd = getDict[0]["fbid"]
                    
                    
                    if fbidd != JSON.null {
                        
                        
                        if let getcx = getDict[0]["credit"].string {
                            self.saveDefaults(deger: getcx, isim: "credit")
                           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "credit"), object: nil)
                            
                            
                        }
                        }
                        }
                        
                    }
                    
                }
                
            }
        task.resume()
    }
    

    
    

    
}
 extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
 }
 extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
 }
 
 
 extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
 }
 public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView) {
        
        overlayView.frame = CGRect(x:0, y:0, width:80, height:80)
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor.red  //UIColor(white: 0x444444, alpha: 0.7)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
       
        let imageName = "animate"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.addSubview(imageView)
        
        
        activityIndicator.frame = CGRect(x:0, y:0, width:40, height:40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(activityIndicator)
        
        
        view.addSubview(overlayView)
        activityIndicator.startAnimating()
        
        
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
    
    
    
    
 }
 
 extension UISegmentedControl {
    
    func setFontSize(fontSize: CGFloat) {
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName as NSObject: UIColor.black,
            NSFontAttributeName as NSObject: UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightRegular)
        ]
        
        let boldTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName as NSObject : UIColor.white,
            NSFontAttributeName as NSObject : UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium),
            ]
        
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
        self.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(boldTextAttributes, for: .selected)
    }
 }

 
 
 extension UIViewController {
    
    func addLeftImage(imageName: String, textField: UITextField) {
        
        textField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: imageName)
        imageView.image = image
        textField.leftView = imageView }
    
 }
 
 
 
 @IBDesignable
 class ImageTextField: UITextField {
    
    var textFieldBorderStyle: UITextBorderStyle = .roundedRect
    
    // Provides left padding for image
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += padding
        return textRect
    }
    
    // Provides right padding for image
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= padding
        return textRect
    }
    
    @IBInspectable var fieldImage: UIImage? = nil {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var padding: CGFloat = 0
    @IBInspectable var color: UIColor = UIColor.gray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = UIColor.clear {
        didSet {
            if bottomColor == UIColor.clear {
                self.borderStyle = .roundedRect
            } else {
                self.borderStyle = .bezel
            }
            self.setNeedsDisplay()
        }
    }
    
    func updateView() {
        
        if let image = fieldImage {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSForegroundColorAttributeName: color])
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.origin.x , y: self.bounds.height
            - 0.5))
        path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.height
            - 0.5))
        path.lineWidth = 0.5
        self.bottomColor.setStroke()
        path.stroke()
    }
    
    
 }
 
