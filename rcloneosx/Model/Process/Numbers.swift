//
//  numbers.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.05.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  Class for crunching numbers from rsyn output.  Numbers are
//  informal only, either used in main view or for logging purposes.
//  swiftlint:disable syntactic_sugar

import Foundation

// enum for returning what is asked for
enum EnumNumbers {
    case totalNumber
    case totalDirs
    case totalNumberSizebytes
    case transferredNumber
    case transferredNumberSizebytes
    case new
    case delete
}

final class Numbers: SetConfigurations {

    private var output: Array<String>?
    // numbers after dryrun and stats
    var totNum: Int?
    var totDir: Int?
    var totNumSize: Double?
    var newfiles: Int?
    var deletefiles: Int?
    
    var transferNum: String?
    var transferNumSize: String?
    var transferNumSizeByte: String?
    var time: String?
    
    // Get numbers from rclone (dry run)
    func getTransferredNumbers (numbers: EnumNumbers) -> Int {
        switch numbers {
        case .totalDirs:
            return self.totDir ?? 0
        case .totalNumber:
            return self.totNum ?? 0
        case .transferredNumber:
            return Int(self.transferNum ?? "0")!
        case .totalNumberSizebytes:
            let size = self.totNumSize ?? 0
            return Int(size/1024 )
        case .transferredNumberSizebytes:
            let size = Int(self.transferNumSize ?? "0" )
            return Int(size!/1024)
        case .new:
            let num = self.newfiles ?? 0
            return Int(num)
        case .delete:
            let num = self.deletefiles ?? 0
            return Int(num)
        }
    }
    
    private func prepareresult() {
        let tempfiles = self.output!.filter({(($0).contains("Transferred:"))})
        let elapsedTime = self.output!.filter({(($0).contains("Elapsed time:"))})
        guard tempfiles.count >= 2 && elapsedTime.count >= 1  else { return }
        let index = tempfiles.count
        let index2 = elapsedTime.count
        var filesPartSize = tempfiles[index-2].components(separatedBy: " ").filter{ $0.isEmpty == false && $0 != "Transferred:"}
        let filesPart = tempfiles[index-1].components(separatedBy: " ").filter{ $0.isEmpty == false }
        let elapstedTimePart = elapsedTime[index2-1].components(separatedBy: " ").filter{ $0.isEmpty == false }
        if filesPart.count > 1 {self.transferNum = filesPart[filesPart.count - 1]} else {self.transferNum = "0"}
        if filesPartSize.count > 3 {
            self.transferNumSize = filesPartSize[0]
            self.transferNumSizeByte = filesPartSize[1]
        } else {
            self.transferNumSize = "0.0"
            self.transferNumSizeByte = "bytes"
        }
        if elapstedTimePart.count > 2 {self.time = elapstedTimePart[2]} else {self.time = "0.0"}
    }

    // Collecting statistics about job
    func stats() -> String {
        self.prepareresult()
        let num = self.transferNum ?? "0"
        let size = self.transferNumSize ?? "0"
        let byte = self.transferNumSizeByte ?? "bytes"
        let time = self.time ?? "0"
        return  num + " files," + " " + size + " " + byte  + " in " + time
    }

    init (output: OutputProcess?) {
        // Default number of files
        self.output = output!.getOutput()
        self.transferNum = String(self.output!.count)
    }
}
