/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import CoreBluetooth

/**
*    Utility class to broadcast a bluetooth signal to communicate with the companion iPad app
**/
class BroadcastManager: NSObject {
    
    // Size of a data chunk
    let notifyMTU = 20
    
    // Bluetooth Service ID which is advertised
    let serviceUUID = CBUUID(string: "5b7c678c-5ca5-11e5-885d-feff819cdc9f")
    // Transfer characteristic UUID which is advertised
    let characteristicUUID = CBUUID(string: "5b7c6a16-5ca5-11e5-885d-feff819cdc9f")
    // The current Device UUID
    var deviceUUID: String?
    // NSData buffer for data to send
    var dataToSend = NSData()
    // Current index of data sent in data buffer
    var sendIndex = 0
    // Flag to track if end of message needs to be sent
    var needEOM = false
    
    internal var peripheralManager: CBPeripheralManager!
    internal var transferCharacteristic: CBMutableCharacteristic!
    
    /**
    Method to start the peripheral manager and turn on bluetooth.
    */
    func start(){
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    /**
    Method to begin advertising service and transfer characteristic UUIDs to nearby centrals.
    */
    private func startAdvertising() {
        
        guard let deviceUUID = UIDevice.currentDevice().identifierForVendor?.UUIDString as String! else{
            print("Bluetooth - Could not get device UUID.")
            MQALogger.log("Bluetooth - Could not get device UUID.", withLevel: MQALogLevelInfo)
            return
        }
        
        transferCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [CBCharacteristicProperties.Notify, CBCharacteristicProperties.WriteWithoutResponse], value: nil, permissions: [CBAttributePermissions.Readable, CBAttributePermissions.Writeable])
        
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [transferCharacteristic]
        peripheralManager.addService(service)
        
        let advertisementData: [String: AnyObject] = [CBAdvertisementDataServiceUUIDsKey: [serviceUUID], CBAdvertisementDataLocalNameKey: deviceUUID]
        
        peripheralManager.startAdvertising(advertisementData)
        print("Bluetooth - Advertisement Data : \(advertisementData)")
        MQALogger.log("Bluetooth - Advertisement Data : \(advertisementData)", withLevel: MQALogLevelInfo)
        
    }
    
    /**
    Method to send data chunks across bluetooth.
    */
    func sendData() {
        
        if needEOM {
            needEOM = !sendEOM()
            return
        }
        
        guard sendIndex < dataToSend.length else {
            return
        }

        var didSend = true
        
        while(didSend) {
            
            var amountToSend = dataToSend.length - sendIndex
            if (amountToSend > notifyMTU) {
                amountToSend = notifyMTU
            }
            
            let dataChunk = NSData(bytes: dataToSend.bytes+sendIndex, length: amountToSend)
            didSend = peripheralManager.updateValue(dataChunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            guard didSend else {
                return
            }
            
            sendIndex += amountToSend
            
            if sendIndex >= dataToSend.length {
                needEOM = true
                needEOM = !sendEOM()
                return
            }
        }
        
    }
    
    /**
    Method to send EOM once data tansmission is complete.
    
    - returns: True if the EOM was sent.
    */
    func sendEOM() -> Bool {
        guard let eom = "EOM".dataUsingEncoding(NSUTF8StringEncoding) else {
            return false
        }
        print("Bluetooth - Sending EOM")
        MQALogger.log("Bluetooth - Sending EOM", withLevel: MQALogLevelInfo)
        return peripheralManager.updateValue(eom, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
    }
    
}

extension BroadcastManager: CBPeripheralManagerDelegate {
    
    /**
    Method called when the manager updates state. When powered on, the device begins advertising.
    
    - parameter peripheral: The peripheral which had its state updated.
    */
     func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
        case CBPeripheralManagerState.Unknown:
            print("Bluetooth - State Unknown")
            MQALogger.log("Bluetooth - State Unknown", withLevel: MQALogLevelInfo)
            
        case CBPeripheralManagerState.Resetting:
            print("Bluetooth - State Resetting")
            MQALogger.log("Bluetooth - State Resetting", withLevel: MQALogLevelInfo)
            
        case CBPeripheralManagerState.Unsupported:
            print("Bluetooth - State Unsupported")
            MQALogger.log("Bluetooth - State Unsupported", withLevel: MQALogLevelInfo)
            
        case CBPeripheralManagerState.Unauthorized:
            print("Bluetooth - State Unauthorized")
            MQALogger.log("Bluetooth - State Unauthorized", withLevel: MQALogLevelInfo)
            
        case CBPeripheralManagerState.PoweredOff:
            print("Bluetooth - State PoweredOff")
            MQALogger.log("Bluetooth - State PoweredOff", withLevel: MQALogLevelInfo)
            
        case CBPeripheralManagerState.PoweredOn:
            print("Bluetooth - State PoweredOn")
            MQALogger.log("Bluetooth - State PoweredOn", withLevel: MQALogLevelInfo)
            startAdvertising()
        }
        
    }
    
    /**
    Method called when the peripheral begins advertising.
    
    - parameter peripheral: The peripheral that began advertising.
    - parameter error:      Any errors.
    */
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("Bluetooth - Started Advertising")
        MQALogger.log("Bluetooth - Started Advertising", withLevel: MQALogLevelInfo)
    }
    
    /**
    Method called when a central subscribes to a characteristic.
    
    - parameter peripheral:     The peripheral broadcasting the characteristic.
    - parameter central:        The central which subscribed.
    - parameter characteristic: The characteristic which was subscribed to.
    */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("Bluetooth - Central Subscribed")
        
        guard let data = UIDevice.currentDevice().identifierForVendor?.UUIDString.dataUsingEncoding(NSUTF8StringEncoding) else {
            return
        }
        
        dataToSend = data
        sendIndex = 0
        sendData()
        
    }
    
    /**
    Method called when a central unsubscribes to a characteristic.
    
    - parameter peripheral:     The peripheral broadcasting the characteristic.
    - parameter central:        The central which unsubscribed.
    - parameter characteristic: The characteristic which was unsubscribed from.
    */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("Bluetooth - Central Unsubscribed")
    }
    
    /**
    Method called when the peripheral is ready to update subscribers.
    
    - parameter peripheral: The peripheral which is updating its subscribers.
    */
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        print("Bluetooth - Ready to Update")
        sendData()
    }
    
    /**
    Method called when a peripheral receives a write request. 
    In this case it checks which command was sent from the companion app and acts accordingly.
    
    - parameter peripheral: The peripheral which received the request.
    - parameter requests:   The requests which were received.
    */
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
        print("Bluetooth - Received Write Request")
        
        let request = requests[0]
        if let value = request.value {
            if let message = NSString(data: value, encoding: NSUTF8StringEncoding) as? String {
                print(message)
                switch message {
                    case "offer":
                        DemoManager.sendOffer()
                        break
                    case "weather":
                        DemoManager.weatherAlert()
                        break
                    case "waittime":
                        DemoManager.waitTimeAlert()
                        break
                    case "invite":
                        DemoManager.sendInvite()
                        break
                    case "reminder":
                        DemoManager.sendReminder()
                        break
                    case "badge":
                        DemoManager.unlockBadge()
                        break
                    default:
                        print("\(message) - Command not recognized. ")
                        break
                }
                
            }
            
        }
    }
    
}

