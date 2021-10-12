//
//	MOFile.swift
//
// 	Created by Cero on 2021-10-04
//	Copyright © Cero, all rights reserved
//
	
import MachO
import Foundation
import Capstone

//TODO: Document this file

/// Represents the `MachO` part of a binary file. Can be alone, or joined by other architectures
struct MachOFile: BinaryFile {
    /// The `Data`. Can be a slice of the entire file or singular.
    var data: Data
    
    /// The type determines which type of binary file this is
    var type: FileType = .macho
    
    lazy var capstone: Capstone = {
        var _self = self
        var name = cpuTypeName(_self.header.cpuType)
        func getMode() -> Any {
            if name == "arm" || name == "arm64" {
                return Mode.arm.arm
            }
            if name == "x86_64" {
                return Mode.bits.b64
            }
            return Mode.bits.b32
        }
        
        do {
            return (
                try Capstone(
                    arch: capstoneArch(fromString: name)!,
                        mode: getMode() as! Mode
                )
            )
        } catch {
            fatalError("hit \(error)")
        }
    }()
    
    /// The `magic` located at the very start of a `mach_header`
    private var magic: UInt32 {
        return data.load()
    }
    
    /// A unified version of` mach_header`
    lazy var header: mach_header_unified = {
        return mach_header_unified(withData: data)
    }()
    
    init(withPath path: String) {
        let url: URL = URL(fileURLWithPath: path)
        do {
            self.data = try Data(contentsOf: url)
        } catch {
            fatalError("Unable to retreive file at path: \(path)")
        }
        
        guard MachOFile.verifyMagic(magic) else {
            fatalError("Not a valid binary file at path: \(path)")
        }
    }
    
    init(withData data: Data) {
        self.data = data
    }
}
