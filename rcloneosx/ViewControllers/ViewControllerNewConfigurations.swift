//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length

import Foundation
import Cocoa

class ViewControllerNewConfigurations: NSViewController, SetConfigurations, VcSchedule, Delay {

    var storageapi: PersistentStorageAPI?
    var newconfigurations: NewConfigurations?
    var tabledata: [NSMutableDictionary]?
    let copycommand: String = "copy"
    let movecommand: String = "move"
    let synccommand: String = "sync"
    let verbose: String = "--verbose"
    let dryrun: String = "--dry-run"
    let checkcommand: String = "check"
    var output: OutputProcess?
    var rclonecommand: String?

    @IBOutlet weak var viewParameter4: NSTextField!
    @IBOutlet weak var viewParameter5: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var equal: NSTextField!
    @IBOutlet weak var empty: NSTextField!
    @IBOutlet weak var profilInfo: NSTextField!
    @IBOutlet weak var newTableView: NSTableView!
    @IBOutlet weak var cloudService: NSComboBox!
    
    @IBAction func cleartable(_ sender: NSButton) {
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        globalMainQueue.async(execute: { () -> Void in
            self.newTableView.reloadData()
            self.setFields()
        })
    }
   
    @IBAction func copyLocalCatalog(_ sender: NSButton) {
         _ = FileDialog(requester: .addLocalCatalog)
    }
    
    @IBAction func copyRemoteCatalog(_ sender: NSButton) {
        _ = FileDialog(requester: .addRemoteCatalog)
    }
    
    @IBOutlet weak var copyradio: NSButton!
    @IBOutlet weak var syncradio: NSButton!
    @IBOutlet weak var moveradio: NSButton!
    @IBOutlet weak var checkradio: NSButton!
    
    @IBAction func choosecommand(_ sender: NSButton) {
        if self.copyradio.state == .on {
            self.rclonecommand = self.copycommand
        } else if self.syncradio.state == .on {
            self.rclonecommand = self.synccommand
        } else if self.moveradio.state == .on {
            self.rclonecommand = self.movecommand
        } else if self.checkradio.state == .on {
            self.rclonecommand = self.checkcommand
        }
    }
    
    // Userconfiguration button
    @IBAction func userconfiguration(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newTableView.delegate = self
        self.newTableView.dataSource = self
        self.localCatalog.toolTip = "By using Finder drag and drop filepaths."
        self.offsiteCatalog.toolTip = "By using Finder drag and drop filepaths."
        ViewControllerReference.shared.setvcref(viewcontroller: .vcnewconfigurations, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        if let profile = self.configurations!.getProfile() {
            self.storageapi = PersistentStorageAPI(profile: profile)
        } else {
            self.storageapi = PersistentStorageAPI(profile: nil)
        }
        self.setFields()
        self.loadCloudServices()
        self.rclonecommand = self.copycommand
        self.copyradio.state = .on
    }
    
    private func loadCloudServices() {
        guard ViewControllerReference.shared.norsync == false else {
            return
        }
        self.output = nil
        self.output = OutputProcess()
        _ = GetCloudServices(output: self.output)
        self.cloudService.removeAllItems()
        self.delayWithSeconds(0.5) {
            self.cloudService.addItems(withObjectValues: self.output!.trimoutput(trim: .three)!)
        }
    }

    private func setFields() {
        self.viewParameter4.stringValue = self.verbose
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.cloudService.stringValue = ""
        self.backupID.stringValue = ""
        self.equal.isHidden = true
        self.empty.isHidden = true
    }
    
    @IBAction func addConfig(_ sender: NSButton) {
        guard self.offsiteCatalog.stringValue != self.localCatalog.stringValue else {
            self.equal.isHidden = false
            return
        }
        guard self.cloudService.stringValue.isEmpty == false else {
            self.empty.isHidden = false
            return
        }
        let dict: NSMutableDictionary = [
            "task": self.rclonecommand ?? "",
            "backupID": self.backupID.stringValue,
            "localCatalog": self.localCatalog.stringValue,
            "offsiteCatalog": self.offsiteCatalog.stringValue,
            "offsiteServer": self.cloudService.stringValue,
            "parameter1": self.copy,
            "parameter2": self.verbose,
            "dryrun": self.dryrun,
            "dateRun": ""]
        dict.setValue("no", forKey: "batch")
        dict.setValue(self.localCatalog.stringValue, forKey: "localCatalog")
        dict.setValue(self.offsiteCatalog.stringValue, forKey: "offsiteCatalog")
        self.configurations!.addNewConfigurations(dict)
        self.newconfigurations?.appendnewConfigurations(dict: dict)
        self.tabledata = self.newconfigurations!.getnewConfigurations()
        globalMainQueue.async(execute: { () -> Void in
            self.newTableView.reloadData()
        })
        self.setFields()
    }
}

extension ViewControllerNewConfigurations: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.newconfigurations?.newConfigurationsCount() ?? 0
    }

}

extension ViewControllerNewConfigurations: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.newconfigurations?.getnewConfigurations() != nil else {
            return nil
        }
        let object: NSMutableDictionary = self.newconfigurations!.getnewConfigurations()![row]
        return object[tableColumn!.identifier] as? String
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        self.tabledata![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
    }
}

extension ViewControllerNewConfigurations: GetPath {

    func pathSet(path: String?, requester: WhichPath) {
        if let setpath = path {
            switch requester {
            case .addLocalCatalog:
                self.localCatalog.stringValue = setpath
            case .addRemoteCatalog:
                self.offsiteCatalog.stringValue = setpath
            default:
                break
            }
        }
    }
}

extension ViewControllerNewConfigurations: DismissViewController {

    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerNewConfigurations: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async(execute: { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        })
    }
}
