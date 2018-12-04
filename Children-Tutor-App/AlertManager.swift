//
//  AlertManager.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 2/16/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import Foundation
import UIKit
var alertMgr = AlertManager()

class AlertManager: NSObject
{
    func alertMsgOK(aTitle: NSString, aBody: NSString, vc: UIViewController) {
        let alertController = UIAlertController(
            title: aTitle as String,
            message: aBody as String,
            preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}
