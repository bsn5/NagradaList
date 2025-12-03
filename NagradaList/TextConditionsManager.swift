//
//  TextConditionsManager.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Foundation

enum ConditionType: Int {
    case simpleCombination = 1
    case noSymbol = 2
    case noCover = 3
}

struct TextCondition {
    var idx: Int
    var name: String
    var type: ConditionType
    var combination: String
    var symbol: String
    var check: Int
}

struct OpredelenieErrors {
    var punkt: [Int] = []
    var position: [Int] = []
    var opisanie: [String] = []
    var punkts: String = ""
    var hasErrors: Bool = false
}

struct Opredelenie {
    var text: String
    var count: Int
    var nagrada: MedalInfo
    var errors: OpredelenieErrors
}

struct MedalInfo {
    var type: Int
    var num: Int
    var stepen: Int
    var id: String
    
    init(from nagrada: Nagrada) {
        self.type = nagrada.nagrada ?? -1
        self.num = nagrada.nomer ?? -1
        self.stepen = nagrada.stepen ?? -1
        self.id = nagrada.id
    }
    
    var view: String {
        if type == 0 {
            return "Крест \(stepen) степени № \(num)"
        } else if type == 1 {
            return "Медаль \(stepen) степени № \(num)"
        } else {
            return "Неизвестный тип награды"
        }
    }
}

class TextConditionsManager {
    static let shared = TextConditionsManager()
    
    private var conditions: [TextCondition] = []
    private let conditionsFileName = "text conditions.txt"
    
    private init() {
        loadConditions()
    }
    
    func loadConditions(from path: String? = nil) {
        let filePath: String
        if let path = path {
            filePath = path
        } else {
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            filePath = documentsPath.appendingPathComponent(conditionsFileName).path
        }
        
        guard FileManager.default.fileExists(atPath: filePath),
              let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            print("⚠️ Файл условий не найден: \(filePath)")
            return
        }
        
        conditions = []
        let lines = content.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() {
            let parts = line.components(separatedBy: ";")
            guard parts.count >= 5 else { continue }
            
            let idx = Int(parts[0]) ?? index
            let name = parts[1]
            let typeRaw = Int(parts[2]) ?? 1
            let type = ConditionType(rawValue: typeRaw) ?? .simpleCombination
            let combination = parts[3]
            let symbol = parts[4]
            let check = parts.count > 5 ? (Int(parts[5]) ?? 0) : 0
            
            conditions.append(TextCondition(
                idx: idx,
                name: name,
                type: type,
                combination: combination,
                symbol: symbol,
                check: check
            ))
        }
        
        print("✅ Загружено условий: \(conditions.count)")
    }
    
    func saveConditions(to path: String? = nil) {
        let filePath: String
        if let path = path {
            filePath = path
        } else {
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            filePath = documentsPath.appendingPathComponent(conditionsFileName).path
        }
        
        var content = ""
        for condition in conditions {
            let line = "\(condition.idx);\(condition.name);\(condition.type.rawValue);\(condition.combination);\(condition.symbol);\(condition.check)"
            content += line + "\n"
        }
        
        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("✅ Условия сохранены в: \(filePath)")
        } catch {
            print("❌ Ошибка сохранения условий: \(error.localizedDescription)")
        }
    }
    
    func checkOpredeleniya(_ opredeleniya: [Opredelenie], progressCallback: ((Int, Int) -> Void)? = nil) -> [Opredelenie] {
        var result = opredeleniya
        
        guard !conditions.isEmpty else {
            print("⚠️ Условия не загружены")
            return result
        }
        
        let total = opredeleniya.count
        for (index, opredelenie) in opredeleniya.enumerated() {
            let errors = checkOpredelenie(opredelenie.text)
            result[index].errors = errors
            
            if index % 5 == 0 {
                progressCallback?(index, total)
            }
        }
        
        return result
    }
    
    private func checkOpredelenie(_ text: String, num: Int = -1) -> OpredelenieErrors {
        var errors = OpredelenieErrors()
        
        for condition in conditions {
            var shouldCheck = false
            
            if num == -1 {
                shouldCheck = condition.check == 1
            } else {
                shouldCheck = condition.idx == num
            }
            
            guard shouldCheck else { continue }
            
            switch condition.type {
            case .simpleCombination:
                if text.contains(condition.combination) {
                    if let pos = text.range(of: condition.combination)?.lowerBound {
                        let position = text.distance(from: text.startIndex, to: pos)
                        addError(&errors, punkt: condition.idx, position: position, opisanie: condition.name)
                    }
                }
                
            case .noSymbol:
                if let range = text.range(of: condition.combination) {
                    let pos = text.distance(from: text.startIndex, to: range.lowerBound)
                    let combLength = condition.combination.count
                    
                    if pos + combLength >= text.count {
                        addError(&errors, punkt: condition.idx, position: pos, opisanie: condition.name)
                    } else {
                        let startIndex = text.index(range.upperBound, offsetBy: 0)
                        let endIndex = text.index(startIndex, offsetBy: min(condition.symbol.count, text.distance(from: startIndex, to: text.endIndex)))
                        let substring = String(text[startIndex..<endIndex])
                        
                        if substring != condition.symbol {
                            addError(&errors, punkt: condition.idx, position: pos, opisanie: condition.name)
                        }
                    }
                }
                
            case .noCover:
                // Реализация по необходимости
                break
            }
        }
        
        return errors
    }
    
    private func addError(_ errors: inout OpredelenieErrors, punkt: Int, position: Int, opisanie: String) {
        errors.punkt.append(punkt)
        errors.position.append(position)
        errors.opisanie.append(opisanie)
        
        if errors.punkts.isEmpty {
            errors.punkts = "\(punkt + 1)"
        } else {
            errors.punkts += ", \(punkt + 1)"
        }
        
        errors.hasErrors = true
    }
    
    func getConditions() -> [TextCondition] {
        return conditions
    }
    
    func setConditions(_ newConditions: [TextCondition]) {
        conditions = newConditions
    }
}

