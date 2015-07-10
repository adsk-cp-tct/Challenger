import UIKit

/// Controller for rendering the menu bar
class BaseSubTabViewController: UITableViewController, ProfileDelegate {
    
    private struct Constants {
        static let PADDING: CGFloat = 10
        static let LOGO_WIDTH: CGFloat = 77
        static let LOGO_HEIGHT: CGFloat = 25
        static let MENU_BUTTON_WIDTH: CGFloat = 180
        static let MENU_BUTTON_HEIGHT: CGFloat = 50
        static let SEGMENT_HEIGHT: CGFloat = 1
    }

    var menuView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set left button for the simple logo
        let logoView = UIImageView(image: UIImage(named: "logo_simple"))
        logoView.frame.size = CGRect(x: Constants.PADDING, y: Constants.PADDING, width: Constants.LOGO_WIDTH, height: Constants.LOGO_HEIGHT).size
        let leftBarButton = UIBarButtonItem(customView: logoView)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // Set right button for navigate to show on/off the dropdown menu
        let dropdownButton = UIBarButtonItem(image: UIImage(named: "quote"), style: .Plain, target: self, action: "switchDropdownMenuOnOff")
        dropdownButton.imageInsets = UIEdgeInsets(top: Constants.PADDING, left: 0, bottom: Constants.PADDING, right: Constants.PADDING + Constants.PADDING)
        self.navigationItem.rightBarButtonItem = dropdownButton
        
        // Create the dropdown menu
        createMenu()
        
        // Prevent scroll the table view horizontally
        tableView.alwaysBounceHorizontal = false
    }
    
    func switchDropdownMenuOnOff() {
        if (menuView!.hidden) {
            menuView!.frame = CGRect(x: self.view.frame.maxX - 202, y: self.view.frame.minY + 4, width: 200, height: 152)
            self.view.superview?.addSubview(menuView!)
            menuView!.hidden = false
        } else {
            menuView!.removeFromSuperview()
            menuView!.hidden = true
        }
    }
    
    func postIdea() {
        menuView!.hidden = true
        var post = PostIdeaViewController(nibName: "PostIdeaViewController", bundle: nil)
        post.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(post, animated: true)
    }
    
    func aboutMe() {
        menuView!.hidden = true
        pushToProfile(true, userID: User.currentUser.userId!)
    }
    
    func signOut() {
        menuView!.hidden = true
        User.currentUser.signOut()
        self.tabBarController!.performSegueWithIdentifier("ToLandingPage", sender: self)
    }
    
    func pushToProfile(isSelfProfile: Bool, userID: String) {
        var profileController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileController.isSelfProfile = isSelfProfile
        profileController.userID = userID
        profileController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    private func createMenu() {
        // Create the menu view
        menuView = UIView()
        menuView!.setTranslatesAutoresizingMaskIntoConstraints(true)
        menuView!.backgroundColor = UIColor.whiteColor()
        
        // Beautify it with shadow
        menuView!.layer.shadowColor = UIColor.blackColor().CGColor
        menuView!.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        menuView!.layer.shadowOpacity = 0.5
        menuView!.layer.shadowRadius = 2.0
        
        // Hide it by default, then open it on demand
        menuView!.hidden = true
        
        // Create button inside
        let postIdeaY = createMenuButton("Post an idea", originY: 0, action: "postIdea", needSegment: false)
        let aboutMeY = createMenuButton("About me", originY: postIdeaY, action: "aboutMe", needSegment: true)
        createMenuButton("Sign out", originY: aboutMeY, action: "signOut", needSegment: true)
    }
    
    private func createMenuButton(title: String, originY: CGFloat, action: String, needSegment: Bool) -> CGFloat {
        var frameY = originY
        if (needSegment) {
            let segmentView = UIView(frame: CGRect(x: Constants.PADDING, y: originY, width: Constants.MENU_BUTTON_WIDTH, height: Constants.SEGMENT_HEIGHT))
            segmentView.backgroundColor = UIColor.lightGrayColor()
            menuView!.addSubview(segmentView)
            
            frameY = segmentView.frame.maxY
        }
        
        let menuBt = UIButton(frame: CGRect(x: Constants.PADDING, y: frameY, width: Constants.MENU_BUTTON_WIDTH, height: Constants.MENU_BUTTON_HEIGHT))
        menuBt.setTitle(title, forState: .Normal)
        menuBt.titleLabel!.font =  UIFont(name: Config.fontFamilyLight, size: Config.buttonFontSize)
        menuBt.setTitleColor(UIColor.blackColor(), forState: .Normal)
        menuBt.contentHorizontalAlignment = .Left
        menuBt.backgroundColor = UIColor.whiteColor()
        menuBt.addTarget(self, action: Selector(action), forControlEvents: UIControlEvents.TouchUpInside)
        menuView!.addSubview(menuBt)
        
        return menuBt.frame.maxY
    }

}
