//
//  Backend.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 2/20/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import Foundation
import UIKit

/*
 Imported Firebase using
 http://stackoverflow.com/questions/37717889/framework-not-found-firebaseanalytics
 and reinstalling everything after adding to Podfile:
 # Pods for Oasys
 pod ‘Firebase/Core’
 pod ‘Firebase’
 pod 'Firebase/Database'
 */
import Firebase
import FirebaseDatabase

var myBackend = BackendHandler()

class BackendHandler: NSObject
{
    var firebasedb: DatabaseReference!
    
    func initFirebase(_ launchOptions: [AnyHashable: Any]?)
    {
        // Use Firebase library to configure APIs
        // solved error of _OBJC_CLASS_$_FIRApp” with http://stackoverflow.com/questions/37344676/undefined-symbols-for-architecture-armv7-objc-class-firapp
        FirebaseApp.configure()
        self.initFirebaseDB()
    }
    
    func initFirebaseDB()
    {
        // database URL set into Info.plist
        firebasedb = Database.database().reference()
    }
    
    
    
    // DOWNLOADS A DICTIONARY OBJECT (uploaded by GScript as object {} )
    func downloadSubjects2(closure: @escaping (_ subjects: NSMutableArray) -> () )
    {
        let subjects = NSMutableArray()
        
        let subjectsRef = firebasedb.child("Subjects")
        print(subjectsRef.ref)
        
        // filter questions to where the TopicRef is equal to the one provided
        subjectsRef.queryOrderedByPriority().observeSingleEvent(of: .value, with:
            { (snapshot) in
            
            if snapshot.value is NSNull
            {
                print("Load Subjects - none found")
            }
            else
            {
                if let snapDict = snapshot.value as? NSMutableDictionary
                {
                    for subj in snapDict
                    {
                        print(subj.key)
                        subjects.add(subj.key)
                    }
                }
                else
                {
                    print("weird dictionary \(String(describing: snapshot.value))")
                }
            }
            closure(subjects)
        })
    }
    
    // DOWNLOADS AN ARRAY OBJECT (uploaded by GScript as object [] )
    func downloadSubjects(closure: @escaping (_ subjects: NSMutableArray) -> () )
    {
        let subjects = NSMutableArray()
        
        let subjectsRef = firebasedb.child("Subjects")
        print(subjectsRef.ref)
        
        // filter questionsx to where the TopicRef is equal to the one provided
        subjectsRef.observeSingleEvent(of: .value, with:
            { (snapshot) in
                
                if snapshot.value is NSNull
                {
                    print("Load Subjects - none found")
                }
                else
                {
                    if let snapDict = snapshot.value as? NSMutableArray
                    {
                        for subj in snapDict
                        {
                            print(subj)
                            subjects.add(subj)
                        }
                    }
                    else
                    {
                        print("weird dictionary \(String(describing: snapshot.value))")
                    }
                }
                closure(subjects)
        })
    }

        /*
        // from http://stackoverflow.com/questions/39667694/firebase-swift-3-0-syntax-update
        firebasedb.child("Subjects").observeSingleEvent(of : .value, with : {(Snapshot) in
            
            if let snapDict = Snapshot.value as? [String:AnyObject]
            {
                for child in snapDict
                {
                    if let name = snapshot.value["Name"] as? String
                    {
                        print(name)
                        subjects.add(name)
                    }
                }
            }
            else
            {
                print("Fb query Subjects returned an empty snapshot")
            }

            closure(subjects)
        })
        }
            */
    
    
    // KEEP THIS IN ORDER TO REMEMBER WHAT WASN'T WORKING IN FIREBASE DATA RETRIEVE
    // Renamed downloadQuestions2 to avoid confusion
    func downloadQuestions2(forSubject: NSString, closure: @escaping (_ subjects: NSMutableArray) -> () )
    {
        let subjects = NSMutableArray()
        
        let subjectPath = "Questions/"+(forSubject as String)
        print("Downloading questions for subject: " + subjectPath)
        
        print(firebasedb.ref)
        let questionsDB = firebasedb.child("Questions")
        print(questionsDB.ref)
        let subjectQuestionsDB = questionsDB.child(forSubject as String)
        print(subjectQuestionsDB.ref)
        
        
        // from http://stackoverflow.com/questions/39667694/firebase-swift-3-0-syntax-update
        //
        //firebasedb.child(subjectPath).observeSingleEvent(of : .value, with : {(snapshot) in
        //firebasedb.child("Questions").observeSingleEvent(of : .value, with : {(Snapshot) in
        
        subjectQuestionsDB.observeSingleEvent(of : .value, with : {(snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value!.count)
            // ALWAYS EMPTY!!! NEED TO ADD queryOrdered(byChild: ) AND queryEqual(toValue: ) otherwise returns empty
            
            if let snapDict = snapshot.value as? [String:AnyObject]
            {
                for child in snapDict
                {
                    if let element = child.value as? NSMutableArray
                    {
                        print(element)
                    }
                }
            }
            else
            {
                print("Fb query Questions returned an empty snapshot")
            }
            closure(subjects)
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    // from the unanswered question on starkoverflow http://stackoverflow.com/questions/41339864/access-nested-data-using-firebase-in-swift-3
    
    func downloadQuestions(forSubject: NSString, closure: @escaping () -> () )
    {
        var questions = NSMutableArray()
        // point at the database
        let questionsRef = firebasedb.child("Questions").child(forSubject as String)
        print(questionsRef.ref)
        
        // filter questions to where the TopicRef is equal to the one provided
        questionsRef.queryOrdered(byChild: "Name").queryEqual(toValue: forSubject as String).observeSingleEvent(of: .value, with:  { (snapshot) in
            
            if snapshot.value is NSNull
            {
                print("Load Questions - none found")
            }
            else
            {
                let snapDict = snapshot.value as! NSMutableArray
                //print("FOUND QUESTIONS! FIRST ONE IS:\n\(snapDict[0])")
                questions = snapDict
            }
            // OLD METHOD
            //myStorage.setLocalQuestions(questions: questions)
            
            //NEW METHOD
            myStorage.saveQuestions(questions)
            closure()
        })
    }


}
