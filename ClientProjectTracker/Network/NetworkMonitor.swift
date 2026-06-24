//
//  NetworkMonitor.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//

import Foundation
import Network

protocol ConnectivityMonitoring: Sendable {
    var isConnected: Bool { get }
}

final class NetworkMonitor: ConnectivityMonitoring, @unchecked Sendable {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.clientprojecttracker.network-monitor")
    private let lock = NSLock()
    nonisolated(unsafe) private var connected = true

    /// Thread-safe snapshot of the current connectivity status.
    nonisolated var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }
        return connected
    }

    /// Starts observing network path changes on a background queue.
    nonisolated init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            lock.lock()
            connected = path.status == .satisfied
            lock.unlock()
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
