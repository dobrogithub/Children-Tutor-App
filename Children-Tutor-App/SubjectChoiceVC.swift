//
//  SubjectChoiceVC.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 2/14/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SubjectChoiceVC: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate
{
    @IBOutlet var subjectsTable: UITableView!
    @IBOutlet weak var myAdsBanner: GADBannerView!

    var subjectElements = NSMutableArray()
    var lastSelectedSubject = ""
    var nextQuestion = QuestionData()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib. 
        
        subjectsTable.dataSource = self
        subjectsTable.delegate = self
        
        startSpinner(vc: self)
        myBackend.downloadSubjects(closure: setSubjects)
        
        // from https://firebase.google.com/docs/admob/ios/quick-start
        // test
        //myAdsBanner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        // live
        myAdsBanner.adUnitID = myAdsManager.myAdsUnitID
        myAdsBanner.rootViewController = self
        myAdsBanner.delegate = self
        myAdsBanner.load(GADRequest())
    }
    
// --------- SEGUE FUNCTIONS ---------
    
    @IBAction func exitToSubjects(_ segue: UIStoryboardSegue)
    {
        // no need to specify anything. Unwind method set in interface builder
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "pushQuestions"
        {
            let nextQuestionVC = segue.destination as? QuestionsVC
            if nextQuestion.questionID != ""
            {
                nextQuestionVC?.visibleQuestion = nextQuestion
                //nextQuestion.printQuestionData()
            }
            else
            {
                print("Trying to push QuestionsVC without next question preloaded")
            }
        }
    }
 
// ------- AD MOB FUNCTIONS ---------
    
    // both // from https://www.appcoda.com/google-admob-ios-swift/
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("Banner loaded successfully")
        //myBannerView.frame = bannerView.frame
        //myBannerView = bannerView
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("Fail to receive ads")
        print(error)
    }
    
    
    
// ------- TABLE VIEW FUNCTIONS --------
// Following https://makeapppie.com/2016/10/03/introducing-table-views-in-swift-3/
// also good: http://www.codingexplorer.com/getting-started-uitableview-swift/
    
    // Number of sections = 1
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    // Number of rows for each section = number of subjects (dynamic)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return subjectElements.count
    }
    
    // Method populates the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // uses the identifier set in interface builder
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = subjectElements[row] as? String
        cell.textLabel?.font = setDefaultFont()
        
        // If in need of setting a detail label in the row
        /*
        let detailTxt = subjectElements[row] as String
        cell.detailTextLabel?.text = detailTxt
        */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let aCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        let cellText = (aCell.textLabel?.text)! as String
        print(cellText)
        
        lastSelectedSubject = cellText
        
        startSpinner(vc: self)
        myBackend.downloadQuestions(forSubject: cellText as NSString, closure: useQuestions)
     
    }
    
// ------- OTHER METHODS --------
    
    func setSubjects(_ subjects: NSMutableArray)
    {
        stopSpinner(vc: self)
        subjectElements = subjects
        subjectsTable.reloadData()
    }
    
    func useQuestions()
    {
        stopSpinner(vc: self)
        let lastAnsweredQuestionIndex = myStorage.getAnsweredQuestionsIndex(subject: lastSelectedSubject)
        print("Loading questions for \(lastSelectedSubject). Index is \(lastAnsweredQuestionIndex)")
        let nextQ = myStorage.getQuestion(index: lastAnsweredQuestionIndex, subject: lastSelectedSubject)
        
        if nextQ.questionID == ""
        {
            print("Error in retrieving next question")
        }
        else
        {
            nextQuestion = nextQ
        }
        self.performSegue(withIdentifier: "pushQuestions", sender: self)
    }
}

