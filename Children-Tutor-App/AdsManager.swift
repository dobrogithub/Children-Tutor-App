//
//  AdsManager.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 3/5/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import Foundation
import GoogleMobileAds

var myAdsManager = AdsManager()

class AdsManager : NSObject
{
    let myAdsUnitID = "ca-app-pub-1001745529029765/2301439531"
    let myAppID = " ca-app-pub-1001745529029765~8347973131"
    
    func registerAdMob()
    {
        // need to update this with client's AdMob number
        // update also on the single View Controllers
        GADMobileAds.configure(withApplicationID: myAppID)
    }
}
