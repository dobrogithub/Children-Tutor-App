//
//  QuestionsVC.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 2/16/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds


class QuestionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate, UIScrollViewDelegate
{
    @IBOutlet var thisScrollView: UIScrollView!
    
    @IBOutlet var heightViewInScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var myAdsBanner: GADBannerView!
    
    @IBOutlet var subjectLabel: UILabel!
    
    @IBOutlet var questionIDLabel: UILabel!

    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var questionTxtHeight: NSLayoutConstraint!
    @IBOutlet var questionTxtLeft: NSLayoutConstraint!
    @IBOutlet var questionTxtRight: NSLayoutConstraint!
    
    @IBOutlet var answersTable: UITableView!
    @IBOutlet var answersViewHeight: NSLayoutConstraint!
    
    @IBOutlet var textExplanation: UILabel!
    @IBOutlet var textExplanationLabelHeight: NSLayoutConstraint!
    @IBOutlet var textExplanationViewHeight: NSLayoutConstraint!
    
    @IBOutlet var imgExplanation: UIImageView!
    @IBOutlet var imgExplanationViewHeight: NSLayoutConstraint!
    @IBOutlet var imgLoadingSpinner: UIActivityIndicatorView!
    
    //@IBOutlet var imgExplanation: UIImageView!
    @IBOutlet var actionButton: UIButton!
    
    var visibleQuestion = QuestionData()
    
    // used to manage checkmarks on cells of answersTable
    var lastSelectedIndexPath: IndexPath!
    var lastSelectedAnswer = ""
    var lockAnswerSelection = false
    var isGradingQuestion = false
    
    override func viewDidLoad()
    {
        answersTable.dataSource = self
        answersTable.delegate = self
        answersTable.isScrollEnabled = true
        
        // from http://candycode.io/automatically-resizing-uitableviewcells-with-dynamic-text-height-using-auto-layout/
        // THIS TUTORIAL IS THE ONLY ONE THAT WORKS!!!
        answersTable.estimatedRowHeight = 30
        answersTable.rowHeight = UITableView.automaticDimension
        answersTable.setNeedsLayout()
        answersTable.layoutIfNeeded()
        
        answersTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // from https://firebase.google.com/docs/admob/ios/quick-start
        // test
        //myAdsBanner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        // live
        myAdsBanner.adUnitID = myAdsManager.myAdsUnitID
        myAdsBanner.rootViewController = self
        myAdsBanner.delegate = self
        myAdsBanner.load(GADRequest())
        
        thisScrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //printVisibleQuestion()
        self.showNewQuestion()
    }
    
    // to resize TableView based on the height of the cells
    // from http://stackoverflow.com/questions/40079970/how-to-get-height-of-uitableview-when-cells-are-dynamically-sized/40081129#40081129
    override func viewDidLayoutSubviews()
    {
        UIView.animate(withDuration: 0, animations: {
            self.answersTable.layoutIfNeeded()
        }) { (complete) in
            
            // ------ Resizing Table View
            var heightOfTableView: CGFloat = 0.0
            // Get visible cells and sum up their heights
            let cells = self.answersTable.visibleCells
            for cell in cells
            {
                heightOfTableView += cell.frame.height
            }
            // Edit heightOfTableViewConstraint's constant to update height of table view
            self.answersViewHeight.constant = heightOfTableView
            
            // call it here so it knows the height of Answers Table View
            self.adaptScrollViewHeight()
            
            //print("Now question label width is: \(self.questionLabel.frame.width)")
            
            print("scroll view offset is \(self.thisScrollView.contentOffset)")
            //self.thisScrollView.scrollUpOf(points: self.thisScrollView.contentOffset.y)
            
            // ----- End of Resizing Table View
        }
        
        
        UIView.animate(withDuration: 0, animations: {
        self.thisScrollView.layoutIfNeeded()
        }) { (complete) in
            if !self.isGradingQuestion
            {
                self.thisScrollView.scrollToTop()
            }
        }
    }
    
    
// ------- TABLE VIEW FUNCTIONS --------
    // Following https://makeapppie.com/2016/10/03/introducing-table-views-in-swift-3/
    // also good: http://www.codingexplorer.com/getting-started-uitableview-swift/
    
