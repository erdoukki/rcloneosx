//
//  scpNSTaskArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

enum Enumscopyfiles {
    case cprclone
    case lsrclone
}

final class CopyFileArguments: SetConfigurations {

    private var file: String?
    private var arguments: Array<String>?
    private var argDisplay: String?
    private var command: String?

    func getArguments() -> Array<String>? {
        return self.arguments
    }

    func getCommand() -> String? {
        return self.command
    }

    func getcommandDisplay() -> String {
        guard self.argDisplay != nil else {
            return ""
        }
        return self.argDisplay!
    }

    init (task: Enumscopyfiles, config: Configuration) {
        self.arguments = nil
        self.arguments = Array<String>()
        switch task {
        case .cprclone:
            self.arguments = nil
            // self.arguments = arguments.getArguments()
            // self.command = arguments.getCommand()
            // self.argDisplay = arguments.getArgumentsDisplay()
        case .lsrclone:
            let index = self.configurations?.getIndex(config.hiddenID)
            self.arguments = self.configurations?.arguments4rsync(index: index!, argtype: .arglistfiles)
        }
    }
}
