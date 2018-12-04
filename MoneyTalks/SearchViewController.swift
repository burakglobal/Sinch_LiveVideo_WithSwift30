
import UIKit
import SwiftyJSON

class SearchViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var ageg: UITextField!
    @IBOutlet weak var selfsummary: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
 

    @IBOutlet weak var removepicture: UIButton!
    @IBOutlet weak var lookingforWhat: UISegmentedControl!
    @IBOutlet weak var iamwhat: UISegmentedControl!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var nameTextBoxt: UITextField!
    @IBOutlet weak var emailTextbox: UITextField!

    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var updateProfile: UIButton!
    @IBOutlet weak var closeAccount: UIButton!
    let settings = GlobalViewController()
    var choosenimage:UIImage? = nil
    var imageURL:URL? = nil
    var imagePicker: UIImagePickerController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "backgroundm")
        self.view.insertSubview(backgroundImage, at: 0)
        
       
        emailTextbox.delegate = self
        nameTextBoxt.delegate = self
        newPassword.delegate = self
        ageg.delegate = self
        newPassword.isSecureTextEntry=true
        selfsummary.delegate = self
        
        
       // self.addLeftImage(imageName: "placeholder-1", textField: emailTextbox)
       // self.addLeftImage(imageName: "profile", textField: nameTextBoxt)
      //  self.addLeftImage(imageName: "key-2", textField: newPassword)
      //  self.addLeftImage(imageName: "birthdate", textField: birthDate)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        profileImage.downloadedFrom(link: settings.getDefaults(isim: "picture"))
        profileImage.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
       profileImage.layer.cornerRadius = 45
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.borderWidth = 2

        LoadingOverlay.shared.hideOverlayView()
        
        
        nameTextBoxt.text = settings.getDefaults(isim: "facebookName")
        emailTextbox.text = settings.getDefaults(isim: "facebookEMail")
      
        ageg.text = settings.getDefaults(isim: "age")
        selfsummary.text = settings.getDefaults(isim: "summary")
        
        closeAccount.layer.cornerRadius = 10
        closeAccount.layer.borderWidth = 1
        
       
        updateProfile.layer.cornerRadius = 10
        updateProfile.layer.borderWidth = 1
        
       print(settings.getDefaults(isim: "iam"))
        
        iamwhat.selectedSegmentIndex = Int(settings.getDefaults(isim: "iam"))!
        lookingforWhat.selectedSegmentIndex = Int(settings.getDefaults(isim: "lookingfor"))!
        
        
        
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
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
   
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        //MARK:cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y =  -getKeyboardHeight(notification)
      }
    
    func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
     }

    @IBAction func takePictureAction(_ sender: Any) {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
            imagePicker.videoQuality = UIImagePickerControllerQualityType.type640x480
            
        present(imagePicker, animated: true, completion: nil)
        } else {
            noCamera()
        }
        
        
        
    }
    
    @IBAction func removepicture(_ sender: Any) {
        
        
        let optionMenu = UIAlertController(title: nil, message: "Would you like to remove this picture?", preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Yes!", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            
            
            let makeURL = self.settings.serverip + "/_table/member?filter=fbid=" + self.settings.getDefaults(isim: "facebookID") + "&api_key="  + self.settings.apiText + "&`session_id=\(self.settings.getDefaults(isim: "sessionToken"))&session_token=\(self.settings.getDefaults(isim: "sessionToken"))"
            let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            
            var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
            request.httpMethod = "PUT"
            
            var json = [:] as [String: Any]
            
            json = [
                "resource": [
                    "picture": "http://i.imgur.com/fYVSRWr.png"
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
                    
                    do {
                        
                        let alert = UIAlertController(title: "Account", message: "Successfully Updated", preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        
                        self.settings.saveDefaults(deger: "http://i.imgur.com/fYVSRWr.png" , isim: "picture")
                        
                        self.profileImage.downloadedFrom(link: self.settings.getDefaults(isim: "picture"))
                        self.profileImage.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
                        self.profileImage.layer.cornerRadius = 45
                        self.profileImage.contentMode = .scaleAspectFill
                        self.profileImage.layer.borderWidth = 2
                        

                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
            
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.profileImage.downloadedFrom(link:  self.settings.getDefaults(isim: "picture"))
            self.profileImage.contentMode = .scaleAspectFill

        })
        
        
        // 4
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
        
        

        
        
    }
    
    
    
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func fixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
          choosenimage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
      profileImage.image = choosenimage
        profileImage.contentMode = .scaleAspectFill

         dismiss(animated: true, completion: nil)
    
       
            
             imageGonder()
            
            
        
        
        
    }

func imageGonder(){
    
    
    LoadingOverlay.shared.showOverlay(view: self.view)
    
    
    
        let myUrl = NSURL(string:  self.settings.pictureUploadURL + "?id=\(settings.getDefaults(isim: "facebookID"))")
        
        let request = NSMutableURLRequest(url:myUrl! as URL)
        request.httpMethod = "POST"
    
        let param = [
            "key"  : "DFJSKLDJFLSKDJF23I402394I293RIJWDFSDFLJFDLJKE10WEU0192EI901I2E0I912EI120EKP1JDPADKFDSFJKSDJFKLJ2J0RJ203JF203J0JCDPISJFIDFJOSDJFOSJDFOJSDFOIJSODFJSODFJOSDJFOASJFOASJDFOAJSDFOASJDFOAISDJFOAJSDFOIJASDFOIJASDF23OIJR2O3IJ2OI3RJ2OI3JROI23JRO23IOJRIO23JRR2OI3IO23JRO23JROISDJOISJDFOSJDFOSDJFOSDJFOSIDFJSODFJOSDOIJSODCJSODICJOSDOICJOSDIOCJDOISCJO23IJO23IJ423OI4JO23O423I4IO23OI4IO234O",
            "userId"    : settings.getDefaults(isim: "facebookID"),
            "video"    : settings.getDefaults(isim: "facebookID")+".jpg"
            ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
    
    
        let image_data = UIImageJPEGRepresentation(choosenimage!, 0.2)
    
        if(image_data==nil)  { return; }
    
        request.httpBody = createBodyWithParameters(parameters: param, idd: settings.getDefaults(isim: "facebookID"), filePathKey: "file", imageDataKey: image_data! as NSData, boundary: boundary) as Data
        
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                LoadingOverlay.shared.hideOverlayView()
                
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            DispatchQueue.main.async {
                
                self.updateProfilePicture()
                LoadingOverlay.shared.hideOverlayView()
                
                
            }
            
    }
    
        task.resume()

    
    

}
   
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?,idd: String?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSMutableData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        let filename = idd!+".jpg"
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey as Data as Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
         
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    
    func updateProfilePicture() {
        
        
        
        let optionMenu = UIAlertController(title: nil, message: "Would you like to keep this picture?", preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            
            
            let makeURL = self.settings.serverip + "/_table/member?filter=fbid=" + self.settings.getDefaults(isim: "facebookID") + "&api_key="  + self.settings.apiText + "&`session_id=\(self.settings.getDefaults(isim: "sessionToken"))&session_token=\(self.settings.getDefaults(isim: "sessionToken"))"
            let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            
            var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
            request.httpMethod = "PUT"
            
            var json = [:] as [String: Any]
            
                  json = [
                    "resource": [
                        "picture": self.settings.pictureURL + self.settings.getDefaults(isim: "facebookID") + ".jpg"
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
                    
                    do {
                        
                        let alert = UIAlertController(title: "Account", message: "Successfully Updated", preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        
                        self.settings.saveDefaults(deger: self.settings.pictureURL + self.settings.getDefaults(isim: "facebookID") + ".jpg" , isim: "picture")
                        
                    
                        
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
            
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
          self.profileImage.downloadedFrom(link:  self.settings.getDefaults(isim: "picture"))
            self.profileImage.contentMode = .scaleAspectFill

        })
        
        
        // 4
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
        
        
        
        
        
        
        
    }

    func updateaccount()
    {
        
        let checkage = Int(ageg.text!)
        
        if checkage==nil {
            let alert = UIAlertController(title: "Account", message: "Please Enter Your Age!", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        let makeURL = self.settings.serverip + "/_table/member?filter=fbid=" + self.settings.getDefaults(isim: "facebookID") + "&api_key="  + self.settings.apiText + "&`session_id=\(self.settings.getDefaults(isim: "sessionToken"))&session_token=\(self.settings.getDefaults(isim: "sessionToken"))"
        let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
        request.httpMethod = "PUT"
        
        var json = [:] as [String: Any]
        if ageg.text=="" {
            ageg.text="0"
        }
        if selfsummary.text=="" {
            selfsummary.text="N"
        }
        
        if self.newPassword.text != "" {
            
            json = [
                "resource": [
                    "name": self.nameTextBoxt.text!,
                    "sex": self.iamwhat.selectedSegmentIndex,
                    "age": self.ageg.text!,
                    "summary": self.selfsummary.text!,
                    "email": self.emailTextbox.text!,
                    "password": self.newPassword.text!,
                    "lookingfor": self.lookingforWhat.selectedSegmentIndex
                ],
                ] as [String: Any]
            
        }
        else{
            
            json = [
                "resource": [
                    "name": self.nameTextBoxt.text!,
                    "sex": self.iamwhat.selectedSegmentIndex,
                    "age": self.ageg.text!,
                    "summary": self.selfsummary.text!,
                    "email": self.emailTextbox.text!,
                    "lookingfor": self.lookingforWhat.selectedSegmentIndex
                ],
                ] as [String: Any]
        }
        
        
        
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
                    
                    self.settings.saveDefaults(deger: String(self.iamwhat.selectedSegmentIndex),isim: "iam")
                    self.settings.saveDefaults(deger: String(self.lookingforWhat.selectedSegmentIndex),isim: "lookingfor")
                     self.settings.saveDefaults(deger: self.selfsummary.text!,isim: "summary")
                     self.settings.saveDefaults(deger: self.ageg.text!,isim: "age")
                
                
               self.opdone()
                }
            }
        }
        task.resume()

    }
    
    func opdone()
    {
        let alert = UIAlertController(title: "Account", message: "Successfully Updated", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            // perhaps use action.title here
        })
        
        self.present(alert, animated: true)
    }
    
    
    func checkEmail()
    {
        let makeURL = settings.serverip + "/_table/member?fields=*&filter=(email=\(emailTextbox.text!))&api_key=\(settings.apiText)&session_id=\(settings.getDefaults(isim: "sessionToken"))&session_token=\(settings.getDefaults(isim: "sessionToken"))"
        
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
                        
                        self.emailTextbox.text=self.settings.getDefaults(isim: "facebookEMail")
                        
                        let alert = UIAlertController(title: "Account", message: "This E-Mail is Exist!, Please Select", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Try Another E-Mail", style: .default) { action in
                            // perhaps use action.title here
                        })
        
                        self.present(alert, animated: true)
                        
                        
                        
                    }
                    else{
                        self.settings.saveDefaults(deger: self.emailTextbox.text!, isim: "facebookEMail")
                    }
                    
                    }
                    
                }
                
            }
        }
        task.resume()
        
    }

    
    @IBAction func updateProfileTouchDown(_ sender: Any) {
        
        
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .alert)
        
      
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            if self.emailTextbox.text != self.settings.getDefaults(isim: "facebookEMail") {
                self.checkEmail()
            }
            self.updateaccount()
            
        
        
        
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        
        // 4
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
        

            
            
        
        
       
    }
    
    @IBAction func closeAccountTouchDown(_ sender: Any) {
        
        
        
        let optionMenu = UIAlertController(title: nil, message: "Would you like to close your account?", preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Yes!", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            
            
            let makeURL = self.settings.serverip + "/_table/member?filter=fbid=" + self.settings.getDefaults(isim: "facebookID") + "&api_key="  + self.settings.apiText + "&`session_id=\(self.settings.getDefaults(isim: "sessionToken"))&session_token=\(self.settings.getDefaults(isim: "sessionToken"))"
            let urlwithPercentEscapes = makeURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            
            var request = URLRequest(url: URL(string: urlwithPercentEscapes!)!)
            request.httpMethod = "PUT"
            
            var json = [:] as [String: Any]
            
            json = [
                "resource": [
                    "status": 0
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
                    
                    do {
                        
                        let alert = UIAlertController(title: "Account", message: "Account Deactivated!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        
                        let lvc = LoginViewController()
                        lvc.logout()

                        
                        
                        
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
            
            }
            task.resume()
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        
        // 4
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        

            
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        nameTextBoxt.resignFirstResponder()
        emailTextbox.resignFirstResponder()
        newPassword.resignFirstResponder()
        ageg.resignFirstResponder()
        selfsummary.resignFirstResponder()
        view.frame.origin.y = 0

        
     }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        view.frame.origin.y = 0

        return true
    }
    
    
}
 
