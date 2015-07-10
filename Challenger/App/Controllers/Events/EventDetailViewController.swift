import UIKit

/// Controller for rendering the event details UI
class EventDetailViewController: UIViewController, CoupleButtonDelegate, CommentTableViewDelegate, ProfileDelegate, CommentTextFieldDelegate,
    UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventDesc: UILabel!
    @IBOutlet weak var userLogo: UIImageView!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var maxCapacity: UILabel!
    @IBOutlet weak var registerPolicy: UILabel!
    @IBOutlet weak var registerUsers: UICollectionView!

    @IBOutlet weak var coupleButton: CoupleButton!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!

    @IBOutlet weak var dateMonth: UILabel!
    @IBOutlet weak var dateDay: UILabel!
    @IBOutlet weak var eDateEndMinute: UILabel!
    @IBOutlet weak var eDateEndHour: UILabel!
    @IBOutlet weak var eDateMinute: UILabel!
    @IBOutlet weak var eDateHour: UILabel!
    @IBOutlet weak var eDateDay: UILabel!
    @IBOutlet weak var eDateMonth: UILabel!
    @IBOutlet weak var regiDateMonth: UILabel!
    @IBOutlet weak var regiDateDay: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var join: UILabel!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var eventType: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var contentViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewTop: NSLayoutConstraint!

    @IBOutlet weak var registeredUsersHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentListHeight: NSLayoutConstraint!

    @IBOutlet weak var commentList: UIView!

    @IBOutlet weak var commentTextField: CommentTextField!
    
    var eventId: String = ""
    var eventRegisteredUsers: Dictionary<String, String> = [String: String]()
    
    var commentController: CommentTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let font = UIFont(name: Config.fontFamilyLight, size: 16) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.navigationItem.title = "Event details"
        
        scrollView.frame = scrollView.superview!.bounds
        
        // Do any additional setup after loading the view.
        // Event Type appearance
        eventType.layer.borderWidth = 1
        eventType.layer.cornerRadius = 3
        eventType.clipsToBounds = true

        // Load Event Detail Data
        let e = EventDetail.getEventDetail(eventId)
        eventRegisteredUsers = e.applyingUsers
        
        // Initialize the UI
        eventTitle.text = e.eventTitle
        eventType.text = e.category.capitalizedString
        eventType.backgroundColor = Utilities.eventTypeToColor(e.category)
        eventType.layer.borderColor = Utilities.eventTypeToColor(e.category).CGColor
        
        // Presenter
        userName.setTitle(e.presenter, forState: UIControlState.Normal)
        userEmail.text = e.presenterEmail
        userTitle.text = e.presenterTitle
        let userAvatarUrl = NSURL(string: e.presenterLogo)
        let userAvatar = NSData(contentsOfURL: userAvatarUrl!)
        userLogo.image = Utilities.cropToSquare(image: ((userAvatar != nil) ? UIImage(data: userAvatar!) : UIImage(named: e.images))!)
        
        // Location
        location.text = e.location
        maxCapacity.text = e.maxCapacity
        registerPolicy.text = e.registerPolicy
        
        var dtArr = e.date.componentsSeparatedByString("-")
        dateMonth.text = dtArr[1]
        dateDay.text = dtArr[2]
        like.text = e.like
        join.text = e.join
        comments.text = e.commentsNum
        let url = NSURL(string: e.images)
        let data = NSData(contentsOfURL: url!)
        self.image.image = (data != nil) ? UIImage(data: data!) : UIImage(named: e.images)

        // Update image height
        var imageHeightConstant: CGFloat = 0
        if (image.image != nil) {
            imageHeightConstant = view.bounds.width * image.image!.size.height / image.image!.size.width
        }
        imageHeight.constant = imageHeightConstant
        
        eventDesc.text = e.eventDesc
        dtArr = e.deadline.componentsSeparatedByString("-")
        regiDateMonth.text = dtArr[1]
        regiDateDay.text = dtArr[2]
        
        var tmpArr = e.eSpan.componentsSeparatedByString(";")
        var eStartDateArr = tmpArr[0].componentsSeparatedByString("-")
        var eEndDateArr = tmpArr[1].componentsSeparatedByString("-")
        eDateMonth.text = eStartDateArr[1]
        eDateDay.text = eStartDateArr[2]
        eDateHour.text = eStartDateArr[3]
        eDateMinute.text = eStartDateArr[4]
        eDateEndHour.text = eEndDateArr[3]
        eDateEndMinute.text = eEndDateArr[4]
        
        if User.currentUser.isEventRegistered(eventId) {
            registerButton.setTitle("Quit the registration", forState: .Normal)
        }
        else {
            registerButton.setTitle("Register", forState: .Normal)
        }
        
        // Couple button
        coupleButton.delegate = self
        let followButtonTitle = User.currentUser.doesUserFollowEvent(eventId) ? "- Unfollow" : "+ Follow"
        coupleButton.setupButton(1, title: followButtonTitle, imageName: nil)
        let likeButtonTitle = User.currentUser.doesUserLikeEvent(eventId) ? "Unlike" : "Like"
        coupleButton.setupButton(2, title: likeButtonTitle, imageName: "like_blue")
        
        // Initialize user avatar collection
        var nibAvatar = UINib(nibName: "UserAvatarCell", bundle: nil)
        registerUsers.registerNib(nibAvatar, forCellWithReuseIdentifier: "avatar")
        
        registerUsers.delegate = self
        registerUsers.dataSource = self
        
        // Initialize comments list
        commentController = CommentTableViewController(nibName: "CommentTableViewController", bundle: nil)
        commentController!.id = eventId
        commentController!.type = Config.eventType.Event
        commentController!.delegate = self
        commentController!.profileDelegate = self
        commentList.addSubview(commentController!.view)
        
        // Initialize comment text field
        commentTextField.id = eventId
        commentTextField.type = Config.eventType.Event
        commentTextField.eventTitle = e.presenterTitle
        commentTextField.delegate = self
        
        self.updateViewConstraints()
    }

    func loadEvent(eventId: String) {
        self.eventId = eventId
    }
    
    @IBAction func showCommentTextField() {
        let bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
        commentTextField.hidden = false
        commentTextField.whenAppear()
    }
    
    @IBAction func registerUnregister() {
        let previousJoinNum = join.text!.toInt()!
        if User.currentUser.isEventRegistered(eventId) {
            if User.currentUser.unregisterEvent(eventId) {
                registerButton.setTitle("Register", forState: .Normal)
                join.text = "\(previousJoinNum-1)"
            }
        }
        else {
            if User.currentUser.registerEvent(eventId) {
                registerButton.setTitle("Quit the registration", forState: .Normal)
                join.text = "\(previousJoinNum+1)"
            }
        }
    }
    
    func followUnfollow() {
        if User.currentUser.doesUserFollowEvent(eventId) {
            if User.currentUser.unfollowEvent(eventId) {
                coupleButton.setupButton(1, title: "+ Follow", imageName: nil)
            }
        }
        else {
            if User.currentUser.followEvent(eventId, title: eventTitle.text!) {
                coupleButton.setupButton(1, title: "- Unfollow", imageName: nil)
            }
        }
    }
    
    func likeUnlike() {
        let previousLikeNum = like.text!.toInt()!
        if User.currentUser.doesUserLikeEvent(eventId) {
            if User.currentUser.unlikeEvent(eventId) {
                coupleButton.setupButton(2, title: "Like", imageName: "like_blue")
                like.text = "\(previousLikeNum-1)"
            }
        }
        else {
            if User.currentUser.likeEvent(eventId, title: eventTitle.text!) {
                coupleButton.setupButton(2, title: "Unlike", imageName: "like_blue")
                like.text = "\(previousLikeNum+1)"
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            view.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height)
        }
        print("Keyboard shown")
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        commentTextField.hidden = true
        view.transform = CGAffineTransformMakeTranslation(0, 0)
    }
    
    func buttonTapped(tag: Int) {
        switch tag {
        case 1: // Follow/unfollow
            followUnfollow()
            break
        case 2: // Like/unlike
            likeUnlike()
            break
        default:
            break
        }
    }
    
    func postCommentCallback(heightToAdd: CGFloat) {
        commentTextField.hidden = true
        commentController!.refreshDetailEventView()
        
        let previousCommentNum = comments.text!.toInt()!
        comments.text = "\(previousCommentNum+1)"
        
        let bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height + heightToAdd)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    func updateSuperviewHeight(height: CGFloat) {
        commentListHeight.constant = height
        self.updateViewConstraints()
    }
    
    func pushToProfile(isSelfProfile: Bool, userID: String) {
        var profileController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileController.isSelfProfile = isSelfProfile
        profileController.userID = userID
        profileController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    //Collection View
    
    func adjustCollectionViewHeight(count: Int) {
        let width = registerUsers.bounds.width
        let maxPerRow = floor((width + 4) / 44)
        let rowsCount = ceil(CGFloat(count) / maxPerRow)
        registeredUsersHeight.constant = CGFloat(44 * rowsCount - 4)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = eventRegisteredUsers.count
        adjustCollectionViewHeight(count)
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var userid = eventRegisteredUsers.keys.array[indexPath.item]
        var avatar = eventRegisteredUsers[userid]!
        
        var item = registerUsers.dequeueReusableCellWithReuseIdentifier("avatar", forIndexPath: indexPath) as! UserAvatarCell
        item.delegate = self
        
        item.loadUser(userid, avatar: avatar)
        
        return item
    }
}
