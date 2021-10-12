//
//	Int+hex.swift
//
// 	Created by Cero on 2021-10-11
//	Copyright © Cero, all rights reserved
//
	

import Foundation

func toHex(_ number: Int) -> String {
    var ret = String(format: "%02X", number)
    if ret.count < 6 {
        let difference = 6 - ret.count
        ret = String(repeating: "0", count: difference) + ret.lowercased()
    }
    return "0x" + ret
}

extension Int {
    func hex() -> String {
        return toHex(self)
    }
}

extension Int32 {
    func hex() -> String {
        return toHex(Int(self))
    }
}

extension Int64 {
    func hex() -> String {
        return toHex(Int(self))
    }
}

extension UInt32 {
    func hex() -> String {
        return toHex(Int(self))
    }
}

extension UInt64 {
    func hex() -> String {
        return toHex(Int(self))
    }
}
