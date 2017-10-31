//
//  GroupReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 26/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Moya
import ReSwift
let jsonDecoder = JSONDecoder()
struct GroupReducer {
    
    func handleAction(action: Action, state: GroupState? ) -> GroupState {
        var state = state ?? GroupState(groups: .loading, currentGroup: .loading)
        
        switch action {
        case let action as GroupsAction.SendMessage:
            if action.message != nil {
                sendMessage(m: action.message)
            }
            break
        case _ as GroupsAction.Groups:
            if token != "" {
                groups()
            }
            break
        case let action as GroupsAction.GroupIn:
            if action.message.eid != nil {
                state.currentGroup = .loading
                self.groupIn(action.message)
            }
            
        default:
            break
        }
        return state
    }
    
    func groupIn(_ message: _requestMessage) -> Void {
        chatProvider.request(.get(m: message), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let dic: NSDictionary = (try response.mapJSON() as? NSDictionary)!
                    let repos = response.data
                    var group = try JSONDecoder().decode(Group.self, from: repos)
                    group = self.verifymessage(group: group)
                    
                    if let pDic = dic["party"], let partyMembers : Data = self.jsonToData(json: pDic) {
                        let party: [PartyMember] = try jsonDecoder.decode([PartyMember].self, from: partyMembers)
                        party.forEach({user in
                            do {
                                try realm.realm.write({
                                    group.party.append(user)
                                })
                            } catch let e {
                                print(e)
                            }
                            
                        })
                        
                    }
                    if let msgs = dic["messages"], let messages = self.jsonToData(json: msgs) {
                        let messages: [MessageEntitie] = try jsonDecoder.decode([MessageEntitie].self, from: messages)
                        messages.forEach({m in
                            group.messages.append(m)
                            
                        })
                        
                    }
                    
                    realm.save(objs: group)
                    store.state.groupState.currentGroup = .Finished(group)
                } catch MoyaError.jsonMapping(let error) {
                    print(error )
                    store.state.userState.status = .Failed("Hubo algun error")
                }catch let myJSONError {
                    print(myJSONError)
                }
                break
            case .failure(let error):
                print(error)
                store.state.userState.status = .Failed("Hubo algun error")
                store.state.userState.status = .none
                break
            }
            
        })
    }
    
    func sendMessage(m: _requestMessage) -> Void {
        chatProvider.request(.post(m: m), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                    print(repos)
                } catch MoyaError.jsonMapping(let error) {
                    print(error )
                    store.state.userState.status = .Failed("Hubo algun error")
                } catch {
                    print(":(")
                }
                break
            case .failure(let error):
                print(error)
                store.state.userState.status = .Failed("Hubo algun error")
                store.state.userState.status = .none
                break
            }
            
        })
    }
    
    func groups() -> Void {
        
        groupsWithCompletion { (status) in
            store.state.groupState.groups = status
        }
    }
    func groupsWithCompletion(completion: @escaping (Result<Any>) -> Void) {
        chatProvider.request(.groups(), completion: { result in
            switch result {
            case .success(let response):
                do {
                 
                    if response.statusCode >= 400 {
                        print("Error al traer los grupos")
                        completion(.failed)
                    }
                    var groups : [Group] = try JSONDecoder().decode([Group].self, from: response.data)
                    groups.enumerated().forEach({ (i,g) in
                        groups[i] = self.verifymessage(group: g)
                    })
                    realm.saveObjects(objs: groups)
                    completion(.finished)
                    
                } catch MoyaError.jsonMapping(let error) {
                    print(error )
                    store.state.userState.status = .Failed("Hubo algun error")
                } catch {
                    print(":(")
                }
                break
            case .failure(let error):
                print(error)
                store.state.userState.status = .Failed("Hubo algun error")
                store.state.userState.status = .none
                break
            }
            
        })
    }

    
    
    func verifymessage(group: Group) -> Group {
        if let group_db = realm.realm.object(ofType: Group.self, forPrimaryKey: group.id) {
            group.messages.append(objectsIn: group_db.messages)
        }
        return group
    }
    
    func jsonToData(json: Any) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
}
