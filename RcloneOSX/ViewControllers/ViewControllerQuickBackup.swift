//
//  ViewControllerQuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerQuickBackup: NSViewController, SetDismisser, AbortTask, Delay {

    var seconds: Int?
    var row: Int?
    var filterby: Filterlogs?
    var quickbackuplist: QuickBackup?
    var executing: Bool = false

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var abortbutton: NSButton!
    @IBOutlet weak var search: NSSearchField!

    // Either abort or close
    @IBAction func abort(_ sender: NSButton) {
        self.quickbackuplist = nil
        self.abort()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Execute batch
    @IBAction func execute(_ sender: NSButton) {
        self.executing = true
        self.executeButton.isEnabled = false
        self.working.startAnimation(nil)
        self.quickbackuplist?.prepareandstartexecutetasks()
        self.reloadtabledata()
    }

    private func loadtasks() {
        self.quickbackuplist = QuickBackup()
        self.working.stopAnimation(nil)
    }

    // Initial functions viewDidLoad and viewDidAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Setting delegates and datasource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.search.delegate = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcquickbackup, nsviewcontroller: self)
        self.loadtasks()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.executeButton.isEnabled = false
        self.reloadtabledata()
        self.enableexecutebutton()
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard self.executing == false else { return }
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let column = myTableViewFromNotification.selectedColumn
        if column == 3 {
            self.filterby = .localCatalog
            self.quickbackuplist?.sortbystrings(sort: .localCatalog)
        } else if column == 4 {
            self.filterby = .remoteCatalog
            self.quickbackuplist?.sortbystrings(sort: .offsiteCatalog)
        } else if column == 5 {
            self.filterby = .remoteServer
            self.quickbackuplist?.sortbystrings(sort: .offsiteServer)
        } else if column == 6 {
            self.filterby = .numberofdays
            self.quickbackuplist?.sortbydays()
        } else {
            return
        }
    }

    private func enableexecutebutton() {
        let backup = self.quickbackuplist?.sortedlist!.filter({$0.value(forKey: "selectCellID") as? Int == 1})
        guard backup != nil else { return }
        guard self.executing == false else { return }
        if backup!.count > 0 {
            self.executeButton.isEnabled = true
        } else {
            self.executeButton.isEnabled = false
        }
    }

}

extension ViewControllerQuickBackup: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.quickbackuplist?.sortedlist?.count ?? 0
    }
}

extension ViewControllerQuickBackup: NSTableViewDelegate, Attributedestring {
    // TableView delegates
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.quickbackuplist?.sortedlist != nil else { return nil }
        guard row < self.quickbackuplist!.sortedlist!.count else { return nil }
        let object: NSDictionary = (self.quickbackuplist?.sortedlist![row])!
        if tableColumn!.identifier.rawValue == "daysID" {
            if object.value(forKey: "markdays") as? Bool == true {
                let celltext = object[tableColumn!.identifier] as? String
                return self.attributedstring(str: celltext!, color: NSColor.red, align: .right)
            }
        }
        if tableColumn!.identifier.rawValue == "selectCellID" {
            return object[tableColumn!.identifier] as? Int
        }
        if tableColumn!.identifier.rawValue == "completeCellID" {
            if object.value(forKey: "inprogressCellID") as? Bool == true {
                return #imageLiteral(resourceName: "leftarrow")
            }
            if object.value(forKey: "completeCellID") as? Bool == true {
                return #imageLiteral(resourceName: "complete")
            }
        }
        return object[tableColumn!.identifier] as? String
    }

    // Toggling selection
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard  self.quickbackuplist?.sortedlist != nil else { return }
        if tableColumn!.identifier.rawValue == "selectCellID" {
            var select: Int = (self.quickbackuplist?.sortedlist![row].value(forKey: "selectCellID") as? Int)!
            if select == 0 { select = 1 } else if select == 1 { select = 0 }
            self.quickbackuplist?.sortedlist![row].setValue(select, forKey: "selectCellID")
        }
        self.enableexecutebutton()
    }
}

extension ViewControllerQuickBackup: Reloadandrefresh {

    // Updates tableview according to progress of batch
    func reloadtabledata() {
        self.enableexecutebutton()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerQuickBackup: CloseViewError {
    func closeerror() {
        self.quickbackuplist = nil
        self.abort()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }
}

extension ViewControllerQuickBackup: UpdateProgress {
    func processTermination() {
        self.quickbackuplist?.setcompleted()
        self.quickbackuplist?.processTermination()
    }

    func fileHandler() {
        // nothing
    }
}

extension ViewControllerQuickBackup: StartStopProgressIndicator {
    func start() {
        // nothing
    }

    func stop() {
        self.working.stopAnimation(nil)
        self.executeButton.isEnabled = false
    }

    func complete() {
        // nothing
    }
}

extension ViewControllerQuickBackup: NSSearchFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        guard self.executing == false else { return }
        self.delayWithSeconds(0.25) {
            let filterstring = self.search.stringValue
            if filterstring.isEmpty {
                globalMainQueue.async(execute: { () -> Void in
                    self.quickbackuplist?.sortbydays()
                })
            } else {
                globalMainQueue.async(execute: { () -> Void in
                    self.quickbackuplist?.filter(search: filterstring, what: self.filterby)
                })
            }
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        guard self.executing == false else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.loadtasks()
        })
    }

}
