import UIKit

/// Controller to redirect to landing page
class ChallengerTabViewController: UITabBarController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appdelegate.tabView = self
        
        if (User.currentUser.userId == nil) {
            self.performSegueWithIdentifier("ToLandingPage", sender: self)
        }
    }
}
