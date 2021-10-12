//
//	UnifiedSegmentCommand.swift
//
// 	Created by Cero on 2021-10-04
//	Copyright © Cero, all rights reserved
//
	

import MachO
import Foundation

/// Unified version of `segment_command` to merge both 32 and 64 bit archs
public struct segement_command_unified {
    
    /// The command type.
    ///
    /// Shared with `load_command`. This value will be one of the following:
    ///  - `LC_SEGMENT`
    ///  - `LC_SEGMENT_64`
    public var cmd: UInt32
    
    /// The size of the command including the sizes of the `section` or `section_64`s below it
    public var cmdsize: UInt32
    
    /// The name of the segment.
    ///
    /// Usually prefixed by `__` these segments contain the information of what data
    /// or information is being laid out. `segment_commmand_unified`s are identified by
    /// their `segname`
    public var segname: String // hahaha kill me plz
    
    /// The virtual memory address of the segment.
    public var vmaddr: UInt64
    
    /// Virtual Memory size of the segment
    public var vmsize: UInt64

    /// The physical file offset of the segment in bytes
    public var fileoff: UInt64

    /// The physical file size of the segment
    public var filesize: UInt64
    
    /// The maximum VM protection for the segment
    public var maxprot: vm_prot_t
    
    /// The initial VM protection of the segment
    public var initprot: vm_prot_t

    /// The number of sections in this segment.
    public var nsects: UInt32

    /// The corrosponding section flags
    ///
    /// Can be any one of the following:
    /// - `SG_HIGHVM` This segment only uses high part of VM space and zeros out the rest
    /// - `SG_FVMLIB` This segment is virtual memory for overlap checking (allocated a the fixed VM library)
    /// - `SG_NORELOC` No relocation has happened involving this segment, so replacement of this segment can happen without relocation as well.
    /// - `SG_PROTECTED_VERSION_1` This segment is protected unless it is located at file offset 0; The first page won't be protected but the rest of the segment will.
    /// - `SG_READ_ONLY` This segment is read only
    public var flags: UInt32
    
    /// Whether this segment is the 64 bit variant
    public var is64: Bool {
        return _header!.is64
    }
    
    private var _header: mach_header_unified?
    
    private var data: Data
    
    private var _size: Int {
        if _header!.is64 {
            return MemoryLayout<segment_command_64>.size
        }
        return MemoryLayout<segment_command>.size
    }
    
    private var _initOffset: Int
    
    /// Sections
    func sections() -> [section_unified] {
        var ret: [section_unified] = []
        var sectionOffset = _size + _initOffset
        for _ in 0..<nsects {
            let section: section_unified = section_unified(withData: data, offset: sectionOffset, header: _header!)
            ret.append(section)
            if _header!.is64 {
                sectionOffset += MemoryLayout<section_64>.size
            } else {
                sectionOffset += MemoryLayout<section>.size
            }
        }
        return ret
    }
    
    private init(_ segment: segment_command,_ data: Data, _ offset: Int) {
        var segment = segment
        self.cmd = segment.cmd
        self.cmdsize = segment.cmdsize
        self.segname = String.fromBytes(&segment.segname)
        self.vmaddr = UInt64(segment.vmaddr)
        self.vmsize = UInt64(segment.vmsize)
        self.fileoff = UInt64(segment.fileoff)
        self.filesize = UInt64(segment.filesize)
        self.maxprot = segment.maxprot
        self.initprot = segment.initprot
        self.nsects = segment.nsects
        self.flags = segment.flags
        self.data = data
        self._initOffset = offset
    }
    
    private init(_ segment: segment_command_64,_ data: Data, _ offset: Int) {
        var segment = segment
        self.cmd = segment.cmd
        self.cmdsize = segment.cmdsize
        self.segname = String.fromBytes(&segment.segname)
        self.vmaddr = segment.vmaddr
        self.vmsize = segment.vmsize
        self.fileoff = segment.fileoff
        self.filesize = segment.filesize
        self.maxprot = segment.maxprot
        self.initprot = segment.initprot
        self.nsects = segment.nsects
        self.flags = segment.flags
        self.data = data
        self._initOffset = offset
    }
    
    public init(withData data: Data, offset: Int, header: mach_header_unified) {
        if header.is64 {
            var segment: segment_command_64 = data.load(byteOffset: offset)
            if header.swappedBits {
                swap_segment_command_64(&segment, NXByteOrder(0))
            }
            self.init(segment, data, offset)
        } else {
            var segment: segment_command = data.load(byteOffset: offset)
            if header.swappedBits {
                swap_segment_command(&segment, NXByteOrder(0))
            }
            self.init(segment, data, offset)
        }
        self._header = header
    }
}
