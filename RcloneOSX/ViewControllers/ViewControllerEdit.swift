//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerEdit: NSViewController, SetConfigurations, SetDismisser, GetIndex, Delay {

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var cloudService: NSComboBox!
    @IBOutlet weak var backupID: NSTextField!

    var index: Int?
    var outputprocess: OutputProcess?

    // Close and dismiss view
    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_ sender: NSButton) {
        var config: [Configuration] = self.configurations!.getConfigurations()
        config[self.index!].localCatalog = self.localCatalog.stringValue
        config[self.index!].offsiteCatalog = self.offsiteCatalog.stringValue
        config[self.index!].offsiteServer = self.cloudService.stringValue
        config[self.index!].backupID = self.backupID.stringValue
        self.configurations!.updateConfigurations(config[self.index!], index: self.index!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.backupID.stringValue = ""
        self.index = self.index()
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        self.localCatalog.stringValue = config.localCatalog
        self.offsiteCatalog.stringValue = config.offsiteCatalog
        self.cloudService.stringValue = config.offsiteServer
        self.backupID.stringValue = config.backupID
        self.loadCloudServices()
    }

    private func loadCloudServices() {
        guard ViewControllerReference.shared.norsync == false else {
            return
        }
        self.outputprocess = nil
        self.outputprocess = OutputProcess()
        _ = GetCloudServices(outputprocess: self.outputprocess)
        self.cloudService.removeAllItems()
        self.delayWithSeconds(0.5) {
            self.cloudService.addItems(withObjectValues: self.outputprocess!.trimoutput(trim: .three)!)
        }
    }

}
