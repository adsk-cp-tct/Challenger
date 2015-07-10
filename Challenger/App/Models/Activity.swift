import Foundation

/// Activity data model class
class Activity {
    var id = ""
    var subject = ""
    var verb = ""
    var obj = ""
    var objType = ""
    var objId = ""
    var data = ""
    var createdTime = ""
    var creator = ""
    
    /// Get activities data
    static func getActivities()->[Activity]{
        let url:String = Config.activityEndpoint
        
        let (response,responseError,responseContent) = HttpRequest.sendSynchronousRequest(url, method: "Get")
        
        var activities:[Activity]=[]
        let statusCode=(response as? NSHTTPURLResponse)?.statusCode ?? -1
        
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return activities
        }
        
        if let jsonResult=Utilities.parsedNSDataToDictionary(responseContent!){
            if let activitiesArray=jsonResult["activities"] as? NSArray{
                for a in activitiesArray{
                    let activity = Activity()
                    activity.id         = Utilities.getStringValue(a, forKey:"id")
                    activity.subject    = Utilities.getStringValue(a, forKey:"subject")
                    activity.verb       = Utilities.getStringValue(a, forKey:"verb")
                    activity.obj        = Utilities.getStringValue(a, forKey:"obj")
                    activity.objType    = Utilities.getStringValue(a, forKey:"objType")
                    activity.objId      = Utilities.getStringValue(a, forKey:"objectId")
                    activity.data       = Utilities.getStringValue(a, forKey:"data")
                    activity.createdTime = Utilities.trimDateInSlashStyle(Utilities.getStringValue(a, forKey:"createdTime"))
                    activity.creator    = Utilities.getStringValue(a, forKey:"creator")
                    activities.append(activity)
                }
            }
        }
        else
        {
            
            println("error")
        }
        
        return activities
    }
}