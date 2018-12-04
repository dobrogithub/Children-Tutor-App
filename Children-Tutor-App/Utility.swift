//
//  Utility.swift
//  CA_Real Estate Agent_Exam
//
//  Created by Paolo Dobrowolny on 2/16/17.
//  Copyright © 2017 MonkeyParking. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

// ---- VISUAL STUFF

func fadeIn(_ aView: UIView)
{
    aView.alpha = 0.0
    aView.isHidden = false
    UIView.animate(withDuration: 0.5, animations:
        {
            aView.alpha = 1.0
    })
}

func fadeOut(_ aView: UIView)
{
    aView.alpha = 1.0
    aView.isHidden = false
    UIView.animate(withDuration: 0.5, animations:
        {
            aView.alpha = 0.0
    })
}

func getScreenWitdh() -> CGFloat
{
    let screenSize: CGRect = UIScreen.main.bounds
    return screenSize.width as CGFloat
}

func getScreenHeight() -> CGFloat
{
    let screenSize: CGRect = UIScreen.main.bounds
    return screenSize.height as CGFloat
}

func heightForView(label: UILabel, margin: CGFloat) -> CGFloat
{
    // get screen size and adapt label width to that size before calling sizeToFit()
    //print("Fitting label \(label.text?.substring(to: (label.text?.index((label.text?.startIndex)!, offsetBy: 5))!))")
    //print("label width START: \(label.frame.width)")
    //print("screen width: \(getScreenWitdh())")
    //print("label width based on screen: \(screenWidth-2*margin)")
    
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.frame = CGRect(x: 0, y: 0, width: (getScreenWitdh() - 2*margin), height: label.frame.height)
    
    //print("label width BEFORE SIZE TO FIT: \(label.frame.width)")
    label.sizeToFit()

    //print("label width AFTER SIZE TO FIT: \(label.frame.width)")
    
    // add 4*margin to leave some space at the top and buttom
    return (label.frame.height + 2*margin)
}

func setDefaultFont() -> UIFont
{
    // Font name on Xcode 
    /*
     Comic Sans MS:
     == ComicSansMS
     == ComicSansMS-Bold
     */

    if let font = UIFont(name: "ComicSansMS", size: 20)
    {
        return font
    }
    else
    {
        return UIFont()
    }
}

func startSpinner(vc aVc: UIViewController)
{
    let loading = MBProgressHUD.showAdded(to: aVc.view, animated: true)
    loading?.mode = MBProgressHUDModeIndeterminate
    delay(20.0, closure: {stopSpinner(vc: aVc)})
}

func stopSpinner(vc aVC: UIViewController)
{
    MBProgressHUD.hide(for: aVC.view, animated: true)
}

// ----- DELAY FUNCTIONS -------

func delay(_ delay: Double, closure: @escaping ()->())
{
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

// ------ IMG DOWNLOAD FUNCTIONS --------

// still form http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView
{
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit)
    {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit)
    {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}


/*
// from http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
func downloadImage(url: URL, imgView: UIImageView, vc: UIViewController, closure: @escaping (UIImage) -> ())
{
    print("Download Img Started at URL: \(url)")
    //startSpinner(vc: vc)
    getDataFromUrl(url: url) { (data, response, error)  in
        guard let data = data, error == nil else
        {
            print("error downloading: \(error?.localizedDescription)")
            return
        }
        print("Retrieved Img name\(response?.suggestedFilename ?? url.lastPathComponent)")
        print("Download Finished")
        
        closure(UIImage(data: data)!)
        
        /*
        DispatchQueue.main.async() { () -> Void in
            imgView.image = UIImage(data: data)
            print("The height of imgView from download file is \(imgView.frame.height)")
            print("The image of imgView from downalod File is \(imgView.image?.size.width) x \(imgView.image?.size.height)")
            //stopSpinner(vc: vc)
        }
        */
    }
}
*/

// from http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void)
{
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
        }.resume()
}

// ----- FONT STUFF --------

// from http://stackoverflow.com/questions/28496093/making-text-bold-using-attributed-string-in-swift
extension NSMutableAttributedString
{
    func fontBold(_ text:String) -> NSMutableAttributedString
    {
        let attrs:[String:AnyObject] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont (name: "HelveticaNeue-Bold", size: 17)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:convertToOptionalNSAttributedStringKeyDictionary(attrs))
        self.append(boldString)
        return self
    }
    
    func fontNormal(_ text:String)->NSMutableAttributedString
    {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}

// ------ SCROLL VIEW STUFF -----

// from http://stackoverflow.com/questions/9450302/get-uiscrollview-to-scroll-to-the-top
extension UIScrollView
{
    func scrollToTop()
    {
        print("About to scroll for \(contentInset.top) points")
        
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
    
    func scrollUpOf(points: CGFloat)
    {
        print("About to scroll for \(points) points")
        let desiredOffset = CGPoint(x: 0, y: -points)
        setContentOffset(desiredOffset, animated: true)
        
    }
}

// -------- ADMIN TOOLS ------

func printFontNames()
{
    for family: String in UIFont.familyNames
    {
        print("\(family)")
        for names: String in UIFont.fontNames(forFamilyName: family)
        {
            print("== \(names)")
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
