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

    private var arguments: Array<String>?
    private var argDisplaydryRun: Array<String>?
    private var argdryRun: Array<String>?

    func getArguments() -> Array<String>? {
        return self.arguments
    }
    
    func getArgumentsdryRun() -> Array<String>? {
        return self.argdryRun
    }

    func getcommandDisplay() -> String {
        guard self.argDisplaydryRun != nil else {
            return ""
        }
        var arguments: String = ""
        for i in 0 ..< self.argDisplaydryRun!.count {
            arguments += self.argDisplaydryRun![i]
        }
        return arguments
    }

    init (task: Enumscopyfiles, config: Configuration, remotefile: String?, localCatalog: String?) {
        self.arguments = nil
        self.arguments = Array<String>()
        switch task {
        case .cprclone:
            let index = self.configurations?.getIndex(config.hiddenID)
            self.arguments = self.configurations?.arguments4rsync(index: index!, argtype: .argrestore)
            self.argdryRun = self.configurations?.arguments4rsync(index: index!, argtype: .argdryRun)
            self.argDisplaydryRun = self.configurations?.arguments4rsync(index: index!, argtype: .argrestoreDisplaydryRun)
        case .lsrclone:
            let index = self.configurations?.getIndex(config.hiddenID)
            self.arguments = self.configurations?.arguments4rsync(index: index!, argtype: .arglistfiles)
        }
    }
}