    // Number of sections = 1
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    // Number of rows for each section = number of answers 4
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    // Method populates the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // uses the identifier set in interface builder
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "answerCell",
            for: indexPath)  as UITableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.default
        

        // IMPLEMENTATION WITH CUSTOM CHECKBOX IMAGE AND CUSTOM CELL CLASS
        // fundamental to make it work: point 2 on:
        // http://stackoverflow.com/questions/29812168/could-not-cast-value-of-type-uitableviewcell-to-appname-customcellname
        if let answerCell = cell as? AnswerTableViewCell
        {
            if lastSelectedIndexPath?.row == indexPath.row
            {
                // selected checkbox
                answerCell.checkboxImg.image = UIImage(named: "answer_clicked_1.png")
            }
            else
            {
                // empty checkbox
                answerCell.checkboxImg.image = UIImage(named: "answer_unclicked_1.png")
            }
            
            answerCell.answerTextLbl.numberOfLines = 0
            answerCell.answerTextLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
            answerCell.answerTextLbl.text = visibleQuestion.answers[indexPath.row] as? String
            answerCell.yesnotick.isHidden = true
        }
        else
        {
            print("Unidentified Cell Found")
        }
        
        
        
        // IMPLEMENTATION WITH NATIVE TABLEVIEW CHECKMARKS
        /*
         // comment because I'm chaning the method to return just the font
         //setDefaultFont((cell.textLabel)!)
         
         // allows multiple lines in each cell
         cell.textLabel?.numberOfLines = 0;
         cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
         
         cell.textLabel?.text = visibleQuestion.answers[indexPath.row] as? String
         
         // adds checkmark (works but layout different than expected)
         // from http://stackoverflow.com/questions/26238457/uitableview-swift-checkmark-in-uitableviewcell
         cell.accessoryType = (lastSelectedIndexPath?.row == indexPath.row) ? .checkmark : .none
         */

        
        return cell
    }
    
    
    // adds checkmark - modified to change custom image instead of regular checkmark
    // from http://stackoverflow.com/questions/26238457/uitableview-swift-checkmark-in-uitableviewcell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if lockAnswerSelection == true
        {
            // do nothing. answer selection not active once question has been graded
            if let selectedCell = answersTable.cellForRow(at: indexPath as IndexPath)  as? AnswerTableViewCell
            {
                selectedCell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
        }
        else
        {
            answersTable.deselectRow(at: indexPath as IndexPath, animated: true)
            
            if indexPath.row != lastSelectedIndexPath?.row
            {
                if let lastSelectedIndexPath = lastSelectedIndexPath
                {
                    if let oldCell = tableView.cellForRow(at: lastSelectedIndexPath) as? AnswerTableViewCell
                    {
                        oldCell.checkboxImg.image = UIImage(named: "answer_unclicked_1.png")
                    }
                }
                
                if let newCell = answersTable.cellForRow(at: indexPath as IndexPath)  as? AnswerTableViewCell
                {
                    newCell.checkboxImg.image = UIImage(named: "answer_clicked_1.png")
                }
                
                lastSelectedIndexPath = indexPath
                
                setSelectedAnswer(row: indexPath.row)
            }
        }
    }
    
// -------- SCROLL VIEW FUNCTIONS ------
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        //print(".")
        if (scrollOffset == 0)
        {
            print("We reached the TOP of the scroll view")
        }
        else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            print("We reached the BOTTOM of the scroll view. Offset = \(scrollOffset)")
        }
    }
    
    
