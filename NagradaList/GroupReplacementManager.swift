//
//  GroupReplacementManager.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Foundation

struct SelectedMedal {
    var id: String
    var displayText: String
    var isSelected: Bool
}

class GroupReplacementManager {
    static let shared = GroupReplacementManager()
    
    private init() {}
    
    func getFieldName(for comboText: String) -> String {
        switch comboText {
        case "Приказ": return "prikaz"
        case "Номер приказа": return "nomer_prik"
        case "Дата приказа": return "data_prik"
        case "Часть": return "chast"
        case "Подразделение 1": return "podrazdel1"
        case "Подразделение 2": return "podrazdel2"
        case "Архив": return "arxiv"
        case "Фонд": return "fond"
        case "Опись": return "opis"
        case "Дело": return "delo"
        case "Др. источники": return "drugie_ist"
        case "Чин": return "chin"
        case "Должность": return "dolzhnost"
        case "Оператор(создание)": return "who_sozd"
        case "Отличие": return "otlichie"
        case "Кампания": return "komp"
        case "Лист": return "list"
        case "Комментарий": return "komment"
        case "Губерния": return "Губерния"
        case "Уезд": return "Уезд"
        case "Деревня": return "Деревня"
        case "Служебные отметки": return "sluzh_otm"
        case "Отношение": return "otnosh"
        case "Дата отношения": return "data_otnosh"
        case "Номер отношения": return "nomer_otnosh"
        default: return ""
        }
    }
    
    func fillList(
        fieldName: String?,
        comparisonType: Int, // 0 = равно, 1 = включает
        value: String,
        caseSensitive: Bool
    ) -> [SelectedMedal] {
        var selectedMedals: [SelectedMedal] = []
        
        guard let fieldName = fieldName, !fieldName.isEmpty else {
            // Если поле не выбрано, возвращаем все награды
            if let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada") {
                for row in results {
                    let nagrada = Nagrada(from: row)
                    let medalInfo = MedalInfo(from: nagrada)
                    let displayText = "\(nagrada.id); \(medalInfo.view)"
                    selectedMedals.append(SelectedMedal(
                        id: nagrada.id,
                        displayText: displayText,
                        isSelected: true
                    ))
                }
            }
            return selectedMedals
        }
        
        guard let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada") else {
            return selectedMedals
        }
        
        var k = 0, m = 0
        
        for row in results {
            let nagrada = Nagrada(from: row)
            guard let fieldValue = row[fieldName] as? String else { continue }
            
            var shouldAdd = false
            var searchValue = value
            var fieldVal = fieldValue
            
            if !caseSensitive {
                searchValue = searchValue.uppercased()
                fieldVal = fieldVal.uppercased()
            }
            
            if comparisonType == 0 { // Равно
                shouldAdd = fieldVal == searchValue
            } else if comparisonType == 1 { // Включает
                shouldAdd = fieldVal.contains(searchValue)
            }
            
            if shouldAdd {
                let medalInfo = MedalInfo(from: nagrada)
                var displayText = "\(nagrada.id); "
                if nagrada.nagrada == 0 {
                    displayText += "К "
                    k += 1
                } else {
                    displayText += "М "
                    m += 1
                }
                displayText += "\(nagrada.stepen ?? 0) ст № \(nagrada.nomer ?? 0)"
                
                selectedMedals.append(SelectedMedal(
                    id: nagrada.id,
                    displayText: displayText,
                    isSelected: true
                ))
            }
        }
        
        return selectedMedals
    }
    
    func makeChanges(
        selectedMedals: [SelectedMedal],
        changeType: Int, // 0 = нет, 1 = установить, 2 = замена, 3 = добавление, 4 = очистка
        fieldName: String,
        textChange1: String,
        textChange2: String
    ) -> Bool {
        guard changeType > 0, !fieldName.isEmpty else {
            return false
        }
        
        let selectedIds = selectedMedals.filter { $0.isSelected }.map { $0.id }
        guard !selectedIds.isEmpty else {
            return false
        }
        
        let idsString = selectedIds.map { "'\($0.replacingOccurrences(of: "'", with: "''"))'" }.joined(separator: ", ")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = formatter.string(from: Date())
        
        var success = true
        
        for id in selectedIds {
            guard let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada WHERE id = '\(id.replacingOccurrences(of: "'", with: "''"))' LIMIT 1"),
                  let row = results.first else {
                continue
            }
            
            let nagrada = Nagrada(from: row)
            var newValue: String = ""
            
            switch changeType {
            case 1: // Установить значение
                newValue = textChange1
                
            case 2: // Замена значения
                if let currentValue = row[fieldName] as? String {
                    newValue = currentValue.replacingOccurrences(of: textChange1, with: textChange2)
                }
                
            case 3: // Добавление значения
                if let currentValue = row[fieldName] as? String {
                    newValue = currentValue + textChange1
                } else {
                    newValue = textChange1
                }
                
            case 4: // Очистка поля
                newValue = ""
                
            default:
                continue
            }
            
            let escapedValue = newValue.replacingOccurrences(of: "'", with: "''")
            let query = "UPDATE nagrada SET \(fieldName) = '\(escapedValue)', data_izm = '\(now)' WHERE id = '\(id.replacingOccurrences(of: "'", with: "''"))'"
            
            if !DatabaseManager.shared.executeUpdate(query) {
                success = false
            }
        }
        
        return success
    }
}


