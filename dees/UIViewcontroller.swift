//
//  UIViewcontroller.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self as? UIGestureRecognizerDelegate
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func setupBack() -> Void {
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back3))
        self.navigationItem.leftBarButtonItem = backBtn
    }
    func alertMessage(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    func back3() -> Void {
        _ = navigationController?.popViewController(animated: true)
    }
    func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func styleNavBarAndTab_1() {
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1215686275, green: 0.6901960784, blue: 0.9882352941, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func keyboardWillHide(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
