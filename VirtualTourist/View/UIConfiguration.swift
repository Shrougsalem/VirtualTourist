//
//  UIConfiguration.swift
//  VirtualTourist
//
//  Created by Shroog Salem on 26/12/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//
//

import Foundation
import UIKit

fileprivate var activityView: UIView?

extension UIViewController {
    
    //MARK: - Activity Indicator Adjustments
    func showSpinner() {
        activityView = UIView(frame: self.view.bounds)
        activityView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.center=activityView!.center
        ai.startAnimating()
        activityView?.addSubview(ai)
        self.view.addSubview(activityView!)
    }
    
    func removeSpinner() {
        DispatchQueue.main.async{
            activityView?.removeFromSuperview()
            activityView = nil
        }
    }
    
    //MARK: - Alert
    func alert (title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
