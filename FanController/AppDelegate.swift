//
//  AppDelegate.swift
//  FanController
//
//  Created by Christopher Boyle on 15/07/2020.
//  Copyright © 2020 Christopher Boyle. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var status_update_timer = Timer()
    var cpu_temp  :Double = 0.0
    var fan_speed :Double = 0.0
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        statusItem.button?.font = NSFont.systemFont(ofSize: 8)
        
        
        do {
            try SMCKit.open()
        }
        catch {
            print("could not open connection to SMC \(error)")
            exit(1)
        }
        
        
        updateDisplayedText()
        
        status_update_timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
          timer in
            self.updateDisplayedText(timer: timer)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        SMCKit.close()
    }
    
    
    func updateDisplayedText() {
        var fan_str = "--"
        var temp_str = "--"
        
        do {
            let fan1speed = try SMCKit.fanCurrentSpeed(0)
            let fan2speed = try SMCKit.fanCurrentSpeed(1)
            self.fan_speed = (fan1speed + fan2speed)*0.5
            fan_str = String(format: "%.0f", self.fan_speed)
            
            let cpu1_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC1C"))
            let cpu2_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC2C"))
            let cpu3_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC3C"))
            let cpu4_temp = try SMCKit.temperature(IOFourCharCode(fromStaticString: "TC4C"))
            self.cpu_temp = (cpu1_temp + cpu2_temp + cpu3_temp + cpu4_temp) * 0.25
            temp_str = String(format: "%.0f", cpu_temp)
        }
        catch {
            // do nothing
            NSLog("Error reading values \(error)")
        }
        
        self.statusItem.button?.title = String(format: "%@ rpm\n%@ºC", fan_str, temp_str)

    }
    
    // https://stackoverflow.com/questions/29561476/run-background-task-as-loop-in-swift/29564713#29564713
    @objc func updateDisplayedText(timer:Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {

              DispatchQueue.main.async {
                self.updateDisplayedText()
             }
          }
    }


}

