//
//	UnifiedMachHeader.swift
//
// 	Created by Cero on 2021-10-04
//	Copyright © Cero, all rights reserved
//
	

import MachO
import Foundation

/// A unified version of the two types: `mach_header`, and `mach_header_64`.
public struct mach_header_unified {
    
    //MARK: Native Properties
    
    /// The corresponding identifier for the header.
    ///
    /// This determines what kind of header it is.
    ///
    /// For normal magic we can leave it be and assume dominance over the information,
    /// but for the dark magic known as `CIGAM`, we have to do extra work.
    /// Depending on the type, we need to call a specific function to reverse the endianness.
    ///  ```swift
    ///  var header: mach_header
    ///  var header_64: mach_header_64
    ///  swap_mach_header(&header, NXByteOrder(0)) // 32 bit
    ///  swap_mach_header_64(&header_64, NCByteOrder(0)) // 64 bit
    ///  ```
    public let magic: UInt32
    
    /// The cpu specifier. Sort of like magic too!
    ///
    /// Determines the tyoe of cpu this binary was compiled for. Specific only to this `mach_header`
    public let cpuType: cpu_type_t
    
    /// The machine specifier.
    ///
    /// This shows the capabilities of the CPU this was built for.
    public let cpuSubtype: cpu_subtype_t
    
    /// The type of the file
    public let fileType: UInt32
    
    /// Number of load commands in the file. This allows the machine to iterate through them.
    ///
    /// Note, commands are of type `load_command`
    public let numberOfCommands: UInt32
    
    /// The size of all the load commands
    public let sizeOfCmds: UInt32
    
    /// Cool flags that will melt your brain
    public let flags: UInt32
    
    // MARK: Non-Native properties
    
    private var data: Data
    
    /// Reads `magic` to determine whether the binary is 64 bit
    public var is64: Bool {
        return magic == MH_MAGIC_64 || magic == MH_CIGAM_64
    }
    
    /// Reads `magic` to determine whether it is under `MH_CIGAM`
    public var swappedBits: Bool {
        return magic == MH_CIGAM_64 || magic == MH_CIGAM
    }
    
    /// Takes a `magic` number to determine whether the binary is 64 bit
    static func is64(_ magicNumber: UInt32) -> Bool {
        return magicNumber == MH_MAGIC_64 || magicNumber == MH_CIGAM_64
    }
    
    ///Takes a `magic` number to determine whether it is under `MH_CIGAM`
    static func swappedBits(_ magicNumber: UInt32) -> Bool {
        return magicNumber == MH_CIGAM_64 || magicNumber == MH_CIGAM
    }
    
    /// The size of the `mach_header` which gets used to calculate other properties
    public var size: Int {
        if is64 {
            return MemoryLayout<mach_header_64>.size
        }
        return MemoryLayout<mach_header>.size
    }
    
//    public var flagsArray: [String] {
//        var flags: [String] = []
//
//        return flags
//    }
    
    /// Load commands immediately following the `mach_header`
    func loadCommands() -> [load_command] {
        var ldCommands: [load_command] = []
        var currentOffset: Int = size
        for _ in 0..<numberOfCommands {
            var loadCommand: load_command = data.load(byteOffset: currentOffset)
            if swappedBits {
                swap_load_command(&loadCommand, NXByteOrder(0))
            }
            
            // This will not trigger on LC_SEGMENT with segname of __PAGEZERO unless malformed macho
            if loadCommand.cmdsize > 0 {
                ldCommands.append(loadCommand)
                currentOffset += Int(loadCommand.cmdsize)
            }
        }
        return ldCommands
    }
    /// A sifted through array of "`load_command`"s that are of the `segment_command` command type
    func segmentCommands() -> [segement_command_unified] {
        var segCommands: [segement_command_unified] = []
        var currentOffset: Int = size
        for loadCommand in loadCommands() {
            if loadCommand.cmd == LC_SEGMENT || loadCommand.cmd == LC_SEGMENT_64 {
                let segment = segement_command_unified(withData: data, offset: currentOffset, header: self)
                segCommands.append(segment)
            }
            currentOffset += Int(loadCommand.cmdsize)
        }
        return segCommands
    }
    
    func versionMinCommand() -> version_min_command? {
        var currentOffset: Int = size
        var versionMinCommand: version_min_command?
        for command in loadCommands() {
            if [
                LC_VERSION_MIN_MACOSX,
                LC_VERSION_MIN_IPHONEOS,
                LC_VERSION_MIN_WATCHOS,
                LC_VERSION_MIN_TVOS
            ].contains(Int32(bitPattern: command.cmd)) {
                versionMinCommand = data.load(byteOffset: currentOffset)
                break;
            }
            currentOffset += Int(command.cmdsize)
        }
        return versionMinCommand
    }
    
    func entryPointCommand() -> entry_point_command? {
        var currentOffset: Int = size
        var entryCommand: entry_point_command?
        for command in loadCommands() {
            if command.cmd == LC_MAIN {
                entryCommand = data.load(byteOffset: currentOffset)
                break;
            }
            currentOffset += Int(command.cmdsize)
        }
        return entryCommand
    }
    
    /// Init using a 32 bit header
    private init(_ header: mach_header, _ data: Data) {
        self.magic = header.magic
        self.cpuType = header.cputype
        self.cpuSubtype = header.cpusubtype
        self.fileType = header.filetype
        self.numberOfCommands = header.sizeofcmds
        self.sizeOfCmds = header.sizeofcmds
        self.flags = header.flags
        self.data = data
    }
    
    /// Init using a 64 bit header
    private init(_ header: mach_header_64,_ data: Data) {
        self.magic = header.magic
        self.cpuType = header.cputype
        self.cpuSubtype = header.cpusubtype
        self.fileType = header.filetype
        self.numberOfCommands = header.sizeofcmds
        self.sizeOfCmds = header.sizeofcmds
        self.flags = header.flags
        self.data = data
    }
    /// Init with the raw data of a file
    public init(withData data: Data) {
        let magic: UInt32 = data.load()
        let is64 = mach_header_unified.is64(magic)
        let swappedBits = mach_header_unified.swappedBits(magic)
        
        if is64 {
            var header: mach_header_64 = data.load()
            if swappedBits {
                swap_mach_header_64(&header, NXByteOrder(0))
            }
            self.init(header, data)
        } else {
            var header: mach_header = data.load()
            if swappedBits {
                swap_mach_header(&header, NXByteOrder(0))
            }
            self.init(header, data)
        }
    }
}
