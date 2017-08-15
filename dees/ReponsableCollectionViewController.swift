//
//  ReponsableCollectionViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 09/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ReponsableCollectionViewController: UICollectionViewController {
    var business: Business!
    var week: Week!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reportSegue" {
            let vc =  segue.destination as! ReportViewController
            vc.user = sender as! User
            vc.business = business
            vc.week = week
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = business.users[indexPath.item]
        if store.state.user.user.rol == .Superior || store.state.user.user.id == user.id{
            self.performSegue(withIdentifier: "reportSegue", sender: user)
        }
        
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return business.users.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ResponsableCollectionViewCell
        let user = business.users[indexPath.item]
        cell.bind(user: user)
        // Configure the cell
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        store.dispatch(GetReportsByEnterpriseAndWeek(eid: business.id, wid: week.id))
    }

}
