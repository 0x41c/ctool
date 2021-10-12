//
//	FatFile.swift
//
// 	Created by Cero on 2021-10-05
//	Copyright © Cero, all rights reserved
//
	

import Foundation
import MachO

struct FatFile: BinaryFile {
    var data: Data
    var type: FileType = .fat
    var is64: Bool {
        return Self.is64(magic)
    }
    private var magic: UInt32 {
        return data.load()
    }
    
    lazy var header: fat_header = {
        var header: fat_header = data.load()
        swap_fat_header(&header, NXByteOrder(0))
        return header
    }()
    
    lazy var arches: [fat_arch] = {
        var arches: [fat_arch] = []
        var offset: Int = MemoryLayout<fat_header>.size
        for i in 0..<Int(header.nfat_arch) {
            var arch: fat_arch = data.load(byteOffset: offset + (i * MemoryLayout<fat_arch>.size))
            swap_fat_arch(&arch, 1, NXByteOrder(0))
            arches.append(arch)
            machFiles.append(MachOFile(withData: Data(data[arch.offset..<(arch.offset + arch.size)])))
        }
        return arches
    }()
    
    lazy var machFiles: [MachOFile] = []
    
    init(withPath: String) {
        let url: URL = URL(fileURLWithPath: withPath)
        do {
            self.data = try Data(contentsOf: url)
        } catch {
            fatalError("Unable to retreive file at path: \(withPath)")
        }
        guard FatFile.verifyMagic(magic) else {
            fatalError("Not a valid binary file at path: \(withPath)")
        }
        // Call Arches
        _ = self.arches
    }
    
    init(withData data: Data) {
        self.data = data
        _ = self.arches
    }
}
