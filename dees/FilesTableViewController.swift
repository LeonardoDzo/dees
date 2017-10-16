//
//  FilesTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MobileCoreServices
import ReSwift
import Whisper

class FilesTableViewController: UITableViewController, UINavigationControllerDelegate {
    var files = [File]()
    var enterprise: Business!
    var user: User!
    var file_type: Int!
    var report: Report!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        let attachBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Attach").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), style: .plain, target: self, action: #selector(self.mySpecialFunction))
        self.navigationItem.rightBarButtonItem = attachBtn
        tableView.tableFooterView = UIView()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "notFiles"))
        imageView.contentMode = .scaleAspectFit
        self.tableView.backgroundView = imageView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return files.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let file = files[indexPath.row]
        cell.textLabel?.text = file.name ?? "Archivo sin nombre"
        cell.imageView?.image = file.getImage()
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        files = report.files.filter({$0.type == file_type})
        var name = file_type != 0 ? "Financiero de " : "Operativo de "
        name.append(user.name!)
        store.subscribe(self){
            $0.select({
                s in s.reportState
            })
        }
        self.navigationItem.titleView = titleNavBarView(title: enterprise.name!, subtitle: name)
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pushToView(view: .webView, sender: (files[indexPath.row], report.eid))
    }
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
}
extension FilesTableViewController:  UIDocumentMenuDelegate,UIDocumentPickerDelegate {
    @available(iOS 8.0, *)
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        
        let cico = url as URL
        print("The Url is : \(cico)")
        let name = cico.absoluteString.components(separatedBy: "/").last?.decodeUrl()
        

        
        let alert = UIAlertController(title: "Nombre del archivo", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (_alert) in
            //Mandar la respuesta
            _ = alert.textFields?[0]
            
            let request = NSURLRequest(url: cico)
            
            let _ = URLSession.shared.dataTask(with: request as URLRequest) { (data, urlResponse, err) in
                
                if err == nil {
                    store.dispatch(ReportsAction.UploadFile(report: self.report, type: self.file_type, data: data!, name: name!))
                } else {
                    print("Hubo un error")
                }
                
                }.resume()
        }))
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nombre del archivo"
            textField.text = name
            textField.isEnabled = false
        }
        
        present(alert, animated: true, completion:nil)
        
        
        
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
        
        
    }
    
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        print("we cancelled")
        
        dismiss(animated: true, completion: nil)
        
        
    }
    @objc func mySpecialFunction(){
        
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeData)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
}
extension FilesTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = ReportState
    
    func newState(state: ReportState) {
        switch state.reports {
            case .Failed(let m as Murmur):
                Whisper.show(whistle: m, action: .show(3.0))
                store.state.reportState.reports = .none
                break
            case .Finished(let tupla as (Report, Murmur)):
                self.files = tupla.0.files.filter({$0.type == file_type})
                self.tableView.reloadData()
                break
            default:
                break
        }
    }
}
