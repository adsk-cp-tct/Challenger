import UIKit

/// Controller for rendering the events UI
class EventTableViewController: BaseSubTabViewController, UITableViewDelegate, UITableViewDataSource {

    var items: [String: [Event]] = [:]
    var eventsCategory: [String] = []
    var eventType = ""
    var byUser = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appdelegate.tableView = self

        var nib = UINib(nibName: "EventCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshEventList"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshEventList()
    }

    func refreshEventList() {
        items = Event.getEvents(eventType, byUser: byUser)
        eventsCategory = items.keys.array
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return eventsCategory.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return eventsCategory[section]
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let title = eventsCategory[section]
        return items[title]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:EventCell = tableView.dequeueReusableCellWithIdentifier("cell") as! EventCell
        let title = eventsCategory[indexPath.section]
        cell.loadEvent(items[title]![indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var v2 = EventDetailViewController(nibName: "EventDetailViewController", bundle: nil)
        let title = eventsCategory[indexPath.section]
        v2.loadEvent(items[title]![indexPath.row].eventId)
        v2.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(v2, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 98
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 53
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
        let header:UILabel = view.subviews[0] as! UILabel
        header.font = UIFont(name: Config.fontFamilyLight, size: 18)
    }

}
