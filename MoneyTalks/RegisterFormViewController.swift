//
//  RegisterFormViewController.swift
//
//  Created by BURAK KEBAPCI on 3/10/17. 
//

import UIKit
import SwiftyJSON

class RegisterFormViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var nameTextBox: UITextField!
    @IBOutlet weak var emailTextBoxt: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var confirmPasswordTextBox: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    var settings = GlobalViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bg")
        self.view.insertSubview(backgroundImage, at: 0)

        nameTextBox.delegate = self
        emailTextBoxt.delegate = self
        passwordTextBox.delegate = self
        confirmPasswordTextBox.delegate = self
        passwordTextBox.isSecureTextEntry=true
        confirmPasswordTextBox.isSecureTextEntry=true
        signUpButton.setImage(UIImage(named:"profile"), for: UIControlState.normal)
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.red.cgColor

        
        self.addLeftImage(imageName: "placeholder-1", textField: emailTextBoxt)
        
        self.addLeftImage(imageName: "key-2", textField: passwordTextBox)
        self.addLeftImage(imageName: "key-2", textField: confirmPasswordTextBox)
        self.addLeftImage(imageName: "profile", textField: nameTextBox)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
    
    
    
    
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        emailTextBoxt.resignFirstResponder()
        passwordTextBox.resignFirstResponder()
         confirmPasswordTextBox.resignFirstResponder()
         nameTextBox.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    

    @IBAction func signupButtonTouchDown(_ sender: Any) {
        
        if nameTextBox.text == "" {
            
            let uiAlert = UIAlertController(title: "Register", message: "Please Enter Your Name", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            return
        }

        if emailTextBoxt.text == "" {
            
            let uiAlert = UIAlertController(title: "Register", message: "Please Enter Your E-Mail", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            return
        }
        if passwordTextBox.text == "" {
            
            let uiAlert = UIAlertController(title: "Register", message: "Please Enter Your Password", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            return
        }
        
        
        if !(emailTextBoxt.text?.isValidEmail())! {
            
            let uiAlert = UIAlertController(title: "Register", message: "Please Enter Correct E-Mail Address", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            return
        }
        
        if (passwordTextBox.text != confirmPasswordTextBox.text)
        {
            
            let uiAlert = UIAlertController(title: "Register", message: "Passwords are not match!", preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                print("Click of cancel button")
            }))
            
            return
        }
        
        
        checkEmail()

        
        
        
        
        
        
    }
    
    
    func resetpasswordprepare() {
        
        let makeURL = self.settings.serverip + "/_table/member?filter=email=" + emailTextBoxt.text! + "&api_key="  + self.settings.apiText + "&`session_id=\(self.settings.getDefaults(isim: "sessionToken"))&session_token=\(self.settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
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
            "first_name": emailTextBoxt.text!,
            "confirm_code": randomcode,
            "to": [
                "name": emailTextBoxt.text!,
                "email": emailTextBoxt.text!
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
                    
                     
                    let uiAlert = UIAlertController(title: "Register", message: "We sent you a new password, Please check you e-mail", preferredStyle: UIAlertControllerStyle.alert)
                    self.present(uiAlert, animated: true, completion: nil)
                    uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                        
                    }))
                    
                }
            }
        }
        
        task.resume()
    }
    

    
    func checkEmail()
    {
        let makeURL = settings.serverip + "/_table/member?fields=*&filter=(email=\(emailTextBoxt.text!))&api_key=\(settings.apiText)&session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        
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
                    let fbidd = getDict[0]["email"]
                    
                    print(json)
                    
                    if fbidd != JSON.null {
                    
                        
                        let alert = UIAlertController(title: "Register", message: "This E-Mail is Exist!, Please Select", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Try Another E-Mail", style: .default) { action in
                            // perhaps use action.title here
                        })
                        alert.addAction(UIAlertAction(title: "Reset Password", style: .default) { action in
                                self.resetpasswordprepare()
                        
                        })
                        self.present(alert, animated: true)
                        return

                        
                    }
                    else{
                        
                        
                      self.goRegisterMe()
                    }
                    
                }
                }
                
            }
        }
        task.resume()
        
    }

    
    
    
    func goRegisterMe()
    {
        let makeURL = settings.serverip + "/_table/member?a=1&" + "api_key="  + settings.apiText + "&session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "POST"
        
        
        let json = [
            "resource": [
                "name": nameTextBox.text!,
                "email": emailTextBoxt.text!,
                "picture": "http://i.imgur.com/fYVSRWr.png",
                "password": passwordTextBox.text!
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
                    if fbidd != JSON.null
                    {
                        self.goPutFBID(fbidd: fbidd.stringValue)
                        
                        
                       
                        let uiAlert = UIAlertController(title: "Register", message: "Welcome To MoneyTalks!, Please Login", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(uiAlert, animated: true, completion: nil)
                        uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                            
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        
                        }

                        
                        
                    }
                    else{
                        let uiAlert = UIAlertController(title: "Register", message: "Network Error", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(uiAlert, animated: true, completion: nil)
                        uiAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: { action in
                            print("Click of cancel button")
                        }))
                        
                        return
                    }

                
                
                
                
                }
            }
            
        }
        task.resume()
    }
    
    
    func goPutFBID(fbidd:String)
    {
        let makeURL = settings.serverip + "/_table/member?filter=id=" + fbidd + "&api_key="  + settings.apiText + "&session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        print(makeURL)
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        
        let json = [
            "resource": [
                "fbid": "nb" + fbidd
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
               
            
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    
}
