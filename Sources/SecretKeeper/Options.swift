//
// Options.swift
// SecretKeeper
//
// Created by Braden Scothern on 11/13/19.
// Copyright © 2019 Braden Scothern. All rights reserved.
//

import Foundation
import SPMUtility
import Yams

class Options {
    // MARK: - Types
    enum Error: Swift.Error, CustomStringConvertible {
        case missingRequiredArguemnt
        case noYAMLFile
        case invalidYAML

        var description: String {
            switch self {
            case .missingRequiredArguemnt:
                return """
                Missing Required Argument.
                Make sure that both -s and -o are provided
                """
            case .noYAMLFile:
                return "Unable to find provided Secrets YAML file."
            case .invalidYAML:
                return """
                The provided YAML file is not the correct format.
                Use --yaml-help to get a description of the expected format.
                """
            }
        }
    }

    typealias Name = String
    typealias Secret = String

    // MARK: - Properties
    // MARK: Internal Static
    static let shared: Options = {
        do {
            let shared = try Options()
            return shared
        } catch {
            exit(1)
        }
    }()

    // MARK: Internal
    let secretsToObfuscate: [Name: Secret]
    let outputPath: String

    // MARK: - Init
    private init() throws {
        let parser = ArgumentParser(usage: "-s [path_to_secrets_yaml] -o [path_to_output_file]", overview: "Reads a yaml file and outputs a swift file with obfuscation secrets.")

        let inputYAMLPathOption = parser.add(option: "--secrets", shortName: "-s", kind: String.self, usage: "Used to provide the path to the secrets yaml to convert.")
        let outputPathOption = parser.add(option: "--output-to", shortName: "-o", kind: String.self, usage: "Used to provide the output path for the obfuscated secrets swift file.")

        let yamlFormatHelpOption = parser.add(option: "--yaml-help", kind: Bool.self, usage: "When supplied a description of the secrets YAML will be provided. Then the application will exit.")

        do {
            let result = try parser.parse(Array(CommandLine.arguments.dropFirst()))

            guard result.get(yamlFormatHelpOption).map(!) ?? true else {
                Self.printYAMLHelp()
            }

            guard let inputYAMLPath = result.get(inputYAMLPathOption),
                let outputPath = result.get(outputPathOption) else {
                    throw Error.missingRequiredArguemnt
            }

            self.secretsToObfuscate = try Self.loadYAML(atPath: inputYAMLPath)
            self.outputPath = outputPath
        } catch {
            print(error)
            throw error
        }
    }

    // MARK: - Funcs
    private static func printYAMLHelp() -> Never {
        print("""
        The secrets.yml file should be in this form:

            nameOfSecret: "My Secret String"
            nameOfSomeOtherSecret: "My other secret"

        Where each line is a key with a String value.
        """)
        exit(0)
    }

    private static func loadYAML(atPath path: String) throws -> [Name: Secret] {
        let filePath: String = path.hasPrefix(".") ? "\(FileManager.default.currentDirectoryPath)/\(path)" : path
        guard let rawYAMLContents = try? String(contentsOfFile: filePath) else {
            throw Error.noYAMLFile
        }
        guard let yamlContents = try? Yams.load(yaml: rawYAMLContents) as? [Name: Secret] else {
            throw Error.invalidYAML
        }
        return yamlContents
    }
}
