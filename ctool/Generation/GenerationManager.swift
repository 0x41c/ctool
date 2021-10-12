//
//	GenerationManager.swift
//
// 	Created by Cero on 2021-10-07
//	Copyright © Cero, all rights reserved
//
	

import Foundation
import MachO
import Capstone

struct GenerationManager {
    
    var generationChildren: [GenerationChild]
    
    init(withFile file: BinaryFile) {
        if file.type == .macho {
            self.generationChildren = [GenerationChild(file: file as! MachOFile)]
        } else {
            var fatVersion: FatFile = file as! FatFile
            self.generationChildren = []
            let files: [MachOFile] = fatVersion.machFiles
            for machFiles in files {
                self.generationChildren.append(GenerationChild(file: machFiles))
            }
        }
    }
    
    init(withPath: String) {
        self.init(withFile: AnyFile.create(withPath: withPath))
    }
}

struct GenerationChild {
    var file: MachOFile
    
    mutating func rawAssembly() -> String {
        var _self = self
        var retString: String = ""
        let manager: Capstone = file.capstone
        do {
            try manager.set(option: .detail(value: true))
            try manager.set(option: .skipDataEnabled(true))
            
        } catch {
            
        }
        for section in _self.file.header.segmentCommands()[1].sections() {
            printSection(section)
        }
        for section in _self.file.header.segmentCommands()[1].sections() {
            do {
                try manager.set(option: .syntax(syntax: .intel))
                let instructions: [Instruction] = try manager.disassemble(code: file.data.dataWithOffset(Int(section.offset), Int(section.size))!, address: 0x0)
                for instruction in instructions {
                    let slice: String = "\(instruction.address): \(instruction.mnemonic), \(instruction.operandsString)"
                    retString += slice + "\n"
                }
            } catch {
                return ""
            }
        }
        print(retString)
        return retString
    }
}
