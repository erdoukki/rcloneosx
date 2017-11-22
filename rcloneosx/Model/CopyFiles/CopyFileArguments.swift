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
    case restorerclone
    case listrclone
}

final class CopyFileArguments: SetConfigurations {

    private var arguments: Array<String>?
    private var argDisplaydryRun: Array<String>?
    private var argdryRun: Array<String>?
    private var remotefile: String?
    private var localCatalog: String?

    func getArguments() -> Array<String>? {
        guard self.arguments!.count > 2 else {
            return self.arguments
        }
        self.arguments![1] = self.arguments![1] + "/" + self.remotefile!
        self.arguments?.insert(self.localCatalog!, at: 2)
        return self.arguments
    }

    func getArgumentsdryRun() -> Array<String>? {
        self.argdryRun![1] = self.argdryRun![1] + "/" + self.remotefile!
        self.argdryRun?.insert(self.localCatalog!, at: 2)
        return self.argdryRun
    }

    func getcommandDisplay() -> String {
        guard self.argDisplaydryRun != nil else {
            return ""
        }
        var arguments: String = ""
        for i in 0 ..< self.argDisplaydryRun!.count {
            if i == 2 {
                arguments += self.argDisplaydryRun![i] + "/" + self.remotefile!
                arguments += " " + self.localCatalog! + " "
            } else {
               arguments += self.argDisplaydryRun![i]
            }
        }
        return arguments
    }

    init (task: Enumscopyfiles, config: Configuration, remotefile: String?, localCatalog: String?) {
        self.remotefile = remotefile
        self.localCatalog = localCatalog
        let index = self.configurations?.getIndex(config.hiddenID)
        switch task {
        case .restorerclone:
            self.arguments = self.configurations?.arguments4rsync(index: index!, argtype: .argrestore)
            self.argdryRun = self.configurations?.arguments4rsync(index: index!, argtype: .argrestoredryRun)
            self.argDisplaydryRun = self.configurations?.arguments4rsync(index: index!, argtype: .argrestoreDisplaydryRun)
        case .listrclone:
            self.arguments = self.configurations?.arguments4rsync(index: index!, argtype: .arglistfiles)
        }
    }
}
