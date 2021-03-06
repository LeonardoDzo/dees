//
//  UserReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire
import Moya
import Mapper
import Whisper

var socket : WebsocketService!
var token = ""
var authPlugin = AccessTokenPlugin(tokenClosure: token)
let userProvider = MoyaProvider<UserService>(plugins: [authPlugin])
let chatProvider = MoyaProvider<MessageProvider>(plugins: [authPlugin])
let authProvider = MoyaProvider<AuthService>(plugins: [])
struct UserReducer {
    func handleAction(action: Action, state: UserState? ) -> UserState {
        var state = state ?? UserState(user: nil, type: 1, users: [], status: .none)
        
        switch action {
        case let action as AuthActions.LogIn:
            if action.email != nil {
                state.status = .loading
                login(whit: action.email, password: action.password)
            }
            break
        case let action as UsersAction.get:
            if action.eid != nil {
                state.status = .loading
              
                self.getUsers(eid: action.eid)
                
            }
            break
        case let action as AuthActions.Token:
            if action.eid != nil {
                setToken(eid: action.eid)
            }
            break
        case let action as AuthActions.ChangePass:
            if action.oldPass != nil {
                state.status = .loading
                changePass(old: action.oldPass, new: action.newPass)
            }
            break
        case _ as AuthActions.LogOut:
            self.logOut()
            state.status = .Finished("logout")
        default:
            break
        }
        return state
    }
    func setToken(eid: Int) -> Void {
        guard let _ =  defaults.value(forKey: "device") as? String else {
            print("NO TOKEN")
           return
        }
        userProvider.request(.token(eid: eid) , completion: { result in
            switch result {
            case .success(let response):
                print(response)
                break
            case .failure(let error):
                print(error)
                store.state.userState.status = .Failed("Hubo algun error")
                store.state.userState.status = .none
                break
            }
            
        })
    }
    func getUser(by id: Int) -> Void {
        userProvider.request(.showUser(id: id), completion: {result in
            switch result {
            case .success(let response):
                do {
                    let repos = try response.mapJSON() as! User
                    print(repos)
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
    func login(whit email: String, password: String ) -> Void {
        authProvider.request(.login(email: email, passwd: password), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                    if response.statusCode != 200  {
                        store.state.userState.status = .Failed(Murmur(title: "Email/Contraseña incorrecta!!",backgroundColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)  ) )
                        return
                    }
                    guard let t = repos.value(forKey: "token") as? String else{
                        return
                    }
                    token = t
                    authPlugin = AccessTokenPlugin(tokenClosure: token)
                    
                    print("TOKEN:" ,token)
                    let user  = User.from(repos)
                    defaults.set(email, forKey: "email")
                    defaults.set(password, forKey: "password")
                    store.state.userState.user = user
                    store.state.userState.status = .Finished(user!)
                    socket = WebsocketService.shared
                    store.dispatch(wAction.Get())
                    store.dispatch(GroupsAction.Groups())
                    if let eid : Int =  user?.bussiness.first?.id {
                         store.dispatch(AuthActions.Token(eid:eid))
                        if let gid = defaults.value(forKey: "Notification-Chat") as? Int {
                            store.dispatch(GroupsAction.GroupIn(gid: gid, eid: eid))
                        }
                    }
                    let Enterprises = user?.bussiness.filter({$0.parentId == nil}) ?? []
                    
                    Enterprises.forEach({e in
                        store.dispatch(baction.Get(id: e.id))
                    });
                    
                } catch MoyaError.jsonMapping(let error) {
                    print(error )
                    store.state.userState.status = .Failed(messages.error._03)
                } catch {
                    print(":(")
                }
                break
            case .failure(let error):
                print(error)
                store.state.userState.status = .Failed(messages.error._05)
                break
            }
            
        })
        
    }
    func changePass(old: String, new: String) -> Void {
        userProvider.request(.changePass(old: old, new: new), completion: { result in
            switch result {
            case .success(let response):
                
                if response.statusCode == 200 {
                    defaults.set(new, forKey: "password")
                    store.state.userState.status = .finished
                }else if response.statusCode >= 500 {
                    store.state.userState.status = .Failed(messages.error._06)
                }
                else if response.statusCode >= 400 {
                    store.state.userState.status = .Failed(messages.error._10)
                }
                store.state.userState.status = .none
             
                break
            case .failure(let error):
                print(error)
                store.state.userState.status = .Failed("Hubo algun error")
                store.state.userState.status = .none
                break
            }
            
        })
    }
    func getUsers(eid: Int) -> Void {
        userProvider.request(.getAll(eid: eid), completion: {result in
            switch result {
            case .success(let response):
                do {
                    let dic = try response.mapJSON()
                    print(dic)
                    let users : [UserCD] = try JSONDecoder().decode([UserCD].self, from: response.data)
                    store.state.userState.users = users
                } catch MoyaError.jsonMapping(let error) {
                    print(error )
                } catch {
                    print(":(")
                }
                break
            case .failure(_):
                store.state.userState.status = .Failed(messages.error._05)
                break
            }
        })
        
    }
    
  
    func logOut() -> Void {
        UserDefaults().removeObject(forKey: "token")
        UserDefaults().removeObject(forKey: "email")
        UserDefaults().removeObject(forKey: "password")
        store.state.businessState = BusinessState(business: [], status: .none)
        store.state.reportState.reports = .none
        store.state.businessState.status = .none
        store.state.businessState.business = []
        store.state.businessState.status = .none
        store.state.userState = UserState(user: nil, type: 0, users: [], status: .none)
        singleton.enterpriseNav.removeAll()
        realm.deleteDatabase()
    }
}

