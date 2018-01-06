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
    var baseURL : URL!
    var data: Data!
    @IBOutlet var webView: WKWebView!
    var url : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        setupBack()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if url != nil {
            baseURL = URL(string:Constants.ServerApi.url+self.url )
        }else{
            baseURL = URL(string: "\(Constants.ServerApi.url)companies/\(eid!)/res/reports/\(file.fid!)/files/\(file.id!)")
        }
        
        
        var request = URLRequest(url: baseURL)
        let session = URLSession.shared
        
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                self.data = data
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))
                self.webView.load(request)
            }else{
                print("ERROR",error!)
            }
        }
        task.resume()
    }
    
    @objc func share() -> Void {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let name = self.file != nil ? self.file.name ?? "Sin nombre" : "PDF"
            let fileUrl = documentDirectory.appendingPathComponent(name)
            try data?.write(to: fileUrl)
            let sharedObjects:[AnyObject] = [fileUrl as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: {
            })
        } catch {
            print(error)
        }
        
        
    }
}
