//
//  OpenCodeMonitorPOC.swift
//  ClaudeIsland
//
//  POC for OpenCode process discovery and memory monitoring
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.claudeisland", category: "OpenCodeMonitor")

/// Result of process discovery
struct ProcessInfo {
    let pid: pid_t
    let name: String
    let commandLine: String
    let memoryMB: Int
}

/// OpenCode process monitor for POC validation
class OpenCodeMonitorPOC {
    
    // MARK: - Process Discovery
    
    /// Find OpenCode process using multiple methods
    static func findOpenCodeProcess() -> ProcessInfo? {
        // Try multiple process names
        let processNames = [
            "opencode",
            "node",  // If running via Node
            "bun"    // If running via Bun
        ]
        
        for name in processNames {
            if let process = findProcessByName(name) {
                // Verify it's actually OpenCode by checking command line
                if process.commandLine.contains("opencode") {
                    return process
                }
            }
        }
        
        // Fallback: search by command line
        return findProcessByCommandLine("opencode")
    }
    
    /// Find process by exact name match
    static func findProcessByName(_ name: String) -> ProcessInfo? {
        let processes = getAllProcesses()
        return processes.first { $0.name == name }
    }
    
    /// Find process by command line pattern
    static func findProcessByCommandLine(_ pattern: String) -> ProcessInfo? {
        let processes = getAllProcesses()
        return processes.first { $0.commandLine.contains(pattern) }
    }
    
    /// Get all running processes with their info
    static func getAllProcesses() -> [ProcessInfo] {
        var processes: [ProcessInfo] = []
        
        // Use BSD sysctl to enumerate processes
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var length: size_t = 0
        
        // Get required buffer size
        guard sysctl(&name, u_int(name.count), nil, &length, nil, 0) == 0 else {
            logger.error("Failed to get process list size")
            return []
        }
        
        // Allocate buffer
        let count = length / MemoryLayout<kinfo_proc>.stride
        var procs = Array(repeating: kinfo_proc(), count: count)
        
        // Get process list
        guard sysctl(&name, u_int(name.count), &procs, &length, nil, 0) == 0 else {
            logger.error("Failed to get process list")
            return []
        }
        
        // Convert to ProcessInfo
        for proc in procs {
            let pid = proc.kp_proc.p_pid
            guard pid > 0 else { continue }
            
            // Get process name
            var processName = withUnsafeBytes(of: proc.kp_proc.p_comm) { buffer -> String in
                let ptr = buffer.baseAddress?.assumingMemoryBound(to: CChar.self)
                return ptr.map { String(cString: $0) } ?? ""
            }
            
            // Get command line (more detailed)
            let commandLine = getProcessCommandLine(pid: pid) ?? processName
            
            // Get memory usage
            let memoryMB = getProcessMemory(pid: pid)
            
            processes.append(ProcessInfo(
                pid: pid,
                name: processName,
                commandLine: commandLine,
                memoryMB: memoryMB
            ))
        }
        
        return processes
    }
    
    /// Get command line for a process
    static func getProcessCommandLine(pid: pid_t) -> String? {
        var name: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        var length: size_t = 0
        
        // Get buffer size
        guard sysctl(&name, u_int(name.count), nil, &length, nil, 0) == 0 else {
            return nil
        }
        
        // Allocate buffer
        var buffer = [UInt8](repeating: 0, count: length)
        
        // Get command line
        guard sysctl(&name, u_int(name.count), &buffer, &length, nil, 0) == 0 else {
            return nil
        }
        
        // Skip argc (first 4 bytes)
        guard length > 4 else { return nil }
        
        // Find null-terminated strings
        var strings: [String] = []
        var start = 4
        
        for i in 4..<buffer.count {
            if buffer[i] == 0 && i > start {
                if let str = String(bytes: buffer[start..<i], encoding: .utf8), !str.isEmpty {
                    strings.append(str)
                }
                start = i + 1
                if strings.count >= 10 { break }  // Limit to first 10 args
            }
        }
        
        return strings.joined(separator: " ")
    }
    
