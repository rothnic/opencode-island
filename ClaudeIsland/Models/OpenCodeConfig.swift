//
//  OpenCodeConfig.swift
//  ClaudeIsland
//
//  OpenCode configuration models and discovery
//

import Foundation

/// OpenCode model configuration
struct OpenCodeModelConfig: Codable {
    let provider: String?
    let name: String?
    let apiKey: String?
    let temperature: Double?
    let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case provider, name
        case apiKey = "api_key"
        case temperature
        case maxTokens = "max_tokens"
    }
}

/// OpenCode MCP server configuration
struct OpenCodeMCPServer: Codable {
    let type: String  // "local" or "remote"
    let command: [String]?  // For local servers
    let url: String?  // For remote servers
    let env: [String: String]?
    let disabled: Bool?
}

/// OpenCode configuration
struct OpenCodeConfig: Codable {
    let model: OpenCodeModelConfig?
    let mcp: [String: OpenCodeMCPServer]?
    let plugins: [String: [String: AnyCodableValue]]?
    let tools: OpenCodeToolsConfig?
    let ui: OpenCodeUIConfig?
    
    /// Merge with another config (other overrides self)
    func merging(with other: OpenCodeConfig) -> OpenCodeConfig {
        return OpenCodeConfig(
            model: other.model ?? self.model,
            mcp: self.mergeMCP(with: other.mcp),
            plugins: other.plugins ?? self.plugins,
            tools: other.tools ?? self.tools,
            ui: other.ui ?? self.ui
        )
    }
    
    private func mergeMCP(with other: [String: OpenCodeMCPServer]?) -> [String: OpenCodeMCPServer]? {
        guard let selfMCP = self.mcp else { return other }
        guard let otherMCP = other else { return selfMCP }
        var merged = selfMCP
        for (key, value) in otherMCP {
            merged[key] = value
        }
        return merged
    }
}

/// OpenCode tools configuration
struct OpenCodeToolsConfig: Codable {
    let enabled: [String]?
    let disabled: [String]?
}

/// OpenCode UI configuration
struct OpenCodeUIConfig: Codable {
    let theme: String?
    let fontSize: Int?
    
    enum CodingKeys: String, CodingKey {
        case theme
        case fontSize = "font_size"
    }
}

/// Type-erased value for arbitrary JSON
enum AnyCodableValue: Codable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([AnyCodableValue])
    case object([String: AnyCodableValue])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([AnyCodableValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: AnyCodableValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}
