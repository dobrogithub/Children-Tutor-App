//
//  LocalData.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 2/16/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import Foundation
import CoreLocation

var myStorage = LocalData()

class LocalData: NSObject
{
    var myData: UserDefaults = UserDefaults.standard

    // methods to store and load data in the phone App
    
    
    // ------- LOCAL QUESTIONS DATABASE ----------

    func saveQuestions(_ questions: NSArray)
    {
        print("saving " + String(questions.count) + " in local storage")
        
        let aQuestion = questions[0] as! NSDictionary
        let subject = aQuestion.object(forKey: "Name") as! String
        
        let debugQuestion = QuestionData(questionsInfo: aQuestion)
        debugQuestion.printQuestionData()
        
        // saving questions under Subject name
        let encodedArray : NSData = NSKeyedArchiver.archivedData(withRootObject: questions) as NSData
        myData.setValue(encodedArray, forKey:("questionsDB-"+subject))
    }
    
    func getAllQuestions(_ forSubject: String) -> NSArray
    {
        if myData.data(forKey: ("questionsDB-"+forSubject)) != nil
        {
            let encodedArray = myData.data(forKey: ("questionsDB-"+forSubject))
            let questionsArray = NSKeyedUnarchiver.unarchiveObject(with: encodedArray!) as AnyObject
            
            if let arr = questionsArray as? NSArray
            {
                //print("getting questions array info \(String(describing: arr[0]))")
                print("getting questions array info")
                return arr
            }
            else
            {
                print("getting questions array info: UNREADABLE")
                return ["empty"]
            }
        }
        else
        {
            print("getting questions array info: EMPTY")
            return ["empty"]
        }
    }
    
    // ------- ANSWERED QUESTIONS IDs ----------
    
    func increaseAnsweredQuestionsIndex(subject: String)
    {
        var i = getAnsweredQuestionsIndex(subject: subject) 
        i += 1
        
        print("New index for subject \(subject) is \(i)")
        print("Questions count for subject \(subject) is \(getAllQuestions(subject).count)")
        
        // if all the answers of that category have been answered start from 0
        if i >= getAllQuestions(subject).count
        {
            print("WARNING: Reached total number of questions answered. Setting index to 0")
            i = 0
        }

        myData.setValue(i, forKey: ("answeredQuestionsIndex-"+subject))
    }
    
    func resetAnsweredQuestionsIndex(subject: String)
    {
        myData.setValue(0, forKey: ("answeredQuestionsIndex-"+subject))
    }
    
    func getAnsweredQuestionsIndex(subject: String) -> Int
    {
        if let i = myData.value(forKey: ("answeredQuestionsIndex-"+subject)) as? Int
        {
            return i
        }
        else
        {
            print("No questions answered on \(subject) yet. Index is 0")
            return 0
        }
    }
    
    func getQuestion(index: Int, subject: String) -> QuestionData
    {
        let questions = getAllQuestions(subject) as NSArray
        if index >= questions.count
        {
            print("WARNING: Questions count for \(subject) changed. Resetting index to 0")
            resetAnsweredQuestionsIndex(subject: subject)
            return QuestionData(questionsInfo: questions[0] as! NSDictionary)
        }
        else
        {
            if questions[index] is NSDictionary
            {
                return QuestionData(questionsInfo: questions[index] as! NSDictionary)
            }
            else
            {
                print("Did not find a question for subject \(subject) at index \(index)")
                return QuestionData()
            }
        }
    }
    
    
    // ------- OLD METHOD - COMPARE LOCAL QUESTIONS WITH ANSWERED QUESTIONS -------
    /*
    
    // OLD METHOD FOR QUESTIONS IN RANDOM ORDER
    func saveAnsweredQuestion(question: QuestionData)
    {
        print("Saving answered question w code: \(question.questionID!)")
        var qArray = getAnsweredQuestions() as NSMutableArray
        if (qArray[0] as! String) == "empty"
        {
            // create a local file for answered questions
            qArray = [question.questionID]
        }
        else
        {
            // make sure the question is not already stored
            var isAlreadySaved = false
            for q in qArray
            {
                let qStr = q as! String
                if qStr == question.questionID
                {
                    isAlreadySaved = true
                }
            }
            if !isAlreadySaved
            {
                qArray.add(question.questionID)
            }
        }
        //printAnsweredQuestions(qArray: qArray)
        
        let encodedArray : NSData = NSKeyedArchiver.archivedData(withRootObject: qArray) as NSData
        
        //Saving from http://stackoverflow.com/questions/19634426/how-to-save-nsmutablearray-in-nsuserdefaults
        myData.setValue(encodedArray, forKey:"answeredQuestions")
    }
    
    // OLD METHOD
    func getAnsweredQuestions() -> NSMutableArray
    {
        //Checking if the data exists
        // from http://stackoverflow.com/questions/28240848/how-to-save-an-array-of-objects-to-nsuserdefault-with-swift
        if myData.data(forKey: "answeredQuestions") != nil
        {
            //Getting Encoded Array
            let encodedArray = myData.data(forKey: "answeredQuestions")
            //Decoding the Array
            let answeredQuestions = NSKeyedUnarchiver.unarchiveObject(with: encodedArray!) as AnyObject

            if let aQuestArray = answeredQuestions as? NSMutableArray
            {
                print("Retrieved \(aQuestArray.count) answered questions")
                //printAnsweredQuestions(qArray: aQuestArray)
                return aQuestArray
            }
            else
            {
                print("Answered questions file found but not readable")
                return ["empty"]
            }
        }
        else
        {
            print("Local file for answered questions not found")
            return ["empty"]
        }
    }
    
    // OLD METHOD
    func printAnsweredQuestions(qArray: NSArray)
    {
        for questionID in qArray
        {
            print(questionID)
        }
    }
    
    func getNextUnansweredQuestion() -> QuestionData
    {
        let localQuestions = myStorage.getLocalQuestions()
        
        if localQuestions.count == 0
        {
            print("No questions returned from backend")
        }
        else
        {
            let answeredQuestions = myStorage.getAnsweredQuestions()
            
            // pick the first question not answered before
            //var aQuestion: QuestionData
            for q in localQuestions
            {
                let qCheck = QuestionData(questionsInfo: q as! NSDictionary)
                print("Checking Local Questions for Subject: \(qCheck.subjectName!)")
                var found = false
                for a in answeredQuestions
                {
                    let aCheckStr = a as! String
                    let qCheckStr = qCheck.questionID!
                    print("Checking new question \(qCheckStr) vs answered one \(aCheckStr)")
                    if qCheckStr == aCheckStr
                    {
                        found = false
                        // stop checking the IDs of answered questions because it already found the matching one
                        break
                    }
                    else
                    {
                        // if ID doesn't match the local one sets found to true but keeps checking IDs of answered to turn it back to false in case a match is found
                        found = true
                    }
                }
                if found == true
                {
                    // stops iterating the local questions since it already found one that doesn't have a match in the answered ones
                    return qCheck
                }
            }
        }
        return QuestionData()
    }
    */
}
