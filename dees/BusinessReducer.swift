//
//  businessRecorder.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire
import Moya
import Mapper
let businessProvider = MoyaProvider<EnterpriseService>(plugins: [authPlugin])

struct BusinessReducer {
    func handleAction(action: Action, state: BusinessState?) -> BusinessState {
        var state = state ?? BusinessState(business: [], status: .none)
        switch action {
        case let action as baction.Get:
            if token != "" {
                state.status = .loading
                getEnterprise(id: action.id)
            }
            break
        case is wAction.Get:
            if !token.isEmpty {
                state.status = .loading
            }
            break
        case let action as baction.AddUser:
            if action.bid != nil {
                state.status = .loading
                addUser(of: action.bid, uid: action.uid)
            }
            break
        case let action as baction.DeleteUser:
            if action.bid != nil {
                state.status = .loading
                deleteUser(of: action.bid, uid: action.uid)
            }
            break
        case let action as baction.Put:
            if action.enterprise != nil {
                state.status = .loading
                putEnterprise(ent: action.enterprise)
            }
        case let action as baction.Create:
            if action.e != nil {
                state.status = .loading
                postEnterprise(ent: action.e)
            }
            break
        case let action as baction.Delete:
            if action.id != nil {
                state.status = .loading
                delete(eid: action.id)
            }
            break
        default:
            break
        }
        return state
    }
    
    func getEnterprise(id: Int) -> Void {
        if id == -1 {
            businessProvider.request(.getAll, completion: {
                result in
                switch result {
                case .success(let response):
                    do {
                        let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                        let array : NSArray = repos.value(forKey: "enterprises") as! NSArray
                        
                        var enterprises = Business.from(array) ?? []
                        enterprises.enumerated().forEach({i,b in
                            b.business.enumerated().forEach({ i2,b2 in
                                enterprises[i].business[i2].color = b.color
                            })
                        })
                        store.state.businessState.business = enterprises
                        store.state.businessState.status = .none
                    } catch MoyaError.jsonMapping(let error) {
                        print(error )
                    } catch {
                        print(":(")
                    }
                    
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            })
        }else{
            businessProvider.request(.get(id: id), completion: {
                result in
                switch result {
                case .success(let response):
                    do {
                        let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                        let array : NSArray = repos.value(forKey: "companies") as! NSArray
                        var enterprises = Business.from(array) ?? []
                        
                        enterprises.enumerated().forEach({i,b in
                            if b.id == id {
                                enterprises[i].business = enterprises.filter({$0.parentId == id})
                                return
                            }
                        })
                        enterprises.first(where: {$0.id == id})?.business.forEach({ b in
                            if let index = enterprises.index(where: {$0.id == b.id}) {
                                enterprises.remove(at: index)
                            }
                        })
                        enterprises.filter({$0.id != id}).forEach({ b in
                            if let index = enterprises.first(where: {$0.id == id})?.business.index(where: {$0.id == b.parentId}){
                               enterprises[0].business[index].business.append(b)
                            }
                        })
                        
                        enterprises = enterprises.filter({$0.id == id})
                        if !store.state.businessState.business.contains(where: {$0.id == enterprises.first?.id}){
                            store.state.businessState.business.append((enterprises.first)!)
                        }else if let index = store.state.businessState.business.index(where: {$0.id == enterprises.first?.id}) {
                            store.state.businessState.business[index] = enterprises.first!
                        }
                        store.state.businessState.status = .finished
                        store.state.businessState.status = .none
                    } catch MoyaError.jsonMapping(let error) {
                        print(error )
                    } catch {
                        print(":(")
                    }
                    
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            })
        }
        
    }
    
    func addUser(of eid: Int, uid: Int) -> Void {
        businessProvider.request(.addUserAt(bid: eid, uid: uid), completion: {
            result in
            switch result {
            case .success(let response):
                
                if response.statusCode == 201 {
                    store.dispatch(baction.Get(id: eid))
                    store.state.businessState.status = .finished
                    
                }else{
                    store.state.businessState.status = .failed
                }
                store.state.businessState.status = .none
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    
    
    func deleteUser(of eid: Int, uid: Int) -> Void {
        businessProvider.request(.deleteUser(eid: eid, uid: uid), completion: {
            result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    store.dispatch(baction.Get(id: eid))
                    store.state.businessState.status = .finished
                    
                }else{
                    store.state.businessState.status = .failed
                }
                store.state.businessState.status = .none
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    func delete(eid: Int) -> Void {
        businessProvider.request(.delete(id: eid), completion: {
            result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    store.dispatch(baction.Get())
                    store.state.businessState.status = .finished
                    
                }else{
                    store.state.businessState.status = .failed
                }
                store.state.businessState.status = .none
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    func putEnterprise(ent: Business) -> Void {
        businessProvider.request(.putEnterprise(enterprise: ent), completion: {
            result in
            switch result {
            case .success(let response):
                
                if response.statusCode == 201 {
                    store.dispatch(baction.Get(id: ent.id!))
                    store.state.businessState.status = .finished
                    
                }else{
                    store.state.businessState.status = .failed
                }
                store.state.businessState.status = .none
                
                
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    func postEnterprise(ent: Business) -> Void {
        businessProvider.request(.create(e: ent), completion: {
            result in
            switch result {
            case .success(let response):
                do {
                    let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                    let enterprise = Business.from(repos)
                    print(repos)
                    if response.statusCode == 201 {
                        if let index = store.state.businessState.business.index(where: {$0.id == ent.parentId!}) {
                            store.state.businessState.business[index].business.append(enterprise!)
                        }
                        store.dispatch(baction.AddUser(uid: store.state.userState.user.id!, bid: (enterprise?.id)!))
                    }else{
                        store.state.businessState.status = .failed
                    }
                    store.state.businessState.status = .none
                } catch MoyaError.jsonMapping(let error) {
                    print(error )
                } catch {
                    print(":(")
                }
                
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    
    
}
