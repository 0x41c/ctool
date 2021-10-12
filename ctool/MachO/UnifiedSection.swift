//
//	UnifiedSection.swift
//
// 	Created by Cero on 2021-10-04
//	Copyright © Cero, all rights reserved
//
	
import MachO
import Foundation

//TODO: Document this file

public struct section_unified {
    
    public var sectname: String

    public var segname: String

    public var addr: UInt64

    public var size: UInt64

    public var offset: UInt32

    public var align: UInt32

    public var reloff: UInt32

    public var nreloc: UInt32

    public var flags: UInt32

    public var reserved1: UInt32

    public var reserved2: UInt32

    public var is64: Bool {
        return _header!.is64
    }
    
    public var dataCopy: Data {
        return Data(_data!.dataWithOffset(_offset, Int(self.size))!)
    }
    
    var _offset: Int
    private var _data: Data?
        
    private var _header: mach_header_unified?
    
    private init(_ section: section, _ ioffset: Int) {
        var section = section
        self.sectname = String.fromBytes(&section.sectname)
        self.segname = String.fromBytes(&section.segname)
        self.addr = UInt64(section.addr)
        self.size = UInt64(section.size)
        self.offset = section.offset
        self.align = section.align
        self.reloff = section.reloff
        self.nreloc = section.nreloc
        self.flags = section.flags
        self.reserved1 = section.reserved1
        self.reserved2 = section.reserved2
        self._offset = ioffset
    }
    
    private init(_ section: section_64, _ ioffset: Int) {
        var section = section
        self.sectname = String.fromBytes(&section.sectname)
        self.segname = String.fromBytes(&section.segname)
        self.addr = section.addr
        self.size = section.size
        self.offset = section.offset
        self.align = section.align
        self.reloff = section.reloff
        self.nreloc = section.nreloc
        self.flags = section.flags
        self.reserved1 = section.reserved1
        self.reserved2 = section.reserved2
        self._offset = ioffset
    }
    
    public init(withData data: Data, offset: Int, header: mach_header_unified) {
        if header.is64 {
            var section: section_64 = data.load(byteOffset: offset)
            if header.swappedBits {
                swap_section_64(&section, 1, NXByteOrder(0))
            }
            self.init(section, offset)
        } else {
            var section: section = data.load(byteOffset: offset)
            if header.swappedBits {
                swap_section(&section, 1, NXByteOrder(0))
            }
            self.init(section, offset)
        }
        self._header = header
        self._data = data
    }
}
