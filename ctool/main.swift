//
//     main.swift
//
//     Created by Cero on 2021-10-04
//     Copyright © Cero, all rights reserved
//

import Foundation
import ArgumentParser

//TODO: Refactor main

struct Main: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "ctool",
        abstract: "Do things with MachO and FAT files",
        discussion: """
        //TODO: Do this longer description lol
        """,
        version: "The real question is, how old are YOU! Ha, gottie!!",
        shouldDisplay: true
    )
    
    @Argument(
        help: ArgumentHelp(
            "The complete file path to dump segements",
            shouldDisplay: true
        )
    ) var filePath: String = ""
    
    func run() throws {
        guard filePath != "" else {
            throw ValidationError("Bruh give me a path\n")
        }
        let manager = GenerationManager(withPath: filePath)
        for var child in manager.generationChildren {
           _ = child.rawAssembly()
        }
//        if FatFile.isFat(tempData.load()) {
//            var file: FatFile = FatFile(withPath: filePath)
//            printFatHeader(file.header)
//            var archNumber: Int = 1
//            for machFile in file.machFiles {
//                print("------------------------------------")
//                print("Architecture \(archNumber)")
//                printOutMachOFile(machFile)
//                archNumber += 1
//            }
//        } else {
//            let file: MachOFile = MachOFile(withPath: filePath)
//            printOutMachOFile(file)
//        }
    }
}

func printOutMachOFile(_ file: MachOFile) {
    var file = file
    let header: mach_header_unified = file.header
    if header.versionMinCommand() != nil {
        printVersionMinCommand(header.versionMinCommand()!)
    }
    let segments: [segement_command_unified] = header.segmentCommands()
    printHeader(header)
    for segment in segments {
        printSegmentCommand(segment)
        for section in segment.sections() {
            printSection(section)
        }
    }
}

Main.main(["/Applications/Betelguese.app/Contents/MacOS/Betelguese"]) // Put any binary here or something..

