//
//	Helper Functions.swift
//
// 	Created by Cero on 2021-10-09
//	Copyright © Cero, all rights reserved
//
	

import Foundation
import Capstone

func capstoneArch(fromString: String) -> Architecture? {
    let architectures: [String: Architecture] = [
        "arm": .arm,
        "arm64": .arm64,
        "x86_64": .x86,
        "(x86, i386)": .x86,
        "powerPC": .ppc,
        "sparc": .sparc,
        "mc680x0": .m680x
    ]
    return architectures[fromString]
}

func magicName(_ magic: UInt32) -> String {
    let names: [UInt32: String] = [
        MH_CIGAM : "MH_CIGAM",
        MH_CIGAM_64 : "MH_CIGAM_64",
        MH_MAGIC : "MH_MAGIC",
        MH_MAGIC_64 : "MH_MAGIC_64",
        FAT_CIGAM : "FAT_CIGAM",
        FAT_CIGAM_64 : "FAT_CIGAM_64",
        FAT_MAGIC : "FAT_MAGIC",
        FAT_MAGIC_64 : "FAT_MAGIC_64",
    ]
    return names[magic] ?? "Unknown CPU"
}


func cpuTypeName(_ cpuType: cpu_type_t) -> String {
    let names: [cpu_type_t: String] = [
        CPU_TYPE_MC680x0: "mc680x0",
        CPU_TYPE_X86: "(x86, i386)",
        CPU_TYPE_X86_64: "x86_64",
        CPU_TYPE_MC98000: "mc98000",
        CPU_TYPE_HPPA: "hppa",
        CPU_TYPE_ARM: "arm",
        CPU_TYPE_ARM64: "arm64",
        CPU_TYPE_ARM64_32: "arm64_32",
        CPU_TYPE_MC88000: "mc88000",
        CPU_TYPE_SPARC: "sparc",
        CPU_TYPE_I860: "i860",
        CPU_TYPE_POWERPC: "powerPC",
        CPU_TYPE_POWERPC64: "powerPC64",
    ]
    return names[cpuType] ?? "Unknown CPU"
}

func fileTypeName(_ fileType: Int32) -> String {
    let names: [Int32: String] = [
        MH_OBJECT: "MH_OBJECT",
        MH_EXECUTE: "MH_EXECUTE",
        MH_FVMLIB: "MH_FVMLIB",
        MH_CORE: "MH_CORE",
        MH_PRELOAD: "MH_PRELOAD",
        MH_DYLIB: "MH_DYLIB",
        MH_DYLINKER: "MH_DYLINKER",
        MH_BUNDLE: "MH_BUNDLE",
        MH_DYLIB_STUB: "MH_DYLIB_STUB",
        MH_DSYM: "MH_DSYM",
        MH_KEXT_BUNDLE: "MH_KEXT_BUNDLE",
        MH_FILESET: "MH_FILESET",
    ]
    return names[fileType] ?? "Unknown File Type"
}

func vmProtName(_ vmProt: vm_prot_t) -> String {
    let names: [vm_prot_t : String] = [
        VM_PROT_NONE: "VM_PROT_NONE",
        VM_PROT_READ: "VM_PROT_READ",
        VM_PROT_WRITE: "VM_PROT_WRITE",
        VM_PROT_EXECUTE: "VM_PROT_EXECUTE",
        VM_PROT_DEFAULT: "VM_PROT_DEFAULT",
        VM_PROT_NO_CHANGE: "VM_PROT_NO_CHANGE",
        VM_PROT_EXECUTE_ONLY: "VM_PROT_EXECUTE_ONLY",
        5: "VM_PROT_MAX" // Inferred name
    ]
    return names[vmProt] ?? "Unknown Protection"
}

func versionOSName(_ command: version_min_command) -> String {
    let names: [Int32 : String] = [
        LC_VERSION_MIN_MACOSX: "MacOS",
        LC_VERSION_MIN_IPHONEOS: "iPhoneOS",
        LC_VERSION_MIN_WATCHOS: "WatchOS" ,
        LC_VERSION_MIN_TVOS: "TVOS"
    ]
    return names[Int32(bitPattern: command.cmd)] ?? "Unknown OS"
}

func osVersion(_ version: UInt32) -> String {
    let major = UInt((version & 0xffff_0000) >> 16)
    let minor = UInt((version & 0x0000_FF00) >> 8)
    let patch = UInt((version & 0x0000_00FF) >> 0)
    return "\(major).\(minor).\(patch)"
}
