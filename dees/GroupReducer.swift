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
           
                state.currentGroup = .loading
                self.groupIn(action.message, gid: action.gid, eid: action.eid)
            
            
        default:
            break
        }
        return state
    }
    
    func groupIn(_ message: _requestMessage?, gid: Int?, eid: Int?) -> Void {
        
        var request : MessageProvider
        
        if message != nil {
            request = MessageProvider.get(m: message!)
        }else if gid != nil, eid != nil{
            request = MessageProvider.getBy(eid: eid!, gid: gid!)
        }else{
            return
        }
        
        chatProvider.request(request, completion: { result in
            switch result {
            case .success(let response):
                do {
                    let repos = response.data
                    var group = try JSONDecoder().decode(Group.self, from: repos)
                    group = self.verifymessage(group: group)
                    
                    if group.party.count > 0 {
                        _ = group.party.map({group._party.append($0)})
                        group.party.removeAll()
                    }
                    
                    realm.save(objs: group)
                    store.state.groupState.currentGroup = .Finished(group)
                    if let _ = defaults.value(forKey: "Notification-Chat") as? Int,  let topController = UIApplication.topViewController() {
                        defaults.removeObject(forKey: "Notification-Chat")
                          topController.pushToView(view: .chatView, sender: configuration(uid: group.userId, wid: store.state.weekState.getWeeks().last?.id! , type: group.type, eid: group.companyId, files: [], user: nil))
                    }
                  
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
                    let dic : NSDictionary = try response.mapJSON() as! NSDictionary
                    print(dic)
                    if response.statusCode < 400 {
                        store.dispatch(GroupsAction.GroupIn(m: m))
                    }
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
                    let dic = try response.mapJSON()
                    print(dic)
                    if response.statusCode >= 400 {
                        print("Error al traer los grupos")
                        completion(.failed)
                    }
                    var groups : [Group] = try JSONDecoder().decode([Group].self, from: response.data)
                    groups.enumerated().forEach({ (i,g) in
                        if g.party.count > 0 {
                            _ = g.party.map({groups[i]._party.append($0)})
                            groups[i].party.removeAll()
                            g.messages.forEach({ (m) in
                                groups[i]._messages.append(m)
                                
                            })
                        }
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
            group._messages.append(objectsIn: group_db._messages)
            group.messages.removeAll()
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
