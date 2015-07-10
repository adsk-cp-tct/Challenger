import UIKit

protocol ProfileDelegate {
    func pushToProfile(isSelfProfile: Bool, userID: String)
}

/// Controller for rendering the user profile
class ProfileViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var profileBt: UIButton!
    
    @IBOutlet weak var displaySwitcher: UISegmentedControl!
    
    @IBOutlet weak var displayContainerView: UIView!
    
    var isSelfProfile: Bool = false
    var userID: String?
    var followedByCurrentUser = true
    
    private var currentUserProfile: Contact?
    private var profile: Contact?
    
    private var registedEventsViewController: EventTableViewController?
    private var postedIdeasViewController: IdeaTableViewController?
    
    private var activeViewController: BaseSubTabViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Beautify the segmented control
        beautifyDisplaySwitcher()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load profile
        loadProfile()
        
        // Button for self profile and other people's profiles are different by the button
        if isSelfProfile {
            profileBt.setTitle("Edit Profile", forState: .Normal)
        } else {
            followedByCurrentUser = false
            for followUser in currentUserProfile!.followUsers {
                if (followUser == userID) {
                    followedByCurrentUser = true
                }
            }
            profileBt.setTitle(followedByCurrentUser ? "－ Unfollow" : "＋ Follow", forState: .Normal)
        }
    }
    
    @IBAction func doProfileAction() {
        if isSelfProfile {
            // Edit Profile
            editProfile()
        } else {
            // Follow/unfollow user
            followUnfollow()
        }
    }
    
    func editProfile() {
        var editProfileController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        editProfileController.userID = userID
        editProfileController.userEmail = profile!.email
        navigationController?.pushViewController(editProfileController, animated: true)
    }
    
    func followUnfollow() {
        if followedByCurrentUser {
            if User.currentUser.unfollowUser(profile!.id) {
                profileBt.setTitle("＋ Follow", forState: .Normal)
            }
        }
        else {
            if User.currentUser.followUser(profile!.id, followUserName: profile!.name) {
                profileBt.setTitle("－ Unfollow", forState: .Normal)
            }
        }
    }
    
    @IBAction func switchDisplayView(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            activeViewController = registedEventsViewController
            break
        case 1:
            activeViewController = postedIdeasViewController
            break
        default:
            break
        }
    }
    
    private func beautifyDisplaySwitcher() {
        let dividerImg = UIImage(named: "profile_segmented_divider")
        let font = UIFont(name: Config.fontFamilyLight, size: Config.buttonFontSize)!
        let normalDisplayTitleStyle = [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : UIColor.lightGrayColor()
        ]
        let selectedDisplayTitleStyle = [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : UIColor.blackColor()
        ]
        
        // Normal state
        displaySwitcher.setTitleTextAttributes(normalDisplayTitleStyle, forState: .Normal)
        displaySwitcher.setBackgroundImage(UIImage(named: "profile_segmented_bg_normal"), forState: .Normal, barMetrics: .Default)
        displaySwitcher.setDividerImage(dividerImg, forLeftSegmentState: .Normal, rightSegmentState: .Selected, barMetrics: .Default)
        
        // Selected state
        displaySwitcher.setTitleTextAttributes(selectedDisplayTitleStyle, forState: .Selected)
        displaySwitcher.setBackgroundImage(UIImage(named: "profile_segmented_bg_selected"), forState: .Selected, barMetrics: .Default)
        displaySwitcher.setDividerImage(dividerImg, forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    private func loadProfile() {
        currentUserProfile = Contact.getProfile(User.currentUser.userId!)
        if (userID != User.currentUser.userId!) {
            profile = Contact.getProfile(userID!)
        } else {
            profile = currentUserProfile
        }
        userName.text = profile!.name
        userTitle.text = profile!.title
        userEmail.text = profile!.email
        let url = NSURL(string: profile!.avatar)
        let data = NSData(contentsOfURL: url!)
        userAvatar.image = Utilities.cropToSquare(image: ((data != nil) ? UIImage(data: data!) : UIImage(named: profile!.avatar))!)
        
        // Set display view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        registedEventsViewController = storyboard.instantiateViewControllerWithIdentifier("EventTableViewController") as? EventTableViewController
        registedEventsViewController!.byUser = userID!
        postedIdeasViewController = storyboard.instantiateViewControllerWithIdentifier("IdeaTableViewController") as? IdeaTableViewController
        postedIdeasViewController!.byUser = userID!
        activeViewController = registedEventsViewController
    }
    
    private func removeInactiveViewController(inactiveViewController: BaseSubTabViewController?) {
        if let inActiveVC = inactiveViewController {
            // Call before removing child view controller's view from hierarchy
            inActiveVC.willMoveToParentViewController(nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // Call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    private func updateActiveViewController() {
        if let activeVC = activeViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            activeVC.view.frame = displayContainerView.bounds
            displayContainerView.addSubview(activeVC.view)
            
            // call before adding child view controller's view as subview
            activeVC.didMoveToParentViewController(self)
        }
    }
}
