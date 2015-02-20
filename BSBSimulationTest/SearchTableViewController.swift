//
//  SearchTableViewController.swift
//  BSBSimulationTest
//
//  Created by Annamalairaj on 18/12/14.
//  Copyright (c) 2014 compname. All rights reserved.
//

import UIKit
import CoreData

class SearchTableViewController: UITableViewController, UITableViewDataSource, UISearchBarDelegate, NSURLSessionDelegate, UIScrollViewDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    var data = NSMutableData()
    var searchResult : Array<Dictionary<String,String!>> = Array()
//    var searchResults = [NSManagedObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        self.searchBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchResult.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cellIdentifier =
        var cell = tableView.dequeueReusableCellWithIdentifier("Identifier") as? UITableViewCell
        if(cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Identifier")
            var lableText = UILabel(frame: CGRectMake(60, (54-30)/2, 260, 30))
            lableText.tag = 12
            lableText.textColor = UIColor.blackColor()
            cell?.contentView.addSubview(lableText)

        }
        var newLable = cell?.contentView.viewWithTag(12) as? UILabel
        newLable?.text = self.searchResult[indexPath.row]["title"]
        

        dispatch_async(dispatch_get_main_queue(), {
            var urlPath = self.searchResult[indexPath.row]["imageUrl"] as String!
            var url = NSURL(string: urlPath)
            var imageData = NSData(contentsOfURL: url!)
            var image = UIImage(data: imageData!)
            
            var imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(5, 2, 50, 50)
            cell?.addSubview(imageView)
            
        })
        
    
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54.0
    }

    
    //MARK: - SearchBar Delegate Method
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchText = searchBar.text
        var searchTextApi =  "https://ajax.googleapis.com/ajax/services/search/ images?v=1.0&q=\(searchText)&start=12&rsz=2"
        println("SearchTextApi \(searchTextApi)")
        if(!searchLocalDatabase(searchText)) {
            self.data.length = 0
            self.startConnection()
        }
        
    }
    
    //MARK:- Search local database before
    func searchLocalDatabase(searchString :String) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Searches")
        
        var error : NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        
        if let results = fetchedResults {
            println("results *** \(results)")
            for result in results as [NSManagedObject] {
                println("results *** \(result)")
                var searchText = result.valueForKey("searchText") as String!
                if(searchText == searchString) {
                    //Get the relationship value as mutable set.
                    var searchResults = result.mutableSetValueForKey("results")
                    self.searchResult = []
                    var title :String!
                    var imageUrl : String!
                    var dict : Dictionary<String,String!>
                    for records in searchResults {
                        title = records.valueForKey("title") as String!
                        imageUrl = records.valueForKey("imageUrl") as String!
                        dict = ["title" : title, "imageUrl" : imageUrl]
                        
                        self.searchResult.append(dict)
                    }

                    self.tableView.reloadData()
                    self.searchBar.hidden = true
                    return true
                }
            }
            
            
            
        }
        else {
            println(" Error in fetching objects \(error?.description)")
        }
        return false

    }
    
    //Upload the data with new search text in local db.
    func uploadInLocalDatabase() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var entity = NSEntityDescription.entityForName("Searches", inManagedObjectContext: managedContext)
        var searches = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        searches.setValue(self.searchBar.text, forKey:"searchText")
        
        for searchRslt in self.searchResult {
            
            //Create a new entity description for the relationship.
            var contactInfo = NSEntityDescription.entityForName("SearchResult", inManagedObjectContext: managedContext)
            
            //Set the values into the nsmanagedobject.
            var sResult = NSManagedObject(entity: contactInfo!, insertIntoManagedObjectContext: managedContext)
            sResult.setValue(searchRslt["title"], forKey: "title")
            sResult.setValue(searchRslt["imageUrl"], forKey: "imageUrl")
            //Create an NSSet to set with the relationship's position.
            var contactObject = NSSet(object: sResult)
            searches.setValue(contactObject, forKey: "results")
            var error : NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
        }
        
       
    }
    
    //MARK: - NSURLConnection Delegate Method
    func startConnection(){
        var searchText = searchBar.text
        var searchTextApi =  "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=\(searchText)&start=12&rsz=2"
        var url: NSURL = NSURL(string: searchTextApi)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
        println("data %%% \(data)")
        
    }
    
 
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        println(jsonResult)
        var results = jsonResult.valueForKey("responseData")?.valueForKey("results") as NSArray
        self.searchResult = []
        for result in results {
            var title = results[0].valueForKey("title") as String!
            var imageUrl = results[0].valueForKey("tbUrl") as String!
            var dict = ["title" : title, "imageUrl" : imageUrl]
            self.searchResult.append(dict)
            
        }
        self.uploadInLocalDatabase()
        self.tableView.reloadData()
        self.searchBar.hidden = true
        
        
    }
    
    //MARK: - NSURLConnection Delegate Method
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        println("self.scrollView \(scrollView.contentOffset.y)")
        if(scrollView.contentOffset.y <= -25) {
            self.searchBar.hidden = false
        }
        if(scrollView.contentOffset.y > 100) {
            self.searchBar.hidden = true
        }
    }
    
}