// ------------ OTHER STUFF ---------------
    
    func adaptScrollViewHeight()
    {
        // setup height for View in Scroll View PRE answer visualization
        // height questionView + height answersView
        // + height explanationView pre Grade (fixed 30px pre-answer)
        // + height imgExplanationView pre Grade (fixed 20px pre-grade)
        // + fixed height Grade button (70px)
        
        // DEBUGGINH HEIGHTS
        /*
        print("QuestionView height is \(questionTxtHeight.constant)")
        print("AnswersTable height is \(answersViewHeight.constant)")
        print("ExplanationView height is \(textExplanationViewHeight.constant)")
        print("ImgExplanationView height is \(imgExplanationViewHeight.constant)")
        */
        let newScrollHeight = questionTxtHeight.constant
            + answersViewHeight.constant
            + textExplanationViewHeight.constant
            + imgExplanationViewHeight.constant
            + 70.0
        
        // Minimum set to screensize minus Ads Banner View (72px) and Nav bar (50px)
        let minScrollHeight = getScreenHeight() - 72.0 - 50.0
        
        // DEBUGGINH HEIGHTS
        print("The height of imgExplanationView is \(imgExplanationViewHeight.constant)")
        print("OLD scroll height was \(heightViewInScrollView.constant)")
        print("NEW scroll height is \(newScrollHeight)")
        print("MIN scroll height is \(minScrollHeight)")
        
        heightViewInScrollView.constant = max(minScrollHeight, newScrollHeight)
    }
    
    func showNewQuestion()
    {
        // DEBUG NASTY BUG
        //printVisibleQuestion()
        
        subjectLabel.text = visibleQuestion.subjectName
        questionIDLabel.text = visibleQuestion.questionID
        //questionLabel.text = visibleQuestion.questionText

        // from http://stackoverflow.com/questions/28496093/making-text-bold-using-attributed-string-in-swift
        // attributed with Q: bold at the beginning
        var attrStr = NSMutableAttributedString()
        attrStr = attrStr.fontBold("Q: ")
        attrStr = attrStr.fontNormal(visibleQuestion.questionText)
        
        questionLabel.attributedText = attrStr
        
        self.questionTxtLeft.constant = 8.0
        self.questionTxtRight.constant = 8.0
        self.questionTxtHeight.constant = heightForView(label: questionLabel, margin: 8.0)
        
        // if image is shown before the answers (so before clicking Grade) use this
        if visibleQuestion.hasImg
        {
            imgLoadingSpinner.startAnimating()
            imgLoadingSpinner.isHidden = false

            print("Question has img. URL is: \(visibleQuestion.imgURL!)")
            imgExplanationViewHeight.constant = 125.0
            imgExplanation.downloadedFrom(url: visibleQuestion.imgURL!, contentMode: .scaleAspectFit)
            
            //imgExplanation.sizeToFit()
            //downloadImage(url: visibleQuestion.imgURL as URL!, imgView: imgExplanation, vc: self, closure: arrangeImgOnScreen)
            fadeIn(imgExplanation)
        }
        else
        {
            imgLoadingSpinner.stopAnimating()
            imgLoadingSpinner.isHidden = true
        }
        
        adaptScrollViewHeight()
    }
    
    func arrangeImgOnScreen(img: UIImage)
    {
        DispatchQueue.main.async() { () -> Void in
            self.imgExplanation.image = img
            self.imgExplanation.layoutIfNeeded()
        }
    }
    
    @IBAction func gradeAnswer()
    {
        if (lastSelectedIndexPath == nil)
        {
            alertMgr.alertMsgOK(aTitle: "Select an Answer", aBody: "An answer must be selected before clicking the 'Grade' button", vc: self)
        }
        else
        {
            //textExplanation.text = visibleQuestion.explanation
            
            var attrStr = NSMutableAttributedString()
            //attrStr = attrStr.fontBold("Answer: ")
            attrStr = attrStr.fontNormal("Answer: " + visibleQuestion.explanation)
            
            textExplanation.attributedText = attrStr
            textExplanationViewHeight.constant = heightForView(label: textExplanation, margin: 16.0)
            
            // make background of CORRECT answer green
            //if let correctCell = getRightAnswerCell() as UITableViewCell?
            if let correctCell = getRightAnswerCell() as AnswerTableViewCell?
            {
                correctCell.backgroundColor = UIColor(red: 28/255, green: 237/255, blue: 7/255, alpha: 1.0)
                correctCell.yesnotick.image = UIImage(named: "tick_yes.png")
                correctCell.yesnotick.isHidden = false
            }
            
            if (lastSelectedAnswer != visibleQuestion.correctAnswer)
            {
                // If WRONG ANSWER make background of selected answer RED
                //let wrongCell = answersTable.cellForRow(at: lastSelectedIndexPath)! as UITableViewCell
                let wrongCell = answersTable.cellForRow(at: lastSelectedIndexPath)! as! AnswerTableViewCell

                wrongCell.backgroundColor = UIColor(red: 240/255, green: 25/255, blue: 32/255, alpha: 1.0)
                wrongCell.yesnotick.image = UIImage(named: "cross_no.png")
                wrongCell.yesnotick.isHidden = false

            }
            
            // if image has to be at the bottom of the screen use this
            /*
            if visibleQuestion.hasImg
            {
                print("ImgURL is: \(visibleQuestion.imgURL!)")
                imgExplanationViewHeight.constant = 125.0
                imgExplanation.sizeToFit()
                downloadImage(url: visibleQuestion.imgURL as URL!, imgView: imgExplanation, vc: self)
                fadeIn(imgExplanation)
            }
            */
            
            adaptScrollViewHeight()
            gradeToNextQuestionButton()
            saveLastQuestionGraded()
            lockAnswerSelection = true
            isGradingQuestion = true
        }
    }

    @objc func nextQuestion()
    {
        clearCellsBackground()
        
        textExplanation.text = ""
        textExplanationViewHeight.constant = 1.0
        
        imgExplanationViewHeight.constant = 10.0
        imgExplanation.image = nil
        imgLoadingSpinner.stopAnimating()
        imgLoadingSpinner.isHidden = true

        deselectAllCells()
        nextQuestionButtonToGrade()
        
        let index = myStorage.getAnsweredQuestionsIndex(subject: visibleQuestion.subjectName)
        visibleQuestion = myStorage.getQuestion(index: index, subject: visibleQuestion.subjectName)
        
        self.showNewQuestion()
        answersTable.reloadData()
        lockAnswerSelection = false
        isGradingQuestion = false
    }
    
    func setSelectedAnswer(row: Int)
    {
        switch (row) {
        case 0 :
            lastSelectedAnswer = "A"
            break
        case 1:
            lastSelectedAnswer = "B"
            break
        case 2:
            lastSelectedAnswer = "C"
            break
        case 3:
            lastSelectedAnswer = "D"
            break
        default:
            print("weird row selected: \(row)")
        }
        
        //print("last selected answer is: \(lastSelectedAnswer)")
    }
    
    //func getRightAnswerCell() -> UITableViewCell
    func getRightAnswerCell() -> AnswerTableViewCell
    {
        var cell = UITableViewCell()
        var indexNum = 0
        
        switch visibleQuestion.correctAnswer
        {
        case "A":
            indexNum = 0
        case "B":
            indexNum = 1
        case "C":
            indexNum = 2
        case "D":
            indexNum = 3
        default:
            indexNum = 99
        }
        
        if indexNum != 99
        {
            let myIndexPath = IndexPath(row: indexNum, section: 0)
            cell = answersTable.cellForRow(at: myIndexPath)!
        }
        else
        {
            print("weird right answer cell detected")
        }
        return cell as! AnswerTableViewCell
    }
    
    func clearCellsBackground()
    {
        for cell in answersTable.visibleCells
        {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func deselectAllCells()
    {
        for cell in answersTable.visibleCells
        {
            if let answerCell = cell as? AnswerTableViewCell
            {
                answerCell.checkboxImg.image = UIImage(named: "answer_unclicked_1.png")
                answerCell.yesnotick.isHidden = true
                answerCell.yesnotick.image = UIImage()
                
                let index = answersTable.indexPath(for: answerCell)! as IndexPath
                answersTable.deselectRow(at: index, animated: true)
                lastSelectedAnswer = ""
                lastSelectedIndexPath = nil
            }
            else
            {
                print("Found cell not of Answer type")
            }
        }
    }
    
    func saveLastQuestionGraded()
    {
        // OLD METHOD
        // create a localQuestionsAnswered[] storing QuestionsID of answered questions (by subject?)
        //myStorage.saveAnsweredQuestion(question: visibleQuestion)
        
        // NEW METHOD - USE INCREMENTAL INDEX
        myStorage.increaseAnsweredQuestionsIndex(subject: visibleQuestion.subjectName)
    }
    
    func gradeToNextQuestionButton()
    {
        //actionButton.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
        actionButton.setTitle("Next Question", for: UIControl.State.normal)
        actionButton.removeTarget(self, action: #selector(gradeAnswer), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
    }
    
    func nextQuestionButtonToGrade()
    {
        //actionButton.backgroundColor = UIColor(red: 75/255, green: 193/255, blue: 147/255, alpha: 1.0)
        actionButton.setTitle("Grade", for: UIControl.State.normal)
        actionButton.removeTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(gradeAnswer), for: .touchUpInside)
    }
    
    func printVisibleQuestion()
    {
        print("[QUESTION VC]")
        visibleQuestion.printQuestionData()
    }

}