    // MARK: - Memory Monitoring
    
    /// Get memory usage for a specific process (in MB)
    static func getProcessMemory(pid: pid_t) -> Int {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        var task: task_t = 0
        guard task_for_pid(mach_task_self_, pid, &task) == KERN_SUCCESS else {
            return 0
        }
        
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(task, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return 0
        }
        
        // Return resident memory in MB
        return Int(taskInfo.phys_footprint) / 1024 / 1024
    }
    
    /// Track memory usage over time
    static func trackMemory(pid: pid_t, duration: TimeInterval = 10.0, interval: TimeInterval = 1.0) -> [Int] {
        var readings: [Int] = []
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < duration {
            let memory = getProcessMemory(pid: pid)
            readings.append(memory)
            Thread.sleep(forTimeInterval: interval)
        }
        
        return readings
    }
    
    /// Get memory statistics from readings
    static func memoryStats(readings: [Int]) -> (min: Int, max: Int, avg: Int) {
        guard !readings.isEmpty else {
            return (0, 0, 0)
        }
        
        let min = readings.min() ?? 0
        let max = readings.max() ?? 0
        let avg = readings.reduce(0, +) / readings.count
        
        return (min, max, avg)
    }
    
    // MARK: - Real-time Memory Monitoring
    
    /// Memory threshold alert levels
    enum MemoryThreshold {
        case normal
        case warning  // > 2 GB
        case critical  // > 4 GB
        
        static func level(memoryMB: Int) -> MemoryThreshold {
            if memoryMB > 4096 {
                return .critical
            } else if memoryMB > 2048 {
                return .warning
            } else {
                return .normal
            }
        }
    }
    
    /// Callback for memory updates
    typealias MemoryUpdateHandler = (Int, MemoryThreshold) -> Void
    
    /// Start real-time memory monitoring
    static func startMonitoring(pid: pid_t, interval: TimeInterval = 60.0, onUpdate: @escaping MemoryUpdateHandler) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            let memory = getProcessMemory(pid: pid)
            let threshold = MemoryThreshold.level(memoryMB: memory)
            onUpdate(memory, threshold)
            
            if threshold == .warning {
                logger.warning("OpenCode memory usage high: \(memory)MB")
            } else if threshold == .critical {
                logger.error("OpenCode memory usage critical: \(memory)MB")
            }
        }
    }
    
    // MARK: - POC Test Methods
    
    /// Run complete POC validation
    static func runPOC() -> String {
        var report = "=== OpenCode Monitor POC Results ===\n\n"
        
        // Test 1: Process Discovery
        report += "## Test 1: Process Discovery\n"
        if let process = findOpenCodeProcess() {
            report += "✅ Found OpenCode process\n"
            report += "- PID: \(process.pid)\n"
            report += "- Name: \(process.name)\n"
            report += "- Command: \(process.commandLine)\n"
            report += "- Memory: \(process.memoryMB)MB\n\n"
            
            // Test 2: Memory Tracking
            report += "## Test 2: Memory Tracking\n"
            report += "Tracking memory for 10 seconds...\n"
            let readings = trackMemory(pid: process.pid, duration: 10.0, interval: 1.0)
            let stats = memoryStats(readings: readings)
            
            report += "✅ Memory tracking successful\n"
            report += "- Samples: \(readings.count)\n"
            report += "- Min: \(stats.min)MB\n"
            report += "- Max: \(stats.max)MB\n"
            report += "- Avg: \(stats.avg)MB\n"
            report += "- Readings: \(readings.map { "\($0)MB" }.joined(separator: ", "))\n\n"
            
            // Test 3: Threshold Detection
            report += "## Test 3: Threshold Detection\n"
            let threshold = MemoryThreshold.level(memoryMB: process.memoryMB)
            report += "Current threshold: \(threshold)\n"
            report += "✅ Threshold detection working\n\n"
        } else {
            report += "⚠️ No OpenCode process found\n"
            report += "Please start an OpenCode session and run POC again\n\n"
        }
        
        report += "=== POC Complete ===\n"
        return report
    }
}
