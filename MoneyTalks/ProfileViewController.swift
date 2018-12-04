//
//  ProfileViewController
//  MoneyTalks
//
//  Created by BURAK KEBAPCI on 4/15/17.

import UIKit

class ProfileViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    @IBOutlet weak var maxdistance: UILabel!

    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var sexsegmentcontrol: UISegmentedControl!
    @IBOutlet weak var aramaslider: UISlider!
    
    let pickerData =  ["Any","18-22","23-30","31-40","41-54","55+"]
    var selected = 0

    override func viewDidLoad() {
        super.viewDidLoad()

       
        //sexsegmentcontrol.setFontSize(fontSize: 30)
        let attr = NSDictionary(object: UIFont(name: "GillSans", size: 15.0)!, forKey: NSFontAttributeName as NSCopying)
        sexsegmentcontrol.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        // Do any additional setup after loading the view.
        myPickerView.delegate = self
        myPickerView.dataSource = self
        //myPickerView.selectRow(1, inComponent:sizeComponent, animated: false)
        sexsegmentcontrol.selectedSegmentIndex = slookingfor
        
        if startage == 18 {
            selected = 1

            myPickerView.selectRow(1,inComponent: 0, animated: false)
            
        }
        
        if startage == 23 {
            selected = 2

            myPickerView.selectRow(2,inComponent: 0, animated: false)
            
        }
        if startage == 31 {
            selected = 3
            myPickerView.selectRow(3,inComponent: 0, animated: false)
            
        }
        if startage == 41 {
            selected = 4
            myPickerView.selectRow(4,inComponent: 0, animated: false)
            
        }
        if startage == 55 {
            selected = 5
            myPickerView.selectRow(5,inComponent: 0, animated: false)
            
        }
        
        
        
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
    }
    @IBAction func milegale(_ sender: Any) {
        let x  = Int(aramaslider.value)
        
        maxdistance.text = "Distance (\(x) Miles)"
    }
    
    
    @IBAction func applyfilter(_ sender: Any) {
        popped=3
        if selected==1 {
            startage=18
            finishage=22
        }
        else if selected==2 {
            startage=23
            finishage=30
        }
        else if selected==3 {
            startage=31
            finishage=40
        }
        else if selected==4 {
            startage=41
            finishage=54
        }
        else if selected==5 {
            startage=55
            finishage=150
        }
        else{
            startage=0
            finishage=0
        }
        slookingfor = sexsegmentcontrol.selectedSegmentIndex
        mileage = Int(self.aramaslider.value)
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "aramayap"), object: nil)
        self.view.removeFromSuperview()
    }
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = row
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
