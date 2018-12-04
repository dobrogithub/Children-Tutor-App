//
//  QuestionData.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 2/27/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import Foundation

class QuestionData: NSObject
{
    var subjectName: String
    var questionID: String
    var questionText: String
    var answers: NSMutableArray
    var correctAnswer: String
    var explanation: String
    
    var imgURL = URL(string: "")
    var hasImg = false
    
    override init()
    {
        subjectName = ""
        questionID = ""
        questionText = ""
        answers = []
        correctAnswer = ""
        explanation = ""
        
        super.init()
    }
    
    init(questionsInfo: NSDictionary)
    {
        subjectName = String(describing: questionsInfo.object(forKey: "Name")!)
        questionID = String(describing: questionsInfo.object(forKey: "QuestionID")!)
        questionText = String(describing: questionsInfo.object(forKey: "Question")!)
        
        answers = [
            String(describing: questionsInfo.object(forKey: "AnswerA")!),
            String(describing: questionsInfo.object(forKey: "AnswerB")!),
            String(describing: questionsInfo.object(forKey: "AnswerC")!),
            String(describing: questionsInfo.object(forKey: "AnswerD")!)
            ]

        correctAnswer = String(describing: questionsInfo.object(forKey: "CorrectAnswer")!)
        explanation = String(describing: questionsInfo.object(forKey: "CorrectAnswerExplanation")!)
        
        let imgURLstr = String(describing: questionsInfo.object(forKey: "ImageURL")!)
        if imgURLstr != ""
        {
            imgURL = URL(string: imgURLstr)
            hasImg = true
            print(imgURLstr)
        }
        
        super.init()
        
        // debug
        //print("[FROM QUESTION DATA]")
        //printQuestionData()
    }
    
    func printQuestionData()
    {
        print("QUESTION \(questionID)")
        print("-- question characters count \(String("questionText").count) --")
        print("Q: \(questionText)")
        print("-")
        print ("A) \(answers[0])")
        print ("B) \(answers[1])")
        print ("C) \(answers[2])")
        print ("D) \(answers[3])")
        print("-")
        print("Correct answer: \(correctAnswer)")
        print("-")
        print("Explanation: \(explanation)")
        if hasImg
        {
            print("-")
            print("Image URL \(imgURL!)")
        }


    }

}
