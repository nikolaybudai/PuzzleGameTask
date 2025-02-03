//
//  NetworkMonitor.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import Network

//MARK: - Protocol
protocol NetworkMonitorProtocol {
    func isConnectionAvailable() -> Bool
}

//MARK: - NetworkMonitor

/// Monitors network connectivity status using NWPathMonitor.
final class NetworkMonitor: NetworkMonitorProtocol {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private var isConnected: Bool = false
    
    //MARK: Init
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }
    
    //MARK: Methods
    func isConnectionAvailable() -> Bool {
        return isConnected
    }
    
    //MARK: Deinit
    deinit {
        monitor.cancel()
    }
}
