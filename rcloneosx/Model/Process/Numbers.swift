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
    var transferNum: Int?
    var transferNumSize: Double?
    var newfiles: Int?
    var deletefiles: Int?
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
            return self.transferNum ?? 0
        case .totalNumberSizebytes:
            let size = self.totNumSize ?? 0
            return Int(size/1024 )
        case .transferredNumberSizebytes:
            let size = self.transferNumSize ?? 0
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
        if filesPart.count > 1 {self.transferNum = Int(filesPart[filesPart.count - 1])} else {self.transferNum = 0}
        if filesPartSize.count > 4 {self.transferNumSize = Double(filesPartSize[1])} else {self.transferNumSize = 0}
        if elapstedTimePart.count > 2 {self.time = elapstedTimePart[2]} else {self.time = "0"}
    }

    // Collecting statistics about job
    func stats(numberOfFiles: String?, sizeOfFiles: String?) -> Array<String> {
        var numbers: String?
        var parts: Array<String>?
        
        var resultsent: String?
        var resultreceived: String?
        var result: String?
        var bytesTotalsent: Double = 0
        var bytesTotalreceived: Double = 0
        var bytesTotal: Double = 0
        var bytesSec: Double = 0
        var seconds: Double = 0
        guard parts!.count > 9 else {return ["0", "0"]}
        guard Double(parts![1]) != nil && (Double(parts![5]) != nil) && (Double(parts![8]) != nil) else {
            return ["0", "0"]
        }
        // Sent
        resultsent = parts![1] + " bytes in "
        bytesTotalsent = Double(parts![1])!
        // Received
        resultreceived = parts![5] + " bytes in "
        bytesTotalreceived = Double(parts![5])!
        if bytesTotalsent > bytesTotalreceived {
            // backup task
            result = resultsent! + parts![8] + " b/sec"
            bytesSec = Double(parts![8])!
            seconds = bytesTotalsent/bytesSec
            bytesTotal = bytesTotalsent
        } else {
            // restore task
            result = resultreceived! + parts![8] + " b/sec"
            bytesSec = Double(parts![8])!
            seconds = bytesTotalreceived/bytesSec
            bytesTotal = bytesTotalreceived
        }
        numbers = self.formatresult(numberOfFiles: numberOfFiles, bytesTotal: bytesTotal, seconds: seconds)
        return [numbers!, result ?? "hmmm...."]
    }

    private func formatresult(numberOfFiles: String?, bytesTotal: Double, seconds: Double) -> String {
        // Dont have numbers of file as input
        if numberOfFiles == nil {
            return String(self.outputprocess!.count) + " files : " +
                String(format: "%.2f", (bytesTotal/1024)/1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        } else {
            return numberOfFiles! + " files : " +
                String(format: "%.2f", (bytesTotal/1024)/1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        }
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
            self.transferNum = self.outputprocess!.count
        }
    }
}
