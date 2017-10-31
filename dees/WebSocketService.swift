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
            socket.connect()
            print("websocket disconnected")
        }
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
                }
                let user = group.first?.party.first(where: {$0.id == message.userId})!
                let username = (user?.name)! + " " + (user?.lastname)!
                self.showNotification(username: username, message: message)
                try! realm.realm.write {
                    group.first?.messages.append(message)
                }
                
                
                realm.save(objs: group.first!)
                
                
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    func showNotification(username: String,message: MessageEntitie) -> Void {
        if message.userId != store.state.userState.user.id, var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let announcement = Announcement(title: (username), subtitle: message.message, image: #imageLiteral(resourceName: "user_min"))
            Whisper.show(shout: announcement, to: topController, completion: {
                print("The shout was silent.")
            })
            // topController should now be your topmost view controller
        }
    }
    
}
