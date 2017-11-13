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

    private var outputprocess: Array<String>?
    // numbers after dryrun and stats
    var totNum: Int?
    var totDir: Int?
    var totNumSize: Double?
    var newfiles: Int?
    var deletefiles: Int?
    
    var transferNum: String?
    var transferNumSize: String?
    var time: String?
    
    // Temporary numbers
    var files: String?
    var filesSize: String?
    var elapsedTime: Array<String>?
    var totfilesNum: Array<String>?
    var new: Array<String>?
    var delete: Array<String>?
    var tempfiles: Array<String>?

    // Get numbers from rclone (dry run)
    func getTransferredNumbers (numbers: EnumNumbers) -> Int {
        switch numbers {
        case .totalDirs:
            return self.totDir ?? 0
        case .totalNumber:
            return self.totNum ?? 0
        case .transferredNumber:
            return Int(self.transferNum!) ?? 0
        case .totalNumberSizebytes:
            let size = self.totNumSize ?? 0
            return Int(size/1024 )
        case .transferredNumberSizebytes:
            let size = Int(self.transferNumSize!) ?? 0
            return Int(size/1024)
        case .new:
            let num = self.newfiles ?? 0
            return Int(num)
        case .delete:
            let num = self.deletefiles ?? 0
            return Int(num)
        }
    }

    private func resultrclone() {
        let filesPart = self.files!.replacingOccurrences(of: ",", with: "").components(separatedBy: " ").filter{ $0.isEmpty == false }
        let filesPartSize = self.filesSize!.replacingOccurrences(of: ",", with: "").components(separatedBy: " ").filter{ $0.isEmpty == false }
        let elapstedTimePart = self.elapsedTime![0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ").filter{ $0.isEmpty == false }
        if filesPart.count > 1 {self.transferNum = filesPart[filesPart.count - 1]} else {self.transferNum = "0"}
        if filesPartSize.count > 4 {self.transferNumSize = filesPartSize[1]} else {self.transferNumSize = "0.0"}
        if elapstedTimePart.count > 2 {self.time = elapstedTimePart[2]} else {self.time = "0.0"}
    }

    // Collecting statistics about job
    func stats() -> String {
        let num = self.transferNum ?? "0"
        let size = self.filesSize ?? "0"
        let time = self.time ?? "0"
        return  num + " files," + " " + size + " in " + time
    }

    init (output: OutputProcess?) {
        self.outputprocess = output!.trimoutput(trim: .two)
        self.tempfiles = self.outputprocess!.filter({(($0).contains("Transferred:"))})
        self.elapsedTime = self.outputprocess!.filter({(($0).contains("Elapsed time:"))})
        if tempfiles?.count == 2 && elapsedTime!.count == 1  {
            self.filesSize = self.tempfiles![0]
            self.files = self.tempfiles![1]
            self.resultrclone()
        } else {
            // If it breaks set number of transferred files to size of output.
            self.transferNum = String(self.outputprocess!.count)
        }
    }
}
