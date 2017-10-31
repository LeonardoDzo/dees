//
//  LibraryViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 11/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper

struct file_Section {
    var week : Week!
    var files = [File]()
}


class LibraryViewController: UIViewController {
    var weeks: [Week] = []
    var weekSelected = 0
    var enterpriseSelected = 0
    var enterprises: [Business] = []
    var files = [file_Section]()
    lazy var weeksTitleView : weeksView? = weeksView(frame: .zero)
    let searchController = UISearchController(searchResultsController: nil)
    var filtered = [file_Section]()
    
    @IBOutlet weak var typeSelected: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterpriseLbl: UILabel!
    @IBOutlet weak var enterpriseStack: UIStackView!
    @IBOutlet weak var borderLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        tableView.formatView()
        self.styleNavBarAndTab_1()
        weeks = store.state.weekState.getWeeks()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectEnterprise))
        enterpriseStack.addGestureRecognizer(tap)
        enterpriseStack.isUserInteractionEnabled = true
        tableView.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Buscar Archivo"
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        self.navigationItem.title = "Biblioteca"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
         self.enterprises = store.state.businessState.business.count > 0 ? store.state.businessState.business.first(where: {$0.id == store.state.userState.type})?.business ?? [] : store.state.userState.user.bussiness
        var count = -1
        self.enterprises.enumerated().forEach({
            index, b in
            count += 1
            b.business.enumerated().forEach( {
                i, b1 in
                count += 1
                self.enterprises.insert(b1, at: count)
            })
        })
        
        store.subscribe(self) {
            subcription in
            subcription.select({ (state) in
                state.files
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        changeEnterprise(direction: .down)
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    @IBAction func handleChangeType(_ sender: UISegmentedControl) {
        //var files : store.state.files.get()
        let files = store.state.files.get()
        changeType(files: files)
    }
    func changeType(files: [File]) -> Void {
        var files = files
        if  typeSelected.selectedSegmentIndex == 0 {
            files = files.filter({!$0.isImage()})
        }else{
            files = files.filter({$0.isImage()})
        }
        if !store.state.userState.user.permissions.contains(where: {$0.rid.rawValue > 601 }) {
            files = files.filter({ (file) -> Bool in
                guard let uid = file.uid else{
                    return false
                }
                if store.state.userState.user.id == uid {
                    return true
                }
                return false
            })
        }
        if files.count == 0 {
             let imageView = UIImageView(image: #imageLiteral(resourceName: "emptyback"))
            self.tableView.backgroundView = imageView
            
        }else{
            self.tableView.backgroundView = nil
        }
        self.tableView.backgroundColor = #colorLiteral(red: 0.9589598775, green: 0.9689574838, blue: 0.9729653001, alpha: 1)
        self.files.removeAll()
        files.forEach({ ( file) in
            if let index = self.files.index(where: {$0.week.id == file.wid}) {
                self.files[index].files.append(file)
            }else{
                self.files.append(file_Section(week: weeks.first(where: {$0.id == file.wid}), files: [file]))
            }
        })
        self.tableView.reloadData()
        
    }
}

extension LibraryViewController: EnterpriseProtocol {
    
    
    func tapRight() {
        changeEnterprise(direction: .right)
    }
    
    func tapLeft() {
        changeEnterprise(direction: .left)
    }
    
    func changeEnterprise(direction: UISwipeGestureRecognizerDirection) {
        if direction == .left {
            self.enterpriseSelected  -= enterpriseSelected > 0 ?  1 : 0
        }else if direction == .right{
            self.enterpriseSelected += enterpriseSelected < enterprises.count-1 ? 1 : 0
        }
        self.enterpriseStack.alpha = 0.0
        self.borderLbl.alpha = 0.0
        let e = self.enterprises[self.enterpriseSelected]
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn, animations: {
            self.enterpriseStack.alpha = 1.0
            self.borderLbl.alpha = 1.0
            self.borderLbl.layer.backgroundColor =  UIColor(hexString: "#\(e.color!)ff")?.cgColor
            self.enterpriseLbl.text = e.name
        }, completion: nil)
        store.dispatch(FileActions.get(eid: e.id))
    }
    
    func selectEnterprise() {
        if enterprises.count >  1 {
            self.pushToView(view: .enterprises, sender: 0)
        }
    }
    
}
extension LibraryViewController : StoreSubscriber {
    
    typealias StoreSubscriberStateType = FileState
    
    func newState(state: FileState) {
        switch state.files {
        case .loading:
            
            break
        case .Finished(let tupla as ([File], Murmur)):
            Whisper.show(whistle: tupla.1, action: .show(3.0))
            changeType(files: tupla.0)
        default:
            break
        }
    }
    
}
extension LibraryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
    
        return isFiltering() ? filtered.count : files.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Filter for type
        if isFiltering() {
            return filtered[section].files.count
        }
        return files[section].files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let file  = isFiltering()  ? filtered[indexPath.section].files[indexPath.row] :  files[indexPath.section].files[indexPath.row]
  
        cell.textLabel?.text = file.name
        cell.imageView?.image = file.getImage()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tupla =  isFiltering() ? (filtered[indexPath.section].files[indexPath.row], enterprises[self.enterpriseSelected].id) : (files[indexPath.section].files[indexPath.row], enterprises[self.enterpriseSelected].id)
        self.pushToView(view: .webView, sender:tupla)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Semana " + files[section].week.getTitleOfWeek()
    }
    
    
}
extension LibraryViewController: UISearchResultsUpdating {
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Todas") {
        filtered = files.filter({ (sfile) -> Bool in
            return (sfile.files.contains(where: { (f) -> Bool in
                return f.name!.lowercased().contains(searchText.lowercased())
            }))
        })
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
