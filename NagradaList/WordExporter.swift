//
//  WordExporter.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Foundation
import AppKit

class WordExporter {
    
    static func exportToWord(
        checkRules: Bool,
        checkOpredeleniya: Bool,
        progressCallback: @escaping (String, Double) -> Void
    ) {
        guard checkRules || checkOpredeleniya else {
            DispatchQueue.main.async {
                progressCallback("Пометьте как минимум 1 пункт", 0)
            }
            return
        }
        
        // Получаем количество записей
        guard let countResult = DatabaseManager.shared.executeQuery("SELECT COUNT(*) AS Result FROM nagrada"),
              let firstResult = countResult.first?["Result"] else {
            DispatchQueue.main.async {
                progressCallback("База данных пуста", 0)
            }
            return
        }
        
        let count: Int
        if let int64Value = firstResult as? Int64 {
            count = Int(int64Value)
        } else if let intValue = firstResult as? Int {
            count = intValue
        } else {
            DispatchQueue.main.async {
                progressCallback("Ошибка получения количества записей", 0)
            }
            return
        }
        
        guard count > 0 else {
            DispatchQueue.main.async {
                progressCallback("База данных пуста", 0)
            }
            return
        }
        
        let totalCount = count
        var opredeleniya: [Opredelenie] = []
        
        // Загружаем определения из базы
        DispatchQueue.global(qos: .userInitiated).async {
            var i = 0
            let stepSize = 5
            
            DispatchQueue.main.async {
                progressCallback("Статус: загрузка определений из базы 0/\(totalCount)", 0)
            }
            
            guard let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada") else {
                DispatchQueue.main.async {
                    progressCallback("Ошибка загрузки данных", 0)
                }
                return
            }
            
            var opredeleniyaDict: [String: Opredelenie] = [:]
            
            for row in results {
                guard let nagrada = Nagrada(from: row) as Nagrada?,
                      let otlichie = nagrada.otlichie, !otlichie.isEmpty else {
                    continue
                }
                
                let medalInfo = MedalInfo(from: nagrada)
                
                if let existing = opredeleniyaDict[otlichie] {
                    opredeleniyaDict[otlichie] = Opredelenie(
                        text: existing.text,
                        count: existing.count + 1,
                        nagrada: existing.nagrada,
                        errors: existing.errors
                    )
                } else {
                    opredeleniyaDict[otlichie] = Opredelenie(
                        text: otlichie,
                        count: 1,
                        nagrada: medalInfo,
                        errors: OpredelenieErrors()
                    )
                }
                
                i += 1
                if i % stepSize == 0 {
                    let progress = Double(i) / Double(totalCount) * 100.0
                    DispatchQueue.main.async {
                        progressCallback("Статус: загрузка определений из базы \(i)/\(totalCount)", progress)
                    }
                }
            }
            
            opredeleniya = Array(opredeleniyaDict.values)
            
            // Проверка по правилам
            if checkRules {
                DispatchQueue.main.async {
                    progressCallback("Статус: проверка по правилам", 50)
                }
                
                opredeleniya = TextConditionsManager.shared.checkOpredeleniya(opredeleniya) { current, total in
                    let progress = 50.0 + (Double(current) / Double(total) * 30.0)
                    DispatchQueue.main.async {
                        progressCallback("Статус: проверка по правилам \(current)/\(total)", progress)
                    }
                }
            }
            
            // Создаем документ
            DispatchQueue.main.async {
                progressCallback("Статус: создание документа", 80)
            }
            
            createWordDocument(
                opredeleniya: opredeleniya,
                checkRules: checkRules,
                checkOpredeleniya: checkOpredeleniya,
                progressCallback: progressCallback
            )
        }
    }
    
    private static func createWordDocument(
        opredeleniya: [Opredelenie],
        checkRules: Bool,
        checkOpredeleniya: Bool,
        progressCallback: @escaping (String, Double) -> Void
    ) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.rtf]
        panel.nameFieldStringValue = "Отчет_\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short).replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-"))"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                DispatchQueue.main.async {
                    progressCallback("Экспорт отменен", 0)
                }
                return
            }
            
            var content = ""
            
            // Заголовок с условиями проверки
            if checkRules {
                let conditions = TextConditionsManager.shared.getConditions()
                content += "Проверка определений\n"
                for condition in conditions {
                    content += "Пункт \(condition.idx + 1). \(condition.name)\n"
                }
                content += "\n\n"
            }
            
            let stepSize = 5
            let total = opredeleniya.count
            
            for (index, opredelenie) in opredeleniya.enumerated() {
                if checkOpredeleniya {
                    content += "\(opredelenie.nagrada.view) (\(opredelenie.count))\n"
                    content += "\(opredelenie.text)\n"
                } else {
                    if opredelenie.errors.hasErrors {
                        content += "\(opredelenie.nagrada.view) (\(opredelenie.count))\n"
                        content += "\(opredelenie.text)\n"
                    }
                }
                
                if checkRules && opredelenie.errors.hasErrors {
                    content += "Пункты: \(opredelenie.errors.punkts)\n"
                }
                
                content += "\n\n"
                
                if index % stepSize == 0 {
                    let progress = 80.0 + (Double(index) / Double(total) * 20.0)
                    DispatchQueue.main.async {
                        progressCallback("Статус: выгрузка информации в word \(index)/\(total)", progress)
                    }
                }
            }
            
            // Сохраняем как RTF
            let rtfContent = convertToRTF(content)
            
            do {
                try rtfContent.write(to: url, atomically: true, encoding: .utf8)
                
                // Открываем файл
                NSWorkspace.shared.open(url)
                
                DispatchQueue.main.async {
                    progressCallback("Состояние: готово", 100)
                }
            } catch {
                DispatchQueue.main.async {
                    progressCallback("Ошибка сохранения: \(error.localizedDescription)", 0)
                }
            }
        }
    }
    
    private static func convertToRTF(_ text: String) -> String {
        // Простой RTF формат
        let escapedText = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
            .replacingOccurrences(of: "\n", with: "\\par\n")
        
        return "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\\f0\\fs24 \(escapedText)}"
    }
}

