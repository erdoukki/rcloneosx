//
//  Fileerrors.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 21.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum fileerrortype {
    case openlogfile
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
}

// Protocol for reporting file errors
protocol Fileerror: class {
    func fileerror(errorstr: String, errortype: fileerrortype)
}

protocol Reportfileerror {
    weak var errorDelegate: Fileerror? { get }
}

extension Reportfileerror {
    weak var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    
    func error(error: String, errortype: fileerrortype) {
        self.errorDelegate?.fileerror(errorstr: error, errortype: errortype)
    }
}

class Filerrors {
    
    private var errortype: fileerrortype?
    
    func errordescription() -> String {
        switch self.errortype! {
        case .openlogfile:
            return "Could not open logfile"
        case .writelogfile:
            return "Could not write to logfile"
        case .profilecreatedirectory:
            return "Could not create profile directory"
        case .profiledeletedirectory:
            return "Could not delete profile directory"
        }
     }

    init(errortype: fileerrortype) {
        self.errortype = errortype
    }
}
