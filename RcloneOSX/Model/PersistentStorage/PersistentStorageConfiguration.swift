//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar function_body_length cyclomatic_complexity

import Foundation

final class PersistentStorageConfiguration: Readwritefiles, SetConfigurations {

    /// Variable holds all configuration data from persisten storage
    private var configurationsAsNSDict: [NSDictionary]?

    /// Variable computes max hiddenID used
    /// MaxhiddenID is used when new configurations are added.
    private var maxhiddenID: Int {
        // Reading Configurations from memory
        let store: [Configuration] = self.configurations!.getConfigurations()
        if store.count > 0 {
            _ = store.sorted { (config1, config2) -> Bool in
                if config1.hiddenID > config2.hiddenID {
                    return true
                } else {
                    return false
                }
            }
            let index = store.count-1
            return store[index].hiddenID
        } else {
            return 0
        }
    }

    /// Function reads configurations from permanent store
    /// - returns : array of NSDictonarys, return might be nil if configuration is already in memory
    func readConfigurationsFromPermanentStore() -> [NSDictionary]? {
        return self.configurationsAsNSDict
    }

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        var array = Array<NSDictionary>()
        // Reading Configurations from memory
        let configs: [Configuration] = self.configurations!.getConfigurations()
        for i in 0 ..< configs.count {
            array.append(self.dictionaryFromconfig(index: i))
        }
        // Write array to persistent store
        self.writeToStore(array)
    }

    // Add new configuration in memory to permanent storage
    // NB : Function does NOT store Configurations to persistent store
    func newConfigurations (_ dict: NSMutableDictionary) {
        var array = Array<NSDictionary>()
        // Get existing configurations from memory
        let configs: [Configuration] = self.configurations!.getConfigurations()
        // copy existing backups before adding
        for i in 0 ..< configs.count {
            array.append(self.dictionaryFromconfig(index: i))
        }
        dict.setObject(self.maxhiddenID + 1, forKey: "hiddenID" as NSCopying)
        array.append(dict)
        self.configurations!.appendconfigurationstomemory(dict: array[array.count - 1])
    }

    // Function for returning a NSMutabledictionary from a configuration record
    private func dictionaryFromconfig (index: Int) -> NSMutableDictionary {
        var config: Configuration = self.configurations!.getConfigurations()[index]
        let dict: NSMutableDictionary = [
            "task": config.task,
            "backupID": config.backupID,
            "localCatalog": config.localCatalog,
            "offsiteCatalog": config.offsiteCatalog,
            "batch": config.batch,
            "offsiteServer": config.offsiteServer,
            "dryrun": config.dryrun,
            "dateRun": config.dateRun!,
            "hiddenID": config.hiddenID]
        // All parameters parameter8 - parameter14 are set
        config.parameter1 = self.checkparameter(param: config.parameter1)
        if config.parameter1 != nil {
            dict.setObject(config.parameter1!, forKey: "parameter1" as NSCopying)
        }
        config.parameter2 = self.checkparameter(param: config.parameter2)
        if config.parameter2 != nil {
            dict.setObject(config.parameter2!, forKey: "parameter2" as NSCopying)
        }
        config.parameter3 = self.checkparameter(param: config.parameter3)
        if config.parameter3 != nil {
            dict.setObject(config.parameter3!, forKey: "parameter3" as NSCopying)
        }
        config.parameter4 = self.checkparameter(param: config.parameter4)
        if config.parameter4 != nil {
            dict.setObject(config.parameter4!, forKey: "parameter4" as NSCopying)
        }
        config.parameter5 = self.checkparameter(param: config.parameter5)
        if config.parameter5 != nil {
            dict.setObject(config.parameter5!, forKey: "parameter5" as NSCopying)
        }
        config.parameter6 = self.checkparameter(param: config.parameter6)
        if config.parameter6 != nil {
            dict.setObject(config.parameter6!, forKey: "parameter6" as NSCopying)
        }
        config.parameter8 = self.checkparameter(param: config.parameter8)
        if config.parameter8 != nil {
            dict.setObject(config.parameter8!, forKey: "parameter8" as NSCopying)
        }
        config.parameter9 = self.checkparameter(param: config.parameter9)
        if config.parameter9 != nil {
            dict.setObject(config.parameter9!, forKey: "parameter9" as NSCopying)
        }
        config.parameter10 = self.checkparameter(param: config.parameter10)
        if config.parameter10 != nil {
            dict.setObject(config.parameter10!, forKey: "parameter10" as NSCopying)
        }
        config.parameter11 = self.checkparameter(param: config.parameter11)
        if config.parameter11 != nil {
            dict.setObject(config.parameter11!, forKey: "parameter11" as NSCopying)
        }
        config.parameter12 = self.checkparameter(param: config.parameter12)
        if config.parameter12 != nil {
            dict.setObject(config.parameter12!, forKey: "parameter12" as NSCopying)
        }
        config.parameter13 = self.checkparameter(param: config.parameter13)
        if config.parameter13 != nil {
            dict.setObject(config.parameter13!, forKey: "parameter13" as NSCopying)
        }
        config.parameter14 = self.checkparameter(param: config.parameter14)
        if config.parameter14 != nil {
            dict.setObject(config.parameter14!, forKey: "parameter14" as NSCopying)
        }
        return dict
    }

    private func checkparameter (param: String?) -> String? {
        if let parameter = param {
            guard parameter.isEmpty == false else { return nil }
            return parameter
        } else { return nil }
    }

    // Function for setting the restore part of newly created added configuration
    // based on dictionary for backup part.
    private func setRestorePart (dict: NSMutableDictionary) -> NSMutableDictionary {
        let restore: NSMutableDictionary = [
            "task": "restore",
            "backupID": dict.value(forKey: "backupID")!,
            "localCatalog": dict.value(forKey: "localCatalog")!,
            "offsiteCatalog": dict.value(forKey: "offsiteCatalog")!,
            "batch": dict.value(forKey: "batch")!,
            "offsiteServer": dict.value(forKey: "offsiteServer")!,
            "offsiteUsername": dict.value(forKey: "offsiteUsername")!,
            "dryrun": dict.value(forKey: "dryrun")!,
            "dateRun": "",
            "hiddenID": self.maxhiddenID + 2]
        if dict.value(forKey: "parameter1") != nil {
            restore.setObject(dict.value(forKey: "parameter1")!, forKey: "parameter1" as NSCopying)
        }
        if dict.value(forKey: "parameter2") != nil {
            restore.setObject(dict.value(forKey: "parameter2")!, forKey: "parameter2" as NSCopying)
        }
        if dict.value(forKey: "parameter3") != nil {
            restore.setObject(dict.value(forKey: "parameter3")!, forKey: "parameter3" as NSCopying)
        }
        if dict.value(forKey: "parameter4") != nil {
            restore.setObject(dict.value(forKey: "parameter4")!, forKey: "parameter4" as NSCopying)
        }
        if dict.value(forKey: "parameter5") != nil {
            restore.setObject(dict.value(forKey: "parameter5")!, forKey: "parameter5" as NSCopying)
        }
        if dict.value(forKey: "parameter6") != nil {
            restore.setObject(dict.value(forKey: "parameter6")!, forKey: "parameter6" as NSCopying)
        }
        if dict.value(forKey: "parameter8") != nil {
            restore.setObject(dict.value(forKey: "parameter8")!, forKey: "parameter8" as NSCopying)
        }
        if dict.value(forKey: "parameter9") != nil {
            restore.setObject(dict.value(forKey: "parameter9")!, forKey: "parameter9" as NSCopying)
        }
        if dict.value(forKey: "parameter10") != nil {
            restore.setObject(dict.value(forKey: "parameter10")!, forKey: "parameter10" as NSCopying)
        }
        if dict.value(forKey: "parameter11") != nil {
            restore.setObject(dict.value(forKey: "parameter11")!, forKey: "parameter11" as NSCopying)
        }
        if dict.value(forKey: "parameter12") != nil {
            restore.setObject(dict.value(forKey: "parameter12")!, forKey: "parameter12" as NSCopying)
        }
        if dict.value(forKey: "parameter13") != nil {
            restore.setObject(dict.value(forKey: "parameter13")!, forKey: "parameter13" as NSCopying)
        }
        if dict.value(forKey: "parameter14") != nil {
            restore.setObject(dict.value(forKey: "parameter14")!, forKey: "parameter14" as NSCopying)
        }
        if dict.value(forKey: "rsyncdaemon") != nil {
            restore.setObject(dict.value(forKey: "rsyncdaemon")!, forKey: "rsyncdaemon" as NSCopying)
        }
        return restore
    }

    // Writing configuration to persistent store
    // Configuration is Array<NSDictionary>
    private func writeToStore (_ array: Array<NSDictionary>) {
        if (self.writeDatatoPersistentStorage(array, task: .configuration)) {
            self.configurationsDelegate?.reloadconfigurationsobject()
        }
    }

    init (profile: String?) {
        super.init(task: .configuration, profile: profile)
        if self.configurations == nil {
            self.configurationsAsNSDict = self.getDatafromfile()
        }
    }
}
