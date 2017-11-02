//
//  WebSocketService.swift
//  dees
//
//  Created by Leonardo Durazo on 24/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Starscream
import RealmSwift
import Whisper
class WebsocketService: WebSocketDelegate {
    var request = URLRequest(url: URL(string: api.ws + "\(store.state.userState.user.bussiness.first!.id!)/res/reply/mine")!)
    
    var socket : WebSocket!
    
    private init() {
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        socket = WebSocket(request: request)
        socket.delegate = self
        print(socket.currentURL.absoluteString)
        socket.connect()
    }
    
    static let shared = WebsocketService()
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            
            print("websocket disconnected")
        }
        socket.connect()
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {

        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let decoder = JSONDecoder()
                let message = try decoder.decode(MessageEntitie.self, from: data)
                let group = realm.realm.objects(Group.self).filter("id = %@", message.groupId)
                if group.first == nil {
                    GroupReducer().groupsWithCompletion(completion: { (status) in
                        switch status {
                        case .loading, .failed, .Failed(_):
                            break
                        case .finished, .Finished(_):
                            self.websocketDidReceiveMessage(socket: socket, text: text)
                            break
                        case .none:
                            break
                        }
                    })
                }else{
                    
                    self.showNotification(group: group.first!, message: message)
                    try! realm.realm.write {
                        group.first?.messages.append(message)
                    }
                    
                    
                    realm.save(objs: group.first!)
                }
                
                
                
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    func showNotification(group : Group,message: MessageEntitie) -> Void {
        let user = group._party.first(where: {$0.id == message.userId})!
        let username = (user.name) + " " + (user.lastname)
        if message.userId != store.state.userState.user.id, let topController = UIApplication.topViewController(), !store.state.groupState.isCurrentGroup(id: message.groupId) {

            let announcement = Announcement(title: (username), subtitle: message.message, image: #imageLiteral(resourceName: "user_min"), duration: 3, action: {
                
                topController.pushToView(view: .chatView, sender: configuration(uid: message.userId, wid: message.weekId, type: group.type, eid: group.companyId, files: [], user: nil) )
            })
            
            Whisper.show(shout: announcement, to: topController)
            // topController should now be your topmost view controller
        }
    }
    
}

extension UIApplication
{
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            let top = topViewController(nav.visibleViewController)
            return top
        }
        
        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                let top = topViewController(selected)
                return top
            }
        }
        
        if let presented = base?.presentedViewController
        {
            let top = topViewController(presented)
            return top
        }
        return base
    }
}
