/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject {
    
    let serviceUUID = CBUUID(string: "5b7c678c-5ca5-11e5-885d-feff819cdc9f")
    let characteristicUUID = CBUUID(string: "5b7c6a16-5ca5-11e5-885d-feff819cdc9f")
    let rssiThreshold = -45
    let decayMax = 5
    
    internal var centralManager: CBCentralManager!
    internal var timer: NSTimer!
    var devices: [String:Int] = [:]
    var connectedDevice: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    var data = NSMutableData()
    
    var mapController: MapViewController?
    var leaderboardController: LeaderboardViewController?
    
    func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        timer = NSTimer(timeInterval: 1.0, target: self, selector: "decay", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    private func startScanning() {
        print("Started Scanning")
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true ])
        
    }
    
    /**
    Decay function is called every second on the timer to ensure that devices 
    that aren't consistently pinging are removed after a maximum of decayMax seconds.
    
    Needs to be public so the timer can find it.
    */
    func decay() {
        for uuid in devices.keys {
            decayDevice(uuid)
        }
    }
    
    func decayDevice(uuid: String) {
        if let uuidVal = devices[uuid] {
            devices[uuid] = uuidVal - 1
            if devices[uuid] <= 0 {
                devices.removeValueForKey(uuid)
                if devices.count <= 0 {
                    clearViews()
                    cleanup()
                }
            }
        }
    }
    
    func clearViews() {
        
        ApplicationDataManager.sharedInstance.currentUser = nil
        
        if let mapVC = mapController {
            mapVC.clearMap()
        }
        
        if let leaderboard = leaderboardController {
            leaderboard.deviceNear = false
            leaderboard.leaderboardTable.reloadData()
            UIView.animateWithDuration(0.3, animations: {
                leaderboard.welcomeHeight.constant = 115 + 30
                leaderboard.view.layoutIfNeeded()
            })
            
        }
    }
    
    func updateViews() {
        
        ApplicationDataManager.sharedInstance.setCurrentUser()
        
        if let mapVC = mapController {
            mapVC.drawMap()
        }
        
        if let leaderboard = leaderboardController {
            leaderboard.deviceNear = true
            leaderboard.determineUserIndex()
            UIView.animateWithDuration(0.3, animations: {
                leaderboard.welcomeHeight.constant = 115
                leaderboard.view.layoutIfNeeded()
            })
            
        }
        
    }
    
    func sendDataFromString(message: String) {
        
        guard let peripheral = connectedDevice, characteristic = transferCharacteristic else {
            print("No connected device.")
            return
        }
        
        if let data = message.dataUsingEncoding(NSUTF8StringEncoding) {
            print("Sending message: \(message) to Peripheral: \(peripheral) on Characteristic: \(characteristic)")
            peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
        }
    }
    
    func receivedString(message: String) {
        print(message)
    }
    
    func cleanup() {
        if let peripheral = connectedDevice {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        switch central.state {
        case CBCentralManagerState.Unknown:
            print("State Unknown")
            break
            
        case CBCentralManagerState.Resetting:
            print("State Resetting")
            break
            
        case CBCentralManagerState.Unsupported:
            print("State Unsupported")
            break
            
        case CBCentralManagerState.Unauthorized:
            print("State Unauthorized")
            break
            
        case CBCentralManagerState.PoweredOff:
            print("State PoweredOff")
            break
            
        case CBCentralManagerState.PoweredOn:
            print("State PoweredOn")
            startScanning()
            break
        }
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if RSSI.integerValue > rssiThreshold && RSSI.integerValue < 0 {
            devices[peripheral.identifier.UUIDString] = decayMax
            updateViews()
            if connectedDevice == nil {
                print("Attempting connect to \(peripheral.identifier.UUIDString).")
                connectedDevice = peripheral
                centralManager.connectPeripheral(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected to peripheral \(peripheral).")
        
        data.length = 0
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected from peripheral \(peripheral).")
        connectedDevice = nil
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect peripheral. \(error)")
        cleanup()
    }
    
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        guard error == nil else {
            print("Error discovering services. \(error)")
            cleanup()
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([characteristicUUID], forService: service)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        guard error == nil else {
            print("Error discovering characteristics. \(error)")
            cleanup()
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.UUID == characteristicUUID {
                    transferCharacteristic = characteristic
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard error == nil else {
            print("Error updating characteristic value. \(error)")
            cleanup()
            return
        }
        
        if let value = characteristic.value {
            let newData = NSString(data: value, encoding: NSUTF8StringEncoding)
            if let stringData = newData as? String {
                if stringData == "EOM" {
                    if let message = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                        receivedString(message)
                    }
                    return
                }
            }
            
            data.appendData(value)
            
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard error == nil else {
            print("Error writing characteristic value. \(error)")
            return
        }
        
        print("Wrote characteristic value.")
    }
    
}
