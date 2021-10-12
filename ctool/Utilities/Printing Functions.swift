//
//	Printing Functions.swift
//
// 	Created by Cero on 2021-10-06
//	Copyright © Cero, all rights reserved
//

import MachO

func printFatHeader(_ header: fat_header) {
    print("""
    ---
    fat_header
        ---
        Magic Number: \(magicName(header.magic)) \(FatFile.shouldSwap(header.magic) ? "(Big Endian)" : "(Little Endian)")
        Number Of Arches: \(header.nfat_arch)
        ---
    ---
    """)
}

func printHeader(_ header: mach_header_unified) {
    print("""
    ---
    mach_header\(header.is64 ? "_64" : "")
        ---
        Magic Number: \(magicName(header.magic)) \(header.swappedBits ? "(Big Endian)" : "(Little Endian)")
        64 Bit: \(header.is64 ? "yes" : "no")
        CPU Type: \(cpuTypeName(header.cpuType))
        CPU Subtype: \(header.cpuSubtype)
        File Type: \(fileTypeName(Int32(header.fileType)))
        Number Of Commands: \(header.numberOfCommands)
        Number Of Load Commands: \(header.loadCommands().count)
        Number Of Segment Commands: \(header.segmentCommands().count)
        Header Size: \(header.size)
        Commands Size: \(header.sizeOfCmds)
        ---
    ---
    """)
}

func printSegmentCommand(_ segment: segement_command_unified) {
    let _64 = segment.is64 ? "_64" : ""
    print("""
    ---
    segment_command\(_64)
        ---
        Command: \(segment.cmd) (LC_SEGMENT\(_64))
        Command Size: \(segment.cmdsize)
        File Size: \(segment.filesize)
        File Offset: \(segment.fileoff)
        Segment Name: \(segment.segname)
        Number of Sections: \(segment.nsects)
        Init VM Protection: \(segment.initprot) (\(vmProtName(segment.initprot)))
        Max VM Protection: \(segment.maxprot) (\(vmProtName(segment.maxprot)))
        VM Address (No ASLR): \(segment.vmaddr)
        VM Size: \(segment.vmsize)
        ---
    ---
    """)
}

func printSection(_ section: section_unified) {
    let _64 = section.is64 ? "_64" : ""
    print("""
    ---
    section\(_64)
        ---
        Segment Name: \(section.segname)
        Section Name: \(section.sectname)
        Section Size: \(section.size)
        File Offset: \(section.offset)
        Relocation Offset: \(section.reloff)
        Internal offset: \(section._offset)
        Address: \(section.addr.hex())
        Number of Relocations: \(section.nreloc)
        Reserved 1: \(section.reserved1)
        Reserved 2: \(section.reserved2)
        ---
    ---
    """)
}

func printVersionMinCommand(_ command: version_min_command) {
    print("""
    ---
    version_min_command
        ---
        OS Type: \(versionOSName(command))
        OS Version: \(osVersion(command.version))
        ---
    ---
    """)
}
