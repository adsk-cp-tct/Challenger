import UIKit

/// Controller for rendering the idea detail UI
class IdeaDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CoupleButtonDelegate, CommentTableViewDelegate, ProfileDelegate, CommentTextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var ideaTitle: UILabel!
    
    @IBOutlet weak var likeNum: UILabel!
    @IBOutlet weak var followNum: UILabel!
    @IBOutlet weak var commentNum: UILabel!
    
    @IBOutlet weak var eventType: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var coupleButton: CoupleButton!
    
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    @IBOutlet weak var followers: UICollectionView!
    @IBOutlet weak var followersHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentList: UIView!
    @IBOutlet weak var commentListHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTextField: CommentTextField!
    
    var ideaId = ""
    var idea: Idea?
    var commentItems: [Comment] = []
    var followersMap: Dictionary<String, String> = [String: String]()
    
    var commentController: CommentTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let font = UIFont(name: Config.fontFamilyLight, size: 16) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        self.navigationItem.title = "Idea details"
        
        scrollView.frame = scrollView.superview!.bounds
        
        // Event Type appearance
        eventType.layer.borderColor = eventType.backgroundColor?.CGColor
        eventType.layer.borderWidth = 1
        eventType.layer.cornerRadius = 3
        eventType.clipsToBounds = true
        
        // Load idea data
        idea = Idea.getIdea(ideaId)

        ideaTitle.text = idea!.title
        likeNum.text = idea!.likeUserCount
        followNum.text = idea!.followersCount
        commentNum.text = idea!.commentsCount
        followersMap = idea!.followers

        let url = NSURL(string: idea!.thumbnails)
        let data = NSData(contentsOfURL: url!)
        self.image.image = (data != nil) ? UIImage(data: data!) : UIImage(named: idea!.thumbnails)
 
        // Update image height
        var imageHeightConstant: CGFloat = 0
        if (image.image != nil) {
            imageHeightConstant = view.bounds.width * image.image!.size.height / image.image!.size.width
        }
        imageHeight.constant = imageHeightConstant
        
        desc.text = idea!.description
        
        // Couple button
        coupleButton.delegate = self
        let followButtonTitle = User.currentUser.doesUserFollowIdea(ideaId) ? "- Unfollow" : "+ Follow"
        coupleButton.setupButton(1, title: followButtonTitle, imageName: nil)
        let likeButtonTitle = User.currentUser.doesUserLikeIdea(ideaId) ? "Unlike" : "Like"
        coupleButton.setupButton(2, title: likeButtonTitle, imageName: "like_blue")

        // Presenter
        let userAvatarUrl = NSURL(string: idea!.createdAvatar)
        let userAvatar = NSData(contentsOfURL: userAvatarUrl!)
        let userAvatarImg = (userAvatar != nil) ? UIImage(data: userAvatar!) : UIImage(named: idea!.createdAvatar)
        userImage.setImage(userAvatarImg, forState: .Normal)
        userName.setTitle(idea!.createdUser, forState: .Normal)
        userEmail.text = idea!.createdEmail
        userTitle.text = idea!.createdDescription
        
        // Initialize user avatar collection
        var nibAvatar = UINib(nibName: "UserAvatarCell", bundle: nil)
        followers.registerNib(nibAvatar, forCellWithReuseIdentifier: "avatar")
        
        followers.delegate = self
        followers.dataSource = self
        
        // Initialize comments list
        commentController = CommentTableViewController(nibName: "CommentTableViewController", bundle: nil)
        commentController!.id = ideaId
        commentController!.type = Config.eventType.Idea
        commentController!.delegate = self
        commentController!.profileDelegate = self
        commentList.addSubview(commentController!.view)
        
        // Initialize comment text field
        commentTextField.id = ideaId
        commentTextField.type = Config.eventType.Event
        commentTextField.eventTitle = ""
        commentTextField.delegate = self
        
        self.updateViewConstraints()
        
    }
    
    func loadIdea(ideaId: String) {
        self.ideaId = ideaId
    }
    
    @IBAction func pushToProfile() {
        pushToProfile(idea!.createdBy == User.currentUser.userId, userID: idea!.createdBy)
    }
    
    
    func buttonTapped(tag: Int) {
        switch tag {
        case 1: // Follow/unfollow
            followPress()
            break
        case 2: // Like/unlike
            likePress()
            break
        default:
            break
        }
    }
    
    func likePress() {
        let previousLikeNum = likeNum.text!.toInt()!
        if User.currentUser.doesUserLikeIdea(ideaId) {
            if User.currentUser.unlikeIdea(ideaId) {
                coupleButton.setupButton(2, title: "Like", imageName: "like_blue")
                likeNum.text = "\(previousLikeNum-1)"
            }
        }
        else {
            if User.currentUser.likeIdea(ideaId, title: ideaTitle.text!) {
                coupleButton.setupButton(2, title: "Unlike", imageName: "like_blue")
                likeNum.text = "\(previousLikeNum+1)"
            }
        }
    }
    
    func followPress() {
        let previousFollowNum = followNum.text!.toInt()!
        if User.currentUser.doesUserFollowIdea(ideaId) {
            if User.currentUser.unfollowIdea(ideaId) {
                coupleButton.setupButton(1, title: "+ Follow", imageName: nil)
                followNum.text = "\(previousFollowNum-1)"
            }
        }
        else {
            if User.currentUser.followIdea(ideaId, title: ideaTitle.text!) {
                coupleButton.setupButton(1, title: "- Unfollow", imageName: nil)
                followNum.text = "\(previousFollowNum+1)"
            }
        }
    }
    
    @IBAction func ShowCommentTextField() {
        let bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
        commentTextField.hidden = false
        commentTextField.whenAppear()
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
        print("Keyboard hidden")
    }
    
    func postCommentCallback(heightToAdd: CGFloat) {
        commentTextField.hidden = true
        commentController!.refreshDetailEventView()
        
        let previousCommentNum = commentNum.text!.toInt()!
        commentNum.text = "\(previousCommentNum+1)"
        
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
        let width = followers.bounds.width
        let maxPerRow = floor((width + 4) / 44)
        let rowsCount = ceil(CGFloat(count) / maxPerRow)
        followersHeight.constant = CGFloat(44 * rowsCount - 4)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = followersMap.count
        adjustCollectionViewHeight(count)
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var userid = followersMap.keys.array[indexPath.item]
        var avatar = followersMap[userid]!
        
        var item = followers.dequeueReusableCellWithReuseIdentifier("avatar", forIndexPath: indexPath) as! UserAvatarCell
        item.delegate = self
        
        item.loadUser(userid, avatar: avatar)
        
        return item
    }

}
