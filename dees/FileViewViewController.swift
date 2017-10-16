//
//  FileViewViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 17/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import WebKit

class FileViewViewController: UIViewController {
    var file: File!
    var eid : Int!
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBack()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        guard let baseURL = URL(string: "\(Constants.ServerApi.url)companies/\(eid!)/res/reports/\(file.fid!)/files/\(file.id!)") else { return }
    
        var request = URLRequest(url: baseURL)
        let session = URLSession.shared
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                self.webView.loadRequest(request)
            }else{
                print("ERROR",error!)
            }
        }
        task.resume()
    }
}
