import Foundation

/// Event data model class
class Event {
    var eventId = ""
    var eventTitle = ""
    var eventSummary = ""
    var like = ""
    var join = ""
    var thumbnail = ""
    var date = ""
    var etype = ""
    
    /// Get all events with title bar info
    static func getEvents(eventType: String, byUser: String) -> [String: [Event]] {
        // TODO, support event filter later
        let url = byUser.isEmpty ? Config.eventsEndpoint : Config.userAppliedEventsEndpoint(byUser)
        
        var events: [String: [Event]] = [:]
        var fullEvents = getEvents(url)
        if (fullEvents.isEmpty) {
            return events
        } else if (byUser.isEmpty) {
            let allEvents = "\(fullEvents.count)" + " TCT Events"
            events[allEvents] = fullEvents
        } else {
            let userAppliedEvents = "\(fullEvents.count)" + " Events Applied"
            events[userAppliedEvents] = fullEvents
            
            let registeredURL = Config.userRegisterEventsEndpoint(byUser)
            var registeredEvents = getEvents(registeredURL)
            if (!registeredEvents.isEmpty) {
                let userRegisteredEvents = "\(registeredEvents.count)" + " Events Successfully Registered"
                events[userRegisteredEvents] = registeredEvents
            }
        }
        
        return events
    }
    
    /// Get all events data
    static func getEvents(url: String) -> [Event] {
        let (response, responseError, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "GET")
        
        var events: [Event] = []
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return events
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            // process jsonResult
            if let eventsArray = jsonResult["events"] as? NSArray{
                for e in eventsArray {
                    let event = Event()
                    event.eventId      = Utilities.getStringValue(e, forKey: "eventId")
                    event.eventTitle   = Utilities.getStringValue(e, forKey: "title")
                    // TODO, use description as summary here
                    event.eventSummary = Utilities.getStringValue(e, forKey: "description")
                    event.like         = Utilities.getStringValue(e, forKey: "likeUserCount", withDefault: "0")
                    event.join         = Utilities.getStringValue(e, forKey: "applyingUserCount", withDefault: "0")
                    event.thumbnail    = Utilities.getImagePath(e, forKey: "thumbnail", withDefault: "DefaultThumbnail")
                    event.date         = Utilities.trimDateAsMonthDay(Utilities.getStringValue(e, forKey: "expiration"))
                    event.etype        = Utilities.getStringValue(e, forKey: "category")
                    events.append(event)
                }
            }
        }
        else {
            // couldn't load JSON, look at error
            println("error")
        }
        
        return events
    }
    
    /// Get one specified event
    static func getEvent(eventId: String) -> Event {
        let e = Event()
        
        let url : String = Config.eventsEndpoint + "/" + eventId
        let (response, responseError, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "GET")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return e
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            e.eventId = eventId
            // process jsonResult
            e.eventTitle = Utilities.getStringValue(jsonResult, forKey: "title")
            // TODO, use description as summary here
            e.eventSummary = Utilities.getStringValue(jsonResult, forKey: "description")
            e.like = Utilities.getArraySizeValue(jsonResult, forKey: "likeUsers")
            e.join = Utilities.getArraySizeValue(jsonResult, forKey: "applyingUsers")
            e.thumbnail = Utilities.getImagePath(jsonResult, forKey: "thumbnail", withDefault: "DefaultThumbnail")
            e.date = Utilities.trimDateAsMonthDay(Utilities.getStringValue(jsonResult, forKey: "expiration"))
            e.etype = Utilities.getStringValue(jsonResult, forKey: "category")
        }
        else {
            // couldn't load JSON, look at error
            println("error")
        }
        
        return e
    }
}

/// Event detail data model class
class EventDetail {
    var eventId = ""
    var eventTitle = ""
    var eventDesc = ""
    var category = ""
    var location = ""
    var maxCapacity = ""
    var registerPolicy = ""
    var presenter = ""
    var presenterLogo = ""
    var presenterEmail = ""
    var presenterTitle = ""
    var date = ""
    var like = ""
    var join = ""
    var commentsNum = ""
    var images = ""
    var deadline = ""
    var eSpan = ""
    var applyingUsers: Dictionary<String, String> = [String: String]()
    
    /// Get one specified event detail
    static func getEventDetail(eventId: String) -> EventDetail {
        let e = EventDetail()
        
        let url : String = Config.eventsEndpoint + "/" + eventId
        let (response, responseError, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "GET")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return e
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            e.eventId = eventId
            // process jsonResult
            e.eventId     = Utilities.getStringValue(jsonResult, forKey: "eventId")
            e.eventTitle  = Utilities.getStringValue(jsonResult, forKey: "title")
            e.eventDesc   = Utilities.getStringValue(jsonResult, forKey: "description")
            e.category    = Utilities.getStringValue(jsonResult, forKey: "category")
            e.location    = Utilities.getStringValue(jsonResult, forKey: "location")
            e.maxCapacity = Utilities.getStringValue(jsonResult, forKey: "seats")
            e.registerPolicy = Utilities.getStringValue(jsonResult, forKey: "registerPolicy")
            e.applyingUsers = Utilities.getMapValue(jsonResult, forKey: "applyingUsers")
            
            for (userId, userAvatar) in e.applyingUsers {
                if (userAvatar.isEmpty) {
                    e.applyingUsers[userId] = "default-avatar"
                } else {
                    e.applyingUsers[userId] = Config.imageEndpoint + userAvatar
                }
            }
            
            e.presenter   = Utilities.getStringValue(jsonResult, forKey: "presenter")
            e.presenterLogo
                = Utilities.getImagePath(jsonResult, forKey: "presenterLogo", withDefault: "default-avatar")
            e.presenterEmail
                = Utilities.getStringValue(jsonResult, forKey: "presenterEmail")
            e.presenterTitle
                = Utilities.getStringValue(jsonResult, forKey: "presenterTitle")
            e.date        = Utilities.trimDateAsMonthDay(Utilities.getStringValue(jsonResult, forKey: "expiration"))
            e.like        = Utilities.getArraySizeValue(jsonResult, forKey: "likeUsers")
            e.join        = Utilities.getDictionarySizeValue(jsonResult, forKey: "applyingUsers")
            e.commentsNum = Utilities.getArraySizeValue(jsonResult, forKey: "comments")
            e.deadline    = e.date
            e.images      = Utilities.getImagePath(jsonResult, forKey: "thumbnail", withDefault: "DefaultThumbnail")
            e.eSpan       = Utilities.trimDatesAsTimeSpan(Utilities.getStringValue(jsonResult, forKey: "startTime"), endDate: Utilities.getStringValue(jsonResult, forKey: "endTime"))
        }
        else {
            // couldn't load JSON, look at error
            println("error")
        }
        
        return e
    }
}