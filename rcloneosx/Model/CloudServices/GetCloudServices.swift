//
//  GetCloudServices.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 09.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable syntactic_sugar

import Foundation

final class GetCloudServices {

    var process: CloudServices?
    private var arguments: Array<String>?
    private var outputprocess: OutputProcess?

    private func getCloudServices() {
        self.process = CloudServices(command: nil, arguments: self.arguments)
        self.process!.executeProcess(outputprocess: self.outputprocess)
    }
    
    init(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
        self.arguments = ["config","show"]
        self.getCloudServices()
    }
}
