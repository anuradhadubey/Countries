//
//  ReachabilityManager.swift
//  NetworkStatusMonitor
//
//

import Foundation
import Reachability

class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    
    //declare this property where it won't go out of scope relative to your listener
    let reachability = Reachability()!
    
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.Connection = .none
    // 5. Reachability instance for Network status monitoring
    
    
    /// Called whenever there is a change in NetworkReachibility Status
    ///
    /// — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            print("Network became unreachable")
        case .wifi:
            print("Network reachable through WiFi")
        case .cellular:
            print("Network reachable through Cellular Data")
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,  name: Notification.Name.reachabilityChanged, object: reachability)
    }
}
