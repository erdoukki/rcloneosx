//
//  ViewControllerRsyncParameters.swift
//  Rsync
//  The ViewController for rsync parameters.
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar line_length

import Foundation
import Cocoa

// protocol for returning if userparams is updated or not
protocol RsyncUserParams: class {
    func rsyncuserparamsupdated()
}

// Protocol for sending selected index in tableView
// The protocol is implemented in ViewControllertabMain
protocol GetSelecetedIndex: class {
    func getindex() -> Int?
}

class ViewControllerRsyncParameters: NSViewController, SetConfigurations, SetDismisser, GetIndex {

    var storageapi: PersistentStorageAPI?
    // Object for calculating rsync parameters
    var parameters: RsyncParameters?
    // Delegate returning params updated or not
    weak var userparamsupdatedDelegate: RsyncUserParams?
    // Reference to rsync parameters to use in combox
    var comboBoxValues = Array<String>()

    @IBOutlet weak var viewParameter1: NSTextField!
    @IBOutlet weak var viewParameter2: NSTextField!
    @IBOutlet weak var viewParameter3: NSTextField!
    @IBOutlet weak var viewParameter4: NSTextField!
    @IBOutlet weak var viewParameter5: NSTextField!
    // user selected parameter
    @IBOutlet weak var viewParameter8: NSTextField!
    @IBOutlet weak var viewParameter9: NSTextField!
    @IBOutlet weak var viewParameter10: NSTextField!
    @IBOutlet weak var viewParameter11: NSTextField!
    @IBOutlet weak var viewParameter12: NSTextField!
    @IBOutlet weak var viewParameter13: NSTextField!
    @IBOutlet weak var viewParameter14: NSTextField!
    // Comboboxes
    @IBOutlet weak var parameter8: NSComboBox!
    @IBOutlet weak var parameter9: NSComboBox!
    @IBOutlet weak var parameter10: NSComboBox!
    @IBOutlet weak var parameter11: NSComboBox!
    @IBOutlet weak var parameter12: NSComboBox!
    @IBOutlet weak var parameter13: NSComboBox!
    @IBOutlet weak var parameter14: NSComboBox!

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userparamsupdatedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let profile = self.configurations!.getProfile() {
            self.storageapi = PersistentStorageAPI(profile: profile)
        } else {
            self.storageapi = PersistentStorageAPI(profile: nil)
        }
        var configurations: [Configuration] = self.configurations!.getConfigurations()
        if let index = self.index() {
            // Create RsyncParameters object and load initial parameters
            self.parameters = RsyncParameters(config: configurations[index])
            self.comboBoxValues = parameters!.getComboBoxValues()
            self.viewParameter1.stringValue = configurations[index].parameter1 ?? ""
            self.viewParameter2.stringValue = configurations[index].parameter2 ?? ""
            self.viewParameter3.stringValue = configurations[index].parameter3 ?? ""
            self.viewParameter4.stringValue = configurations[index].parameter4 ?? ""
            self.viewParameter5.stringValue = configurations[index].parameter5 ?? ""
            // There are seven user seleected rsync parameters
            self.setValueComboBox(combobox: self.parameter8, index: self.parameters!.getParameter(rsyncparameternumber: 8).0)
            self.viewParameter8.stringValue = self.parameters!.getParameter(rsyncparameternumber: 8).1
            self.setValueComboBox(combobox: self.parameter9, index: self.parameters!.getParameter(rsyncparameternumber: 9).0)
            self.viewParameter9.stringValue = self.parameters!.getParameter(rsyncparameternumber: 9).1
            self.setValueComboBox(combobox: self.parameter10, index: self.parameters!.getParameter(rsyncparameternumber: 10).0)
            self.viewParameter10.stringValue = self.parameters!.getParameter(rsyncparameternumber: 10).1
            self.setValueComboBox(combobox: self.parameter11, index: self.parameters!.getParameter(rsyncparameternumber: 11).0)
            self.viewParameter11.stringValue = self.parameters!.getParameter(rsyncparameternumber: 11).1
            self.setValueComboBox(combobox: self.parameter12, index: self.parameters!.getParameter(rsyncparameternumber: 12).0)
            self.viewParameter12.stringValue = self.parameters!.getParameter(rsyncparameternumber: 12).1
            self.setValueComboBox(combobox: self.parameter13, index: self.parameters!.getParameter(rsyncparameternumber: 13).0)
            self.viewParameter13.stringValue = self.parameters!.getParameter(rsyncparameternumber: 13).1
            self.setValueComboBox(combobox: self.parameter14, index: self.parameters!.getParameter(rsyncparameternumber: 14).0)
            self.viewParameter14.stringValue = self.parameters!.getParameter(rsyncparameternumber: 14).1

        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.parameters = nil
    }

    // Function for saving changed or new parameters for one configuration.
    @IBAction func update(_ sender: NSButton) {
        var configurations: [Configuration] = self.configurations!.getConfigurations()
        guard configurations.count > 0 else {
            return
        }
        // Get the index of selected configuration
        if let index = self.index() {
            configurations[index].parameter8 = self.parameters!.getRsyncParameter(indexComboBox:
                self.parameter8.indexOfSelectedItem, value: getValue(value: self.viewParameter8.stringValue))
            configurations[index].parameter9 = self.parameters!.getRsyncParameter(indexComboBox:
                self.parameter9.indexOfSelectedItem, value: getValue(value: self.viewParameter9.stringValue))
            configurations[index].parameter10 = self.parameters!.getRsyncParameter(indexComboBox:
                self.parameter10.indexOfSelectedItem, value: getValue(value: self.viewParameter10.stringValue))
            configurations[index].parameter11 = self.parameters!.getRsyncParameter(indexComboBox:
                self.parameter11.indexOfSelectedItem, value: getValue(value: self.viewParameter11.stringValue))
            configurations[index].parameter12 = self.parameters!.getRsyncParameter(indexComboBox:
                self.parameter12.indexOfSelectedItem, value: getValue(value: self.viewParameter12.stringValue))
            configurations[index].parameter13 = self.parameters!.getRsyncParameter(indexComboBox:
                self.parameter13.indexOfSelectedItem, value: getValue(value: self.viewParameter13.stringValue))
            configurations[index].parameter14 = self.parameters!.getRsyncParameter(indexComboBox:
                self.parameter14.indexOfSelectedItem, value: getValue(value: self.viewParameter14.stringValue))
            // Update configuration in memory before saving
            self.configurations!.updateConfigurations(configurations[index], index: index)
            // notify an update
            self.userparamsupdatedDelegate?.rsyncuserparamsupdated()
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // There are eight comboboxes
    // All eight are initalized during ViewDidLoad and
    // the correct index is set.
    private func setValueComboBox (combobox: NSComboBox, index: Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: self.comboBoxValues as [String]!)
        combobox.selectItem(at: index)
    }

    // Returns nil or value from stringvalue (rsync parameters)
    private func getValue(value: String) -> String? {
        if value.isEmpty {
            return nil
        } else {
            return value
        }
    }

}
