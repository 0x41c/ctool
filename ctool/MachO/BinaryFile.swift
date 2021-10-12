//
//	BinaryFile.swift
//
// 	Created by Cero on 2021-10-05
//	Copyright © Cero, all rights reserved
//
	

import Foundation
import MachO
import Capstone
enum FileType {
    case fat
    case macho
}

protocol BinaryFile {
    var data: Data { get }
    var type: FileType { get }
    static func verifyMagic(_ magic: UInt32) -> Bool
}

extension BinaryFile {
    static func verifyMagic(_ magic: UInt32) -> Bool {
        return [
            MH_CIGAM,
            MH_CIGAM_64,
            MH_MAGIC,
            MH_MAGIC_64,
            FAT_CIGAM,
            FAT_CIGAM_64,
            FAT_MAGIC,
            FAT_MAGIC_64,
        ].contains(magic)
    }
    
    static func isFat(_ magic: UInt32) -> Bool {
        return [
            FAT_MAGIC,
            FAT_MAGIC_64,
            FAT_CIGAM,
            FAT_CIGAM_64
        ].contains(magic)
    }
    
    static func shouldSwap(_ magic: UInt32) -> Bool {
        return [
            MH_CIGAM,
            MH_CIGAM_64,
            FAT_CIGAM,
            FAT_CIGAM_64
        ].contains(magic)
    }
    
    static func is64(_ magic: UInt32) -> Bool {
        return [
            MH_CIGAM_64,
            MH_MAGIC_64,
            FAT_CIGAM_64,
            FAT_MAGIC_64,
        ].contains(magic)
    }
    static func create(withPath: String) -> BinaryFile {
        if FileManager.default.fileExists(atPath: withPath)  {
            do {
                let data: Data = try Data(contentsOf: URL(fileURLWithPath: withPath))
                let magic: UInt32 = data.load()
                if Self.isFat(magic) {
                    return FatFile(withData: data) as BinaryFile
                } else {
                    return MachOFile(withData: data) as BinaryFile
                }
            } catch {
                fatalError("I should really make better things to warn you about issues shouldn't I?")
            }
        } else {
            fatalError("Houston we have a problem")
        }
    }
}

struct AnyFile: BinaryFile {
    var data: Data
    var type: FileType
}
