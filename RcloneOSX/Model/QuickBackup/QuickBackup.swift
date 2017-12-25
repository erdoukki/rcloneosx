//
//  QuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum Sort {
    case localCatalog
    case offsiteCatalog
    case offsiteServer
    case backupId
}

class QuickBackup: SetConfigurations {
    var backuplist: [NSMutableDictionary]?
    var sortedlist: [NSMutableDictionary]?
    typealias Row = (Int, Int)
    var stackoftasktobeexecuted: [Row]?

    func sortbydays() {
        guard self.backuplist != nil else {
            self.sortedlist = nil
            return
        }
        let sorted = self.backuplist!.sorted {(di1, di2) -> Bool in
            let di1 = (di1.value(forKey: "daysID") as? NSString)!.doubleValue
            let di2 = (di2.value(forKey: "daysID") as? NSString)!.doubleValue
            if di1 > di2 {
                return false
            } else {
                return true
            }
        }
        self.sortedlist = sorted
    }

    func sortbystrings(sort: Sort) {
        var sortby: String?
        guard self.backuplist != nil else {
            self.sortedlist = nil
            return
        }
        switch sort {
        case .localCatalog:
            sortby = "localCatalogCellID"
        case .backupId:
            sortby = "backupIDCellID"
        case .offsiteCatalog:
            sortby = "offsiteCatalogCellID"
        case .offsiteServer:
            sortby = "offsiteServerCellID"
        }
        let sorted = self.backuplist!.sorted {return ($0.value(forKey: sortby!) as? String)!.localizedStandardCompare(($1.value(forKey: sortby!) as? String)!) == .orderedAscending}
        self.sortedlist = sorted
    }

    private func executetasknow(hiddenID: Int) {
        let now: Date = Date()
        let dateformatter = Tools().setDateformat()
        let task: NSDictionary = [
            "start": now,
            "hiddenID": hiddenID,
            "dateStart": dateformatter.date(from: "01 Jan 1900 00:00") as Date!,
            "schedule": "manuel"]
        ViewControllerReference.shared.scheduledTask = task
        _ = OperationFactory()
    }

    func prepareandstartexecutetasks() {
        if let list = self.sortedlist {
            self.stackoftasktobeexecuted = nil
            self.stackoftasktobeexecuted = [Row]()
            for i in 0 ..< list.count {
                list[i].setObject(false, forKey: "completeCellID" as NSCopying)
                if list[i].value(forKey: "selectCellID") as? Int == 1 {
                    self.stackoftasktobeexecuted?.append(((list[i].value(forKey: "hiddenID") as? Int)!, i))
                }
            }
            guard self.stackoftasktobeexecuted!.count > 0 else { return }
            let hiddenID = self.stackoftasktobeexecuted![0].0
            self.executetasknow(hiddenID: hiddenID)
        }
    }

    func processTermination() {
        guard self.stackoftasktobeexecuted != nil else { return }
        let hiddenID = self.stackoftasktobeexecuted![0].0
        self.stackoftasktobeexecuted?.remove(at: 0)
        if self.stackoftasktobeexecuted?.count == 0 { self.stackoftasktobeexecuted = nil }
        self.executetasknow(hiddenID: hiddenID)
    }

    // Called before processTerminatiom
    func setcompleted() {
        guard self.stackoftasktobeexecuted != nil else { return }
        let index = self.stackoftasktobeexecuted![0].1
        self.sortedlist![index].setValue(true, forKey: "completeCellID")
        if self.stackoftasktobeexecuted?.count == 0 { self.stackoftasktobeexecuted = nil }
    }

    init() {
        self.backuplist = self.configurations!.getConfigurationsDataSourcecountBackupOnly()
        self.sortbydays()
    }
}