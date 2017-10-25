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
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Received text: \(text)")
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let decoder = JSONDecoder()
                let message = try decoder.decode(MessageEntitie.self, from: data)
                realm.save(objs: message)
                
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    
}
