//
//	String+BinaryString.swift
//
// 	Created by Cero on 2021-10-04
//	Copyright © Cero, all rights reserved
//
import MachO

typealias CharTuple = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)
extension String {
    static func fromBytes(_ bytes: UnsafePointer<CharTuple>) -> String {
        bytes.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: bytes)) { cString in
            return String(cString: cString)
        }
    }
}
