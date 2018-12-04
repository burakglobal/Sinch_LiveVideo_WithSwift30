

import UIKit

import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import SwiftyJSON


class LoginViewController: UIViewController,FBSDKLoginButtonDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var eulabutton: UIButton!
    @IBOutlet weak var girisButton: UIButton!
    var girStatus = 0
    let settings = GlobalViewController()
    
    @IBOutlet weak var EmailTextBoxt: UITextField!
    @IBOutlet weak var PasswordTextBoxt: UITextField!
 
    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var SignupButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bg")
        self.view.insertSubview(backgroundImage, at: 0)
        
        settings.loginToServer()
        EmailTextBoxt.delegate = self
        PasswordTextBoxt.delegate = self
        PasswordTextBoxt.isSecureTextEntry = true
        SignupButton.setImage(UIImage(named:"profile"), for: UIControlState.normal)
        
        SignupButton.layer.cornerRadius = 10
        SignupButton.layer.borderWidth = 1
        SignupButton.layer.borderColor = UIColor.black.cgColor

        
        tutorialButton.layer.cornerRadius = 10
        tutorialButton.layer.borderWidth = 1
        
        eulabutton.layer.cornerRadius = 10
        eulabutton.layer.borderWidth = 1
        
        
        self.addLeftImage(imageName: "placeholder-1", textField: EmailTextBoxt)
        
        self.addLeftImage(imageName: "key-2", textField: PasswordTextBoxt)
        girisButton.setImage(UIImage(named:"facebook"), for: UIControlState.normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let loginButton = FBSDKLoginButton()
        
        loginButton.readPermissions = ["public_profile", "email"]
        
        loginButton.backgroundColor = .blue
        loginButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        loginButton.setTitle("Signup with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont(name: "Gill Sans", size: 15)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setImage(UIImage(named:"facebook"), for: UIControlState.normal)
        
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
      
        loginButton.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -80).isActive = true
        
        
        loginButton.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: 20).isActive = true
        
        loginButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: -20).isActive = true
        
        if(FBSDKAccessToken.current() == nil){
            print("Is not logged in")
            girisButton.isHidden = true
            
        }else{
            girStatus = 1
            loginButton.isHidden = true
            
        }
        
        let f = settings.getDefaults(isim: "facebookEMail")
        
        if f != "" {
            EmailTextBoxt.text = f
            
        }
        settings.saveDefaults(deger: "0", isim: "kapat")
        
        let g = settings.getDefaults(isim: "facebookID")
        if g != "" {
            findAccount(g)
        }
        
        
        
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        EmailTextBoxt.resignFirstResponder()
        PasswordTextBoxt.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
 
    @IBAction func eulagor(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.moneytalks.io/eula-agreement")!)

    }
    @IBAction func tutorialButtonClick(_ sender: Any) {
        tutorial()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        girisButton.isHidden = true

        print("Logged out")
    }
    @IBAction func girButtonTouch(_ sender: Any) {
        if girStatus==1{
            LoadingOverlay.shared.showOverlay(view: self.view)

            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, email, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                   
                    
                        let data:[String:AnyObject] = result as! [String : AnyObject]
                        let json = JSON(data)
                        let picture = "http://i.imgur.com/fYVSRWr.png"
                        //let picture = pictureArray["data"]["url"].string
                        self.settings.saveDefaults(deger: picture ,isim: "picture")
              
                        self.settings.saveDefaults(deger: json["id"].stringValue,isim: "facebookID")
                        self.settings.saveDefaults(deger: json["first_name"].stringValue ,isim: "facebookName")
                        self.settings.saveDefaults(deger: json["email"].stringValue,isim: "facebookEMail")
                    self.settings.saveDefaults(deger: "0",isim: "iam")
                    self.settings.saveDefaults(deger: "2",isim: "lookingfor")
                    self.settings.saveDefaults(deger: "0", isim: "getcalls")
                    self.settings.saveDefaults(deger: "0", isim: "credit")
                    
                    
                    print(self.settings.getDefaults(isim: "facebookID"))
                    
                    self.findAccount(self.settings.getDefaults(isim: "facebookID"))
                    
                   
                }
            })
        }

    }
    override func viewDidAppear(_ animated: Bool) {
       
    }
   
    func logout()
    {
        //self.view.toBottomAnimation()
        settings.saveDefaults(deger: "", isim: "facebookEMail")
        settings.saveDefaults(deger: "", isim: "facebookID")
        settings.saveDefaults(deger: "", isim: "facebookName")
        settings.saveDefaults(deger: "", isim: "id")
        settings.saveDefaults(deger: "", isim: "picture")
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "facebookEMail")
        defaults.removeObject(forKey: "facebookID")
        defaults.removeObject(forKey: "facebookName")
        defaults.removeObject(forKey: "id")
        defaults.removeObject(forKey: "picture")
        
        let loginView : FBSDKLoginManager = FBSDKLoginManager()
        loginView.loginBehavior = FBSDKLoginBehavior.web
        let manager = FBSDKLoginManager()
        manager.logOut()
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        cikisyap()
        
        
    }
    
    func cikisyap()
    {
        exit(0)
    }
    
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(error == nil){
            
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, first_name,email, picture.type(large)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(String(describing: error))")
                }
                else
                {
                    
                    LoadingOverlay.shared.showOverlay(view: self.view)
                    
                    
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    let json = JSON(data)
                    //let pictureArray = json["picture"]
                    //let picture = pictureArray["data"]["url"].string
                    let picture = "http://i.imgur.com/fYVSRWr.png"
                    self.settings.saveDefaults(deger: picture ,isim: "picture")
                    
                    self.settings.saveDefaults(deger: json["id"].stringValue,isim: "facebookID")
                    self.settings.saveDefaults(deger: json["first_name"].stringValue ,isim: "facebookName")
                    self.settings.saveDefaults(deger: json["email"].stringValue,isim: "facebookEMail")
                    self.settings.saveDefaults(deger: "0", isim: "getcalls")
                    self.settings.saveDefaults(deger: "1", isim: "credit")
                    
                    self.settings.saveDefaults(deger: "0",isim: "iam")
                    self.settings.saveDefaults(deger: "2",isim: "lookingfor")
                   
                    
                    print(self.settings.getDefaults(isim: "facebookID"))
                    
                    
                        self.UpdateOrSaveAccount (json["email"].stringValue, json["id"].stringValue, json["first_name"].stringValue, picture)
                        
                    
                }
            })
            
            
            print("Successfully logged")
        }else{
            print(error.localizedDescription)
        }
    }
 
    @IBAction func standartLogin(_ sender: Any) {
                 if EmailTextBoxt.text == "" {
            
            let uiAlert = UIAlertController(title: "Login", message: "Please Enter Your E-Mail", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))

            return
        }
        if PasswordTextBoxt.text == "" {
            
            let uiAlert = UIAlertController(title: "Login", message: "Please Enter Your Password", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            return
        }
        
        
        if !(EmailTextBoxt.text?.isValidEmail())! {
            
            let uiAlert = UIAlertController(title: "Login", message: "Please Enter Correct E-Mail Address", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            return
        }
        
        
        
         goLoginStandart()
        
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
                DispatchQueue.main.async {
                    
                    if let json = try? JSON(data: data) {
                let getDict = json["resource"]
                let fbidd = getDict[0]["fbid"]
            
                    
                if fbidd != JSON.null {
                    if getDict[0]["status"]==0 {
                        
                        let uiAlert = UIAlertController(title: "Login", message: "This Account was cancelled, Please send e-mail to support@moneytalks.io!", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(uiAlert, animated: true, completion: nil)
                        uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                            print("Click of cancel button")
                        }))
                        
                        LoadingOverlay.shared.hideOverlayView()
                        
                        return
                    }
                    
            
                    if let name = getDict[0]["name"].string {
                        
                        self.settings.saveDefaults(deger: name, isim: "facebookName")
                    }
                    
                    if  let email = getDict[0]["email"].string {
                        self.settings.saveDefaults(deger: email, isim: "facebookEMail")
                    }
                    
                    if let picture = getDict[0]["picture"].string {
                        self.settings.saveDefaults(deger: picture, isim: "picture")
                        
                    }
                    if let getc = getDict[0]["getcalls"].string {
                        self.settings.saveDefaults(deger: getc, isim: "getcalls")
                        
                    }
              
                    if let sex = getDict[0]["sex"].string {
                        self.settings.saveDefaults(deger: sex,isim: "iam")
                    }
                    
                    if let lookingfor = getDict[0]["lookingfor"].string {
                        self.settings.saveDefaults(deger: lookingfor,isim: "lookingfor")
                        
                    }
                    
                    if let selfx = getDict[0]["summary"].string {
                        self.settings.saveDefaults(deger: selfx,isim: "summary")
                        
                    }
                    
                        self.settings.saveDefaults(deger: getDict[0]["age"].stringValue,isim: "age")
                   
                    
                    
                    
                    if let credit = getDict[0]["credit"].string  {
                        self.settings.saveDefaults(deger: credit, isim: "credit")
                        
                    }
                    
                    
                        self.girIceri()
                    
                   
                  }
                            else{
               
                      self.createAccount(self.settings.getDefaults(isim: "facebookEMail"), self.settings.getDefaults(isim: "facebookID"), self.settings.getDefaults(isim: "facebookName"),self.settings.getDefaults(isim: "picture"))
                    
               }
               
                }
                }
               
            }
        }
        task.resume()
        
    }

    
    func goLoginStandart()
    {
        let makeURL = settings.serverip + "/_table/member?fields=*&filter=(email=\(EmailTextBoxt.text!)) and (password=\(PasswordTextBoxt.text!))&api_key=\(settings.apiText)&session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
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
                    
                    print(json)
                    
                    if fbidd != JSON.null {
                        
                        
                        if getDict[0]["status"]==0 {
                            
                            let uiAlert = UIAlertController(title: "Login", message: "This Account was cancelled, Please send e-mail to support@moneytalks.io!", preferredStyle: UIAlertControllerStyle.alert)
                            self.present(uiAlert, animated: true, completion: nil)
                            uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                                print("Click of cancel button")
                            }))
                            LoadingOverlay.shared.hideOverlayView()
                            
                            return
                        }

                        
                        
                        
                        
                        if let facebookID = getDict[0]["fbid"].string {
                            
                            self.settings.saveDefaults(deger: facebookID, isim: "facebookID")
                        }
                        if let id = getDict[0]["id"].string {
                            
                            self.settings.saveDefaults(deger: id, isim: "id")
                        }
                        
                        if let name = getDict[0]["name"].string {
                            
                            self.settings.saveDefaults(deger: name, isim: "facebookName")
                        }
                        
                        if  let email = getDict[0]["email"].string {
                            self.settings.saveDefaults(deger: email, isim: "facebookEMail")
                        }
                        
                        if let picture = getDict[0]["picture"].string {
                            self.settings.saveDefaults(deger: picture, isim: "picture")
                            
                        }
                        if let getc = getDict[0]["getcalls"].string {
                            self.settings.saveDefaults(deger: getc, isim: "getcalls")
                            
                        }
                        if let credit = getDict[0]["credit"].string {
                            self.settings.saveDefaults(deger: credit, isim: "credit")
                            
                        }
                        if let sex = getDict[0]["sex"].string {
                            self.settings.saveDefaults(deger: sex,isim: "iam")
                        }
                        
                        if let lookingfor = getDict[0]["lookingfor"].string {
                            self.settings.saveDefaults(deger: lookingfor,isim: "lookingfor")
                            
                        }
                        if let selfx = getDict[0]["summary"].string {
                            self.settings.saveDefaults(deger: selfx,isim: "summary")
                            
                        }
                        
                             self.settings.saveDefaults(deger: getDict[0]["age"].stringValue,isim: "age")
                        
                        self.girIceri()
                        
                        }
                    }
                    else{
                        
                        
                        let alert = UIAlertController(title: "Login", message: "Wrong E-Mail Or Password", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { action in
                            // perhaps use action.title here
                        })
                        alert.addAction(UIAlertAction(title: "Reset Password", style: .default) { action in
                            self.resetpasswordprepare()
                        })
                        self.present(alert, animated: true)
                    }
                    
                }
                
            }
        }
        task.resume()
        
    }

    func tutorial(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowViewController") as! TutorialViewController
        self.present(vc, animated: true, completion: nil)
        vc.close.isHidden = false
    }
    
    func UpdateOrSaveAccount(_ email: String, _ fbid: String, _ name:String, _ picture:String)
    {
        let makeURL = settings.serverip + "/_table/member?fields=*&filter=fbid=" + fbid + "&api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "GET"
        
            
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
                    
                    if getDict[0]["status"]==0 {
                        
                        let uiAlert = UIAlertController(title: "Login", message: "This Account was cancelled, Please send e-mail to support@moneytalks.io!", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(uiAlert, animated: true, completion: nil)
                        uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                            print("Click of cancel button")
                        }))
                        LoadingOverlay.shared.hideOverlayView()
                        
                        return
                    }
                    

                    
                    
                    let name = getDict[0]["name"].string!
                    let email = getDict[0]["email"].string!
                    let picture = getDict[0]["picture"].string!
                    let getc = getDict[0]["getcalls"].string!
                    let credit = getDict[0]["credit"].string!
                    
                    self.settings.saveDefaults(deger: picture, isim: "picture")
                    self.settings.saveDefaults(deger: name, isim: "facebookName")
                    self.settings.saveDefaults(deger: email, isim: "facebookEMail")
                    self.settings.saveDefaults(deger: getc, isim: "getcalls")
                    self.settings.saveDefaults(deger: credit, isim: "credit")
                    
                    if let sex = getDict[0]["sex"].string {
                        self.settings.saveDefaults(deger: sex,isim: "iam")
                    }
                    
                    if let lookingfor = getDict[0]["lookingfor"].string {
                        self.settings.saveDefaults(deger: lookingfor,isim: "lookingfor")
                        
                    }
                    
                    if let selfx = getDict[0]["summary"].string {
                        self.settings.saveDefaults(deger: selfx,isim: "summary")
                        
                    }
                    
                      self.settings.saveDefaults(deger: getDict[0]["age"].stringValue,isim: "age")
                    

                    
                    self.girIceri()
                }
                    }
                        
                else{
                    
                    self.createAccount(email, fbid, name, picture)
                    
                }
                }
                
                
            }

            
        
        
        
        
        
        
        
        
        
        
        
        }
        task.resume()
        
    }
     
  
    
    func createAccount(_ email: String, _ fbid: String, _ name:String, _ picture:String)
    {
         let makeURL = settings.serverip + "/_table/member?a=1&" + "api_key="  + settings.apiText + "&`session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "POST"
        
        
        let json = [
            "resource": [
                "fbid": fbid,
                "name": name,
                "email": email,
                "picture": picture
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
                    
            _ = String(data: data, encoding: .utf8)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                
                let lazyMapCollection = json.values
                let lazyMapCollection1 = json.keys
                
                let stringArray = Array(lazyMapCollection.map { String(describing: $0) })
                let stringArray1 = Array(lazyMapCollection1.map { String(describing: $0) })
                
                
                print(stringArray1)
                
                print(stringArray)
                
                if !stringArray.contains("error") {
                    self.girIceri()
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
                }
            }
            
        }
        task.resume()
    }

    
    
    func resetpasswordprepare() {
        
        let makeURL = self.settings.serverip + "/_table/member?filter=(email=" + EmailTextBoxt.text! + ")&api_key="  + self.settings.apiText + "&`session_id=\(self.settings.getDefaults(isim: "sessionToken"))&session_token=\(self.settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        print(makeURL)
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        let randomcode1: Int = Int(arc4random_uniform(6)+1)
        let randomcode2: Int = Int(arc4random_uniform(6)+1)
        let randomcode3: Int = Int(arc4random_uniform(6)+1)
        let randomcode4: Int = Int(arc4random_uniform(6)+1)
        let randomcode5: Int = Int(arc4random_uniform(6)+1)
        
        let randomcode:String = String(randomcode1) +  String(randomcode2) +  String(randomcode3) +  String(randomcode4) +  String(randomcode5)
        
        
        var json = [:] as [String: Any]
        
        json = [
            "resource": [
                "password": randomcode
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
                    
                    if let json = try? JSON(data: data) {
                    let getDict = json["resource"]
                    let fbidd = getDict[0]["id"]
                    
                    print(json)
                    
                    if fbidd != JSON.null {
                        
                 
                    let x:String = String(randomcode)
                    self.resetpassword(randomcode: x)
                    
                    
                    }
                    }
                    
                }
            
                
                
            }
            
        }
        task.resume()

        
        
    }
    func resetpassword(randomcode:String)
    {
        
        
        let makeURL = "http://132.148.90.100:81/api/v2/email?api_key="  + settings.apiText + "&session_id=" + settings.getDefaults(isim: "sessionToken") + "&session_token=" + settings.getDefaults(isim: "sessionToken")
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "POST"
        
        
       
        let json = [
            "template": "Password Reset Default MoneyTalks",
            "template_id": 0,
            "first_name": EmailTextBoxt.text!,
            "confirm_code": randomcode,
            "to": [
                    "name": EmailTextBoxt.text!,
                    "email": EmailTextBoxt.text!
                 ]
            ] as [String : Any]
        
        
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
                    
                    
                    
                            let uiAlert = UIAlertController(title: "Login", message: "We sent you a new password, Please check you e-mail", preferredStyle: UIAlertControllerStyle.alert)
                            self.present(uiAlert, animated: true, completion: nil)
                            uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                               
                            }))
                            
                }
            }
        }
    
        task.resume()
    }
    

    
    
    
    
    func girIceri()
    {
        print(settings.getDefaults(isim: "facebookID"))
            LoadingOverlay.shared.showOverlay(view: self.view)
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ContainerViewController")
            self.present(vc, animated: false, completion: nil)
            
            
            LoadingOverlay.shared.hideOverlayView()
            
       

    }
    }
    extension String {
        func isValidEmail() -> Bool {
            let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
        }
    }
    

