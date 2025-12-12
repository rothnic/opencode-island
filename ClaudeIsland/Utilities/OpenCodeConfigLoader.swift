//
//  OpenCodeConfigLoader.swift
//  ClaudeIsland
//
//  Discovers and loads OpenCode configuration from standard locations
//

import Foundation

/// OpenCode configuration loader that discovers and merges configs
class OpenCodeConfigLoader {
    
    /// Standard OpenCode configuration file locations (in priority order)
    static let configSearchPaths: [String] = [
        // Project-specific (current directory)
        "opencode.jsonc",
        ".opencode/opencode.jsonc",
        // Global user config
        "~/.config/opencode/opencode.jsonc",
        "~/.config/opencode/opencode.json"
    ]
    
    /// Discover and load OpenCode configuration
    /// - Parameter projectRoot: Optional project root directory. If nil, uses current directory.
    /// - Returns: Merged configuration from all discovered sources, or nil if none found
    static func discoverConfiguration(projectRoot: String? = nil) -> OpenCodeConfig? {
        var discoveredConfigs: [OpenCodeConfig] = []
        
        // Start with global config (lowest priority)
        if let globalConfig = loadGlobalConfig() {
            discoveredConfigs.append(globalConfig)
        }
        
        // Then add project config (higher priority)
        if let projectConfig = loadProjectConfig(projectRoot: projectRoot) {
            discoveredConfigs.append(projectConfig)
        }
        
        // Merge all configs (later overrides earlier)
        guard !discoveredConfigs.isEmpty else {
            return nil
        }
        
        var merged = discoveredConfigs[0]
        for config in discoveredConfigs.dropFirst() {
            merged = merged.merging(with: config)
        }
        
        return merged
    }
    
    /// Load global OpenCode configuration from ~/.config/opencode/
    static func loadGlobalConfig() -> OpenCodeConfig? {
        let paths = [
            "~/.config/opencode/opencode.jsonc",
            "~/.config/opencode/opencode.json"
        ]
        
        for path in paths {
            if let config = loadConfigFile(at: expandPath(path)) {
                return config
            }
        }
        
        return nil
    }
    
    /// Load project-specific OpenCode configuration
    static func loadProjectConfig(projectRoot: String? = nil) -> OpenCodeConfig? {
        let root = projectRoot ?? FileManager.default.currentDirectoryPath
        
        let paths = [
            "\(root)/opencode.jsonc",
            "\(root)/.opencode/opencode.jsonc"
        ]
        
        for path in paths {
            if let config = loadConfigFile(at: path) {
                return config
            }
        }
        
        return nil
    }
    
    /// Load configuration from a specific file path
    static func loadConfigFile(at path: String) -> OpenCodeConfig? {
        let expandedPath = expandPath(path)
        
        guard FileManager.default.fileExists(atPath: expandedPath) else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: expandedPath)) else {
            return nil
        }
        
        // Remove JSONC comments (simple implementation for // and /* */ style comments)
        let jsonString = removeJSONComments(from: String(data: data, encoding: .utf8) ?? "")
        
        guard let cleanData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(OpenCodeConfig.self, from: cleanData)
    }
    
    /// Expand ~ in paths
    static func expandPath(_ path: String) -> String {
        if path.hasPrefix("~/") {
            return NSString(string: path).expandingTildeInPath
        }
        return path
    }
    
    /// Remove JSON comments (JSONC support)
    private static func removeJSONComments(from jsonString: String) -> String {
        var result = ""
        var inString = false
        var inSingleLineComment = false
        var inMultiLineComment = false
        var escaped = false
        
        let chars = Array(jsonString)
        var i = 0
        
        while i < chars.count {
            let char = chars[i]
            
            // Handle escape sequences in strings
            if inString {
                result.append(char)
                if char == "\\" && !escaped {
                    escaped = true
                } else if char == "\"" && !escaped {
                    inString = false
                } else {
                    escaped = false
                }
                i += 1
                continue
            }
            
            // Handle string start
            if char == "\"" {
                inString = true
                result.append(char)
                i += 1
                continue
            }
            
            // Handle single-line comment
            if !inMultiLineComment && i + 1 < chars.count && char == "/" && chars[i + 1] == "/" {
                inSingleLineComment = true
                i += 2
                continue
            }
            
            // End single-line comment at newline
            if inSingleLineComment && (char == "\n" || char == "\r") {
                inSingleLineComment = false
                result.append(char)
                i += 1
                continue
            }
            
            // Handle multi-line comment start
            if !inSingleLineComment && i + 1 < chars.count && char == "/" && chars[i + 1] == "*" {
                inMultiLineComment = true
                i += 2
                continue
            }
            
            // Handle multi-line comment end
            if inMultiLineComment && i + 1 < chars.count && char == "*" && chars[i + 1] == "/" {
                inMultiLineComment = false
                i += 2
                continue
            }
            
            // Skip comment content
            if inSingleLineComment || inMultiLineComment {
                i += 1
                continue
            }
            
            // Add normal characters
            result.append(char)
            i += 1
        }
        
        return result
    }
    
    /// Validate that a configuration has required fields
    static func validateConfig(_ config: OpenCodeConfig) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        // Check if model is configured
        if config.model == nil {
            errors.append("No model configuration found")
        } else if let model = config.model {
            if model.provider == nil {
                errors.append("Model provider not specified")
            }
            if model.name == nil {
                errors.append("Model name not specified")
            }
        }
        
        // Check MCP server configurations
        if let mcpServers = config.mcp {
            for (name, server) in mcpServers {
                if server.type == "local" && (server.command == nil || server.command?.isEmpty == true) {
                    errors.append("MCP server '\(name)' is local but has no command")
                }
                if server.type == "remote" && (server.url == nil || server.url?.isEmpty == true) {
                    errors.append("MCP server '\(name)' is remote but has no URL")
                }
            }
        }
        
        return (errors.isEmpty, errors)
    }
}
