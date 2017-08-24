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

struct BusinessReducer: Reducer {
    func handleAction(action: Action, state: BusinessState?) -> BusinessState {
        var state = state ?? BusinessState(business: [], status: .none)
        switch action {
        case let action as GetBusinessAction:
            if token != "" {
                state.status = .loading
                getEnterprise(id: action.id)
            }
            break
        case is GetWeeksAction:
            if !token.isEmpty {
                state.status = .loading
            }
            break
        case let action as AddUserBusinessAction:
            if action.bid != nil {
                state.status = .loading
                addUser(of: action.bid, uid: action.uid)
            }
            break
        case let action as DeleteUserBusinessAction:
            if action.bid != nil {
                state.status = .loading
                deleteUser(of: action.bid, uid: action.uid)
            }
            break
        case let action as PutBusinessAction:
            if action.enterprise != nil {
                state.status = .loading
                putEnterprise(ent: action.enterprise)
            }
        case let action as CreateBusinessAction:
            if action.e != nil {
                state.status = .loading
                postEnterprise(ent: action.e)
            }
            break
        case let action as DeleteBusinessAction:
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
                        
                        let enterprises = Business.from(array) ?? []
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
                        let dic = repos.value(forKey: "enterprise") as! NSDictionary
                        let enterprise = Business.from(dic)
                        store.state.businessState.business.enumerated().forEach({
                            index, b in
                            if b.id == enterprise?.id {
                                store.state.businessState.business[index] = enterprise!
                                return
                            }else{
                                b.business.enumerated().forEach({
                                    i2, b2 in
                                    store.state.businessState.business[index].business[i2].color = b.color
                                    if b2.id == enterprise?.id {
                                        store.state.businessState.business[index].business[i2] = enterprise!
                                        return
                                    }
                                })
                            }
                            
                        })
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
                    store.dispatch(GetBusinessAction(id: eid))
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
                    store.dispatch(GetBusinessAction(id: eid))
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
                    store.dispatch(GetBusinessAction())
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
                    store.dispatch(GetBusinessAction(id: ent.id!))
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
                        if let index = store.state.businessState.business.index(where: {$0.id == ent.ext!}) {
                            store.state.businessState.business[index].business.append(enterprise!)
                        }
                        store.dispatch(AddUserBusinessAction(uid: store.state.userState.user.id!, bid: (enterprise?.id)!))
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
