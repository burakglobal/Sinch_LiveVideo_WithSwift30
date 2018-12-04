import UIKit
var menuShown: Bool = false

class ContainerViewController: UIViewController {
    var leftViewController: UIViewController? {
        willSet{
            if self.leftViewController != nil {
                if self.leftViewController!.view != nil {
                    self.leftViewController!.view!.removeFromSuperview()
                }
                self.leftViewController!.removeFromParentViewController()
            }
        }
        
        didSet{
            
            self.view!.addSubview(self.leftViewController!.view)
            self.addChildViewController(self.leftViewController!)
        }
    }
    
    var rightViewController: UIViewController? {
        willSet {
            if self.rightViewController != nil {
                if self.rightViewController!.view != nil {
                    self.rightViewController!.view!.removeFromSuperview()
                }
                self.rightViewController!.removeFromParentViewController()
            }
        }
        
        didSet{
            
            self.view!.addSubview(self.rightViewController!.view)
            self.addChildViewController(self.rightViewController!)
        }
    }
    
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        showMenu()
        
    }
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        hideMenu()
    }
    
    func kapatme(){
      
    }
    
    func showMenu() {
        UIView.animate(withDuration: 0.5, animations: {
            self.rightViewController!.view.frame = CGRect(x: self.view.frame.origin.x + 280, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: { (Bool) -> Void in
                menuShown = true
        })
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.5, animations: {
            self.rightViewController!.view.frame = CGRect(x: 0, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: { (Bool) -> Void in
                menuShown = false
        })
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(hideMenu), name: NSNotification.Name(rawValue: "yap"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMenu), name: NSNotification.Name(rawValue: "yapac"), object: nil)
        

        DispatchQueue.global(qos: .userInitiated).async {
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
              
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainNavigationController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
        
        let menuViewController: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController")as! MenuViewController
        
        self.leftViewController = menuViewController
        self.rightViewController = mainNavigationController
            
            }
        }
      

        
        
    } 
   
    
    
}
