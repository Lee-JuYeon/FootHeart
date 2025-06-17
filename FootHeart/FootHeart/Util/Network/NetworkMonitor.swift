//
//  NetworkMonitor.swift
//  FootHeart
//
//  Created by Jupond on 5/12/25.
//

import Foundation
import Network

/*
 network monitoring and optimize On/Offline mode
 */
class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitoring")
    
    var isConnected = false
    var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case unknown
    }
    
    func startMonitoring(handler: @escaping (Bool, ConnectionType) -> Void) {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            
            if path.usesInterfaceType(.wifi) {
                self.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self.connectionType = .cellular
            } else {
                self.connectionType = .unknown
            }
            
            DispatchQueue.main.async {
                handler(self.isConnected, self.connectionType)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
