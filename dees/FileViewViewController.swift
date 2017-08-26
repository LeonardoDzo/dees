//
//  FileViewViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 17/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FileViewViewController: UIViewController {
    var file: File!
    @IBOutlet weak var webView: UIWebView!
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
        guard let baseURL = URL(string: "\(Constants.ServerApi.fileurl)\(file.path!)") else { return }
        
        let request = URLRequest(url: baseURL)
        let session = URLSession.shared
        
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
