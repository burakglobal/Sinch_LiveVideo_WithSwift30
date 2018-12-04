import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!     
    @IBOutlet weak var imgView: UIImageView!
    var pIndex = 0

    @IBOutlet weak var close: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = UIImage(named:"how0")
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
    @IBAction func closem(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func valuee(_ sender: Any) {
       
        if menuShown {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "yap"), object: nil)
            return
        }
        if pIndex == 11 {
            pIndex = 0
        }
        else
        {
            pIndex += 1
        }
        
            self.pageControl.currentPage = self.pIndex
            self.imgView.leftToRightAnimation()
            self.imgView.image = UIImage(named:"how\(self.pageControl.currentPage)")
        
        
           }
    
    @IBAction func valueleft(_ sender: Any) {
        
        
        if pIndex == 0 {
            pIndex = 11
        }
        else
        {
            pIndex -= 1
        }
             self.pageControl.currentPage = self.pIndex
        self.imgView.rightToLeftAnimation()
        self.imgView.image = UIImage(named:"how\(self.pageControl.currentPage)")
       

        
        
    }
    
    
    @IBAction func change(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.imgView.image = UIImage(named:"How\(self.pageControl.currentPage)")
            self.pIndex = self.pageControl.currentPage
        }, completion: { (Bool) -> Void in
        })


    }
}


