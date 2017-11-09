//
//  GetCloudServices.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 09.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class GetCloudServices {

    var process: CloudServices?
    private var arguments: Array<String>?
    private var output: OutputProcess?
    
    private func getCloudServices() {
        self.process = CloudServices(command: nil, arguments: self.arguments)
        self.process!.executeProcess(output: self.output)
    }
    
    init(output: OutputProcess?) {
        self.output = output
        self.arguments = ["config","show"]
        self.getCloudServices()
    }
}
