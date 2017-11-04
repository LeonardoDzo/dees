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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func setupBack() -> Void {
        var backBtn :UIBarButtonItem!
        if let _ = self.navigationController {
            backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back3))
        } else {
            backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
        }
      
        self.navigationItem.leftBarButtonItem = backBtn
    }
    func alertMessage(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func back3() -> Void {
        if let value = navigationController?.popViewController(animated: true) {
            print(value)
        }else{
             self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func back() -> Void {
        
        self.dismiss(animated: true, completion: nil)
    }
    @objc func keyboardWillShow(notification: Notification){
        print(self.view.frame.origin.y)
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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
    
    @objc func keyboardWillHide(notification: Notification){
        self.view.setNeedsDisplay()
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

extension UIViewController {
    
    func popToView(view: RoutingDestination, sender: Any? = nil) -> Void {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        switch viewcontroller {
        case let vc as AllReportsTableViewController:
            if sender is Int {
               vc.weekSelected = sender as! Int
            }
            break
        default:
            return
        }
        
        self.navigationController?.popToViewController(viewcontroller, animated: true)
    }
    
    func pushToView(view: RoutingDestination, sender: Any? = nil) -> Void {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        
        switch viewcontroller {
        case _ as WeeksTableViewController:
            break
        case let vc as EnterprisesTableViewController:
            if sender is Bool {
                 vc.isFocus = sender as! Bool
            }
            break
        case let vc as AllReportsTableViewController:
            if sender is Business {
                vc.enterprises = [sender as! Business]
            }
            break
        case let vc as AllPendingsTableViewController:
            if sender is [pendingModel] {
                vc.pendings = sender as! [pendingModel]
            }
            break
        case let vc as ChatViewController:
            if sender is configuration {
                vc.conf = sender as! configuration
            }
            break
        case let vc as ResponsableTableViewController:
            if sender is configuration {
                vc.conf = sender as! configuration
            }
            break
        case let vc as FileViewViewController:
            if let tupla = sender as? (File, Int) {
                vc.file = tupla.0
                vc.eid = tupla.1
            }
            break
        case let vc as FilesTableViewController:
            if sender is configuration {
                vc.conf = sender as! configuration
            }
        default:
           break
        }
        
        
        if let nav = self.navigationController {
            nav.pushViewController(viewcontroller, animated: true)
        }else{
            let targetViewController = viewcontroller // this is that controller, that you want to be embedded in navigation controller
            let targetNavigationController = UINavigationController(rootViewController: targetViewController)
            
            self.present(targetNavigationController, animated: true, completion: nil)
        }
        
    }
    
}
