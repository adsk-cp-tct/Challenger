import UIKit

/// Controller for rendering ideas UI
class IdeaTableViewController: BaseSubTabViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items: [Idea] = []
    var byUser = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent scroll the table view horizontally
        tableView.alwaysBounceHorizontal = false
        
        var nib = UINib(nibName: "IdeaCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshIdeaList"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshIdeaList()
    }
    
    func refreshIdeaList() {
        items = Idea.getIdeas(byUser)
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:IdeaCell = tableView.dequeueReusableCellWithIdentifier("cell") as! IdeaCell
        cell.loadIdea(self.items[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var ideaDetail = IdeaDetailViewController(nibName: "IdeaDetailViewController", bundle: nil)
        ideaDetail.loadIdea(self.items[indexPath.row].id)
        ideaDetail.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(ideaDetail, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 98
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return byUser.isEmpty ? 53 : 0.1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return byUser.isEmpty ? String(items.count) + " Ideas" : ""
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var label = UILabel();
        label.frame = CGRectMake(0, 0, tableView.frame.width, 50)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        var headerView = UIView();
        headerView.backgroundColor = Config.baseBackgroundColor
        headerView.addSubview(label)
        return headerView
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if (byUser.isEmpty) {
            let header:UILabel = view.subviews[0] as! UILabel
            header.font = UIFont(name: Config.fontFamilyLight, size: 18)
        }
    }
}
