//
//  ViewController.swift
//  BSBSimulationTest
//
//  Created by Annamalairaj on 18/12/14.
//  Copyright (c) 2014 compname. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        
    
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "CurrentUser")
        
        var error : NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        
        if let results = fetchedResults {
            println(results)
            if(!results.isEmpty) {
                var storyBoard = UIStoryboard(name: "Main", bundle: nil)
                var searchTVC = storyBoard.instantiateViewControllerWithIdentifier("SearchTableController") as SearchTableViewController
                self.navigationController?.pushViewController(searchTVC, animated: false)
            }
            
            
        }
        else {
            println(" Error in fetching objects \(error?.description)")
        }

    }
   
    @IBAction func registerNewUser(sender: AnyObject) {
        
        if(!self.userNameTextField.text.isEmpty && !self.contactNumberTextField.text.isEmpty) {
            self.performSubmit()
        }
        
    }
    func performSubmit() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var entity = NSEntityDescription.entityForName("CurrentUser", inManagedObjectContext: managedContext)
        var employee = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        employee.setValue(self.userNameTextField.text, forKey: "userName")
        employee.setValue(self.contactNumberTextField.text, forKey: "contactNo")
        
        var error : NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        else {
            
            var storyBoard = UIStoryboard(name: "Main", bundle: nil)
            var searchTVC = storyBoard.instantiateViewControllerWithIdentifier("SearchTableController") as SearchTableViewController
            self.navigationController?.pushViewController(searchTVC, animated: true)
        }
        
    }
}

