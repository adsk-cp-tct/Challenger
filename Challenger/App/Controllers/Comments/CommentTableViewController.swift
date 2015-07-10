import UIKit

protocol CommentTableViewDelegate {
    func updateSuperviewHeight(height: CGFloat)
}

/// Controller for rendering UI
class CommentController {
    static func initCommentTable(tableView: UITableView) {
        var nibLeft = UINib(nibName: "CommentCellLeft", bundle: nil)
        var nibRight = UINib(nibName: "CommentCellRight", bundle: nil)
        
        tableView.registerNib(nibLeft, forCellReuseIdentifier: "cellLeft")
        tableView.registerNib(nibRight, forCellReuseIdentifier: "cellRight")
    }
    
    static func cell(tableView: UITableView, atIndexPath indexPath: NSIndexPath, fromCommentList: [Comment], profileDelegate: ProfileDelegate?) -> UITableViewCell {
        var comment = fromCommentList[indexPath.row]
        
        if (comment.userName != User.currentUser.userName!){
            var cell = tableView.dequeueReusableCellWithIdentifier("cellLeft", forIndexPath: indexPath) as! CommentCellLeft
            cell.loadComment(comment)
            cell.delegate = profileDelegate
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("cellRight", forIndexPath: indexPath) as! CommentCellRight
            cell.loadComment(comment)
            cell.delegate = profileDelegate
            return cell
        }
    }
    
    static func cellHeight(tableView: UITableView, atIndexPath indexPath: NSIndexPath, fromCommentList: [Comment]) -> CGFloat {
        var comment = fromCommentList[indexPath.row]
        return Comment.calculateCommentCellHeight(Comment.assembleComment(comment.userName, content: comment.content), width: tableView.frame.width)
    }
    
    static func headerFooterHeight() -> CGFloat {
        return 0.1
    }
}

/// Tabc controller for comments
class CommentTableViewController: UITableViewController {
    
    var id: String = ""
    var type: Config.eventType?
    var commentItems : [Comment] = []
    var delegate: CommentTableViewDelegate?
    var profileDelegate: ProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //initial comment list
        commentItems = Comment.getComments(type!, targetId: self.id)
        CommentController.initCommentTable(tableView)
    }
    
    func refreshDetailEventView(){
        commentItems = Comment.getComments(type!, targetId: id)
        tableView.reloadData()
        var height = tableView.contentSize.height
        delegate?.updateSuperviewHeight(height)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentItems.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var height = tableView.contentSize.height
        delegate?.updateSuperviewHeight(height)
        
        return CommentController.cell(tableView, atIndexPath: indexPath, fromCommentList: commentItems, profileDelegate: profileDelegate)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CommentController.cellHeight(tableView, atIndexPath: indexPath, fromCommentList: commentItems)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CommentController.headerFooterHeight()
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CommentController.headerFooterHeight()
    }
}
