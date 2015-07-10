import UIKit

/// Table view controller for rendering activities
class ActivitiesTableViewController: BaseSubTabViewController, CommentTextFieldDelegate, ActivityCellDelegate {

    var activityArr: [Activity] = []
    var activityHeightArr: [CGFloat] = []
    
    var commentTextField: CommentTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAndFilterActivities()
        
        // Initialize the data
        var activityNib = UINib(nibName: "ActivityCell", bundle: nil)
        tableView.registerNib(activityNib, forCellReuseIdentifier: "activityCell")
        
        var eventNib = UINib(nibName: "EventCell", bundle: nil)
        tableView.registerNib(eventNib, forCellReuseIdentifier: "eventCell")
        
        var ideaNib = UINib(nibName: "IdeaCell", bundle: nil)
        tableView.registerNib(ideaNib, forCellReuseIdentifier: "ideaCell")
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshTableView"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let height = tableView.frame.width * 58 / 375
        commentTextField = CommentTextField(frame: CGRect(x: 0, y: tableView.frame.height - height - self.tabBarController!.tabBar.frame.height, width: tableView.frame.width, height: height))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTableView()
        
        commentTextField!.removeFromSuperview()
        commentTextField!.hidden = true
        
        super.updateViewConstraints()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.activityArr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ActivityCell = tableView.dequeueReusableCellWithIdentifier("activityCell") as! ActivityCell
        let activity = self.activityArr[indexPath.row]
        if (activity.objType == Config.eventType.Event.rawValue) {
            let contentCell = tableView.dequeueReusableCellWithIdentifier("eventCell") as! EventCell
            let event = Event.getEvent(activity.objId)
            contentCell.loadEvent(event)
            cell.loadActivity(activity, contentCell: contentCell, index: indexPath.row)
        } else if (activity.objType == Config.eventType.Idea.rawValue) {
            let contentCell = tableView.dequeueReusableCellWithIdentifier("ideaCell") as! IdeaCell
            let idea = Idea.getIdea(activity.objId)
            contentCell.loadIdea(idea)
            cell.idea = idea
            cell.loadActivity(activity, contentCell: contentCell, index: indexPath.row)
        }
        
        cell.profileDelegate = self
        cell.activityCellDelegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let activity = self.activityArr[indexPath.row]
        if (activity.objType == Config.eventType.Event.rawValue) {
            var eventDetail = EventDetailViewController(nibName: "EventDetailViewController", bundle: nil)
            eventDetail.loadEvent(activity.objId)
            eventDetail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(eventDetail, animated: true)
        } else if (activity.objType == Config.eventType.Idea.rawValue) {
            var ideaDetail = IdeaDetailViewController(nibName: "IdeaDetailViewController", bundle: nil)
            ideaDetail.loadIdea(activity.objId)
            ideaDetail.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(ideaDetail, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
  
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return activityHeightArr[indexPath.row]
    }
    
    /// Refresh this UI
    func refreshTableView() {
        getAndFilterActivities()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func getAndFilterActivities() {
        activityArr.removeAll(keepCapacity: false)
        activityHeightArr.removeAll(keepCapacity: false)
        
        let tmpArr: [Activity] = Activity.getActivities()
        for a in tmpArr {
            if (a.verb == "create") {
                activityArr.append(a)
                
                var height: CGFloat = 217
                if (a.objType == Config.eventType.Event.rawValue) {
                    let commentItems = Comment.getComments(Config.eventType.Event, targetId: a.objId)
                    for comment in commentItems {
                        height += Comment.calculateCommentCellHeight(Comment.assembleComment(comment.userName, content: comment.content), width: tableView.frame.width)
                    }
                } else if (a.objType == Config.eventType.Idea.rawValue) {
                    let commentItems = Comment.getComments(Config.eventType.Idea, targetId: a.objId)
                    for comment in commentItems {
                        height += Comment.calculateCommentCellHeight(Comment.assembleComment(comment.userName, content: comment.content), width: tableView.frame.width)
                    }
                }
                activityHeightArr.append(height)
            }
        }
    }
    
    func postCommentCallback(heightToAdd: CGFloat) {
        refreshTableView()
    }
    
    func showCommentTextField(index: Int, id: String, type: Config.eventType) {
        // Initialize comment text field
        commentTextField!.id = id
        commentTextField!.type = type
        commentTextField!.eventTitle = ""
        commentTextField!.delegate = self
        
        view.superview!.addSubview(commentTextField!)
        commentTextField!.hidden = false
        commentTextField!.whenAppear()
    }

    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            commentTextField!.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height + self.tabBarController!.tabBar.frame.height)
        }
        print("Keyboard shown")
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        commentTextField!.removeFromSuperview()
        commentTextField!.hidden = true
        commentTextField!.transform = CGAffineTransformMakeTranslation(0, self.tabBarController!.tabBar.frame.height)
    }
}

