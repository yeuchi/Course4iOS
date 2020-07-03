import Foundation


// Use this String extension method to encode a string to be passed in a URL request.
// When sending a string as a parameter in a URL query, you must replace certain characters with escape sequences.
// This function will return a string that is safe to embed in a URL query.
// It will escape any non-alphanumeric characters, except for the specified exceptions.

extension String {
    func encodedStringForURLEncodedFormData() -> String? {
        let exceptions = "*-._"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: exceptions)
        
        //allowed.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        //return stringByAddingPercentEncodingWithAllowedCharacters(allowed)
        /* need to figure out what this is about*/
        return ""
    }
}

// Use this class to communicate with the Yelp Fusion API.
// Create instances of this class using the connectClient factory method.
// Our sample implementation has one instance method that lets you use Yelp's Location Search.
// You can find more APIs by browsing Yelp's documentation. 
// Use the locationSearch function as a guide on constructing a request and parsing the returned data.

class YelpAPIClient {
    
    private var accessToken: String
    
    static let AuthURL = "https://api.yelp.com/oauth2/token"
    static let SearchURL = "https://api.yelp.com/v3/businesses/search"
    
    enum YelpAPIClientError: Int {
        case URLFormattingError
        case JSONFormatError
        case TokenResponseMissing
        case StringEncodingError
        case MissingData
    }
    
    // Note: An access token must be requested from Yelp using the connectClient class function.
    init(token: String) {
        accessToken = token
    }
    
    // Requests an access token and returns a new instance of YelpAPIClient.
    static func connectClient (id: String, secret: String, completion: (YelpAPIClient?, NSError?) -> Void) {
        
        let requestString = "\(AuthURL)?grant_type=client_credentials&client_id=\(id.encodedStringForURLEncodedFormData()!)&client_secret=\(secret.encodedStringForURLEncodedFormData()!)"
        
        guard let requestURL = NSURL(string: requestString)
            
            else {
                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.URLFormattingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "URL Formatting Error"])
            
                /*DispatchQueue.main.async {
                    completion(nil, error)
                }*/
            return
        }
        
        /*
         * HTTP POST request
         * https://www.appsdeveloperblog.com/http-post-request-example-in-swift/
         */
        
        var request = URLRequest(url: requestURL as URL)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            /*(guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(nil, error)
                })
                return
            }*/
 
             if let error = error {
                print("Error took place \(error)")
                return
             }
            
            if let jsonData = data, let dataString = String(data: jsonData, encoding: .utf8){
                guard let json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? Dictionary<String, AnyObject>
                    else
                {
                    print("Failed to parse jsonData")
                    /*
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "YelpAPIClient", code: YelpAPIClientError.JSONFormatError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient could not decode json response."]))
                    }*/
                return
            }
          /*
            guard let jsonData = data else {
                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.MissingData.rawValue, userInfo: [NSLocalizedDescriptionKey:"YelpAPIClient server response did not include any data."])
                dispatch_async(dispatch_get_main_queue(), {
                    completion(nil, error)
                })
                return
            }
            
            
            }*/
            
            guard let accessToken = json["access_token"] as? String
                else {
                /*
                    DispatchQueue.main.async {
                    completion(nil, NSError(domain: "YelpAPIClient", code: YelpAPIClientError.TokenResponseMissing.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient token missing from response."]))
                }*/
                return
            }
            
            /*DispatchQueue.main.async {
                completion(YelpAPIClient(token: accessToken), nil)
            }*/
            YelpAPIClient(token: accessToken)
            
            
            }
        }
        task.resume()
        
    }
    
    // Search near a particular location using the Location Search API.
    // See here for all possible parameters: https://www.yelp.ca/developers/documentation/v3/business_search
    
    func locationSearch(term: String, location: String, completion: (AnyObject?, NSError?)->Void) {
        
        // Note how calls to our completion block are wrapped in 'dispatch_async(dispatch_get_main_queue()) {}'.
        // This is necessary to ensure the completion block is called on the main queue. Only code on the main queue
        // may update user interface elements, call Cocoa APIs, etc.
        // It's also done to ensure the completion block is not called before this function returns, in case
        // the user of this function doesn't expect that to happen.
        
        // Encode the search strings before embedding them in the url.
        guard let encodedTerm = term.encodedStringForURLEncodedFormData() else {
            let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.StringEncodingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient string encoding error."])
            /*
            DispatchQueue.main.async {
                completion(nil, error)
            }*/
            return
        }
        
        guard let encodedLocation = location.encodedStringForURLEncodedFormData() else {
            let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.StringEncodingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient string encoding error."])
            /*
            DispatchQueue.main.async {
                completion(nil, error)
            }*/
            return
        }
        
        // Construct the full url including parameters.
        let requestString = "\(YelpAPIClient.SearchURL)?term=\(encodedTerm)&location=\(encodedLocation)"
        guard let requestURL = NSURL(string: requestString) else {
            let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.URLFormattingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "URL Formatting Error"])
            /*
            DispatchQueue.main.async {
                completion(nil, error)
            }*/
            return
        }
        
        // Create the URL request. Note we need to include the current access token as an HTTP header field value.
        var request = URLRequest(url: requestURL as URL)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Send the network data task.
        // Don't forget to call resume() on the new data task!
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        //NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil
                else {
                /*
                    DispatchQueue.main.async  {
                    completion(nil, error as NSError?)
                }*/
                return
            }
            
            // Make sure some data was returned.
            guard let jsonData = data else {
                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.MissingData.rawValue, userInfo: [NSLocalizedDescriptionKey:"YelpAPIClient server response did not include any data."])
                /*
                DispatchQueue.main.async {
                    completion(nil, error)
                }*/
                return
            }
            
            // Parse the raw text data into an object.
            guard let json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? Dictionary<String,AnyObject> else {
                let error = NSError(domain: "YelpAPIClient", code: YelpAPIClientError.JSONFormatError.rawValue, userInfo: [NSLocalizedDescriptionKey: "YelpAPIClient could not decode json response."])
                /*
                DispatchQueue.main.async {
                    completion(nil, error)
                }*/
                return
            }
            
            // Return the JSON object if everything is ok.
            /*
            DispatchQueue.main.async {
                completion(json as AnyObject, nil)
            }*/  
        }
        task.resume()
        
        
    }
    
}
