//
//  DatabaseManager.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: OpaquePointer?
    private var dbPath: String
    
    private init() {
        let fileManager = FileManager.default
        
        // Сначала проверяем сохраненный путь из UserDefaults
        if let savedPath = UserDefaults.standard.string(forKey: "DatabasePath"),
           fileManager.fileExists(atPath: savedPath) {
            dbPath = savedPath
            print("✅ База данных загружена из сохраненного пути: \(savedPath)")
        } else {
            // Пробуем найти базу данных в нескольких местах
            let projectPath = "/Users/ossuser/Documents/projects/NagradaList/base.db"
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dbURL = documentsPath.appendingPathComponent("base.db")
            
            // Приоритет: 1) Проект, 2) Documents приложения, 3) Создать новую
            if fileManager.fileExists(atPath: projectPath) {
                dbPath = projectPath
                print("✅ База данных найдена в проекте: \(projectPath)")
            } else if fileManager.fileExists(atPath: dbURL.path) {
                dbPath = dbURL.path
                print("✅ База данных найдена в Documents приложения: \(dbURL.path)")
            } else {
                // Пытаемся скопировать из проекта в Documents
                if fileManager.fileExists(atPath: projectPath) {
                    print("📋 Копирую базу данных из проекта в Documents...")
                    do {
                        try fileManager.copyItem(at: URL(fileURLWithPath: projectPath), to: dbURL)
                        dbPath = dbURL.path
                        print("✅ База данных скопирована в: \(dbURL.path)")
                    } catch {
                        print("❌ Ошибка копирования: \(error.localizedDescription)")
                        dbPath = projectPath
                        print("⚠️ Использую путь проекта: \(projectPath)")
                    }
                } else {
                    dbPath = dbURL.path
                    print("📝 База данных будет создана в: \(dbURL.path)")
                }
            }
            
            // Сохраняем путь в UserDefaults
            UserDefaults.standard.set(dbPath, forKey: "DatabasePath")
        }
        
        print("🔍 Финальный путь к базе: \(dbPath)")
        openDatabase()
    }
    
    private func openDatabase() {
        print("🔍 Открываю базу данных по пути: \(dbPath)")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            print("❌ Файл базы данных не существует по пути: \(dbPath)")
            self.db = nil
            return
        }
        
        // Проверяем права доступа (может не работать в sandbox, но попробуем)
        if !fileManager.isReadableFile(atPath: dbPath) {
            print("⚠️ Предупреждение: файл может быть недоступен из-за sandbox: \(dbPath)")
            print("⚠️ Продолжаю попытку открытия...")
            // Не прерываем выполнение, так как isReadableFile может давать false positive в sandbox
        }
        
        let result = sqlite3_open(dbPath, &db)
        print("🔍 Результат sqlite3_open: \(result) (SQLITE_OK = \(SQLITE_OK))")
        
        if result != SQLITE_OK {
            var errorMessage = "Неизвестная ошибка"
            if let db = db {
                errorMessage = String(cString: sqlite3_errmsg(db))
                sqlite3_close(db)
            } else {
                errorMessage = "Не удалось получить указатель на базу данных"
            }
            print("❌ Ошибка открытия базы данных (код \(result)): \(errorMessage)")
            print("❌ Путь к базе: \(dbPath)")
            self.db = nil
        } else {
            print("✅ База данных успешно открыта, db указатель: \(db != nil ? "установлен" : "nil")")
            // Проверяем, что база действительно работает (прямой запрос, без использования executeQuery)
            if let db = db {
                var testStatement: OpaquePointer?
                let testQuery = "SELECT name FROM sqlite_master WHERE type='table' LIMIT 1"
                if sqlite3_prepare_v2(db, testQuery, -1, &testStatement, nil) == SQLITE_OK {
                    if sqlite3_step(testStatement) == SQLITE_ROW {
                        print("✅ База данных работает. Таблицы найдены")
                    } else {
                        print("⚠️ База открыта, но таблицы не найдены")
                    }
                    sqlite3_finalize(testStatement)
                } else {
                    let errorMsg = String(cString: sqlite3_errmsg(db))
                    print("⚠️ Не удалось выполнить тестовый запрос: \(errorMsg)")
                }
            } else {
                print("❌ КРИТИЧЕСКАЯ ОШИБКА: db указатель стал nil после открытия!")
            }
        }
    }
    
    func executeQuery(_ query: String) -> [[String: Any]]? {
        guard let db = db else {
            print("❌ Ошибка: база данных не открыта")
            print("❌ dbPath был: \(dbPath)")
            print("❌ Попытка повторного открытия...")
            // Попробуем открыть базу заново
            openDatabase()
            guard let db = self.db else {
                print("❌ Не удалось открыть базу данных повторно")
                return nil
            }
            // Продолжаем с открытой базой
            return executeQueryInternal(query, db: db)
        }
        
        return executeQueryInternal(query, db: db)
    }
    
    private func executeQueryInternal(_ query: String, db: OpaquePointer) -> [[String: Any]]? {
        
        print("🔍 Выполняю запрос: \(query)")
        var statement: OpaquePointer?
        var results: [[String: Any]] = []
        
        let prepareResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        if prepareResult == SQLITE_OK {
            print("✅ Запрос подготовлен успешно")
            var rowCount = 0
            while sqlite3_step(statement) == SQLITE_ROW {
                var row: [String: Any] = [:]
                let columnCount = sqlite3_column_count(statement)
                
                for i in 0..<Int(columnCount) {
                    let columnName = String(cString: sqlite3_column_name(statement, Int32(i)))
                    let columnType = sqlite3_column_type(statement, Int32(i))
                    
                    switch columnType {
                    case SQLITE_INTEGER:
                        row[columnName] = sqlite3_column_int64(statement, Int32(i))
                    case SQLITE_FLOAT:
                        row[columnName] = sqlite3_column_double(statement, Int32(i))
                    case SQLITE_TEXT:
                        if let text = sqlite3_column_text(statement, Int32(i)) {
                            row[columnName] = String(cString: text)
                        }
                    case SQLITE_NULL:
                        row[columnName] = NSNull()
                    default:
                        break
                    }
                }
                results.append(row)
                rowCount += 1
            }
            print("✅ Получено строк: \(rowCount)")
        } else {
            // db уже извлечен в начале функции, используем его напрямую
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Ошибка выполнения запроса (код \(prepareResult)): \(errorMessage)")
            print("❌ Запрос: \(query)")
            sqlite3_finalize(statement)
            return nil
        }
        
        sqlite3_finalize(statement)
        print("✅ Возвращаю \(results.count) результатов")
        // Возвращаем массив, даже если он пустой (nil только при ошибке)
        return results
    }
    
    func executeUpdate(_ query: String) -> Bool {
        guard let db = db else {
            print("Ошибка: база данных не открыта")
            return false
        }
        
        var statement: OpaquePointer?
        var result = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                result = true
            } else {
                // db уже извлечен в начале функции
                print("Ошибка выполнения обновления: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            // db уже извлечен в начале функции
            print("Ошибка подготовки запроса: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    func executeUpdateWithParameters(_ query: String, parameters: [Any]) -> Bool {
        guard let db = db else {
            print("Ошибка: база данных не открыта")
            return false
        }
        
        var statement: OpaquePointer?
        var result = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            for (index, param) in parameters.enumerated() {
                let position = Int32(index + 1)
                if let stringValue = param as? String {
                    sqlite3_bind_text(statement, position, stringValue, -1, nil)
                } else if let intValue = param as? Int {
                    sqlite3_bind_int64(statement, position, Int64(intValue))
                } else if let int64Value = param as? Int64 {
                    sqlite3_bind_int64(statement, position, int64Value)
                } else if param is NSNull {
                    sqlite3_bind_null(statement, position)
                }
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                result = true
            } else {
                print("Ошибка выполнения обновления: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Ошибка подготовки запроса: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    func recordCount(_ query: String) -> Int {
        let countQuery = "SELECT COUNT(*) AS Result FROM (\(query))"
        if let results = executeQuery(countQuery), let first = results.first {
            if let count = first["Result"] as? Int64 {
                return Int(count)
            }
        }
        return 0
    }
    
    func isDatabaseOpen() -> Bool {
        return db != nil
    }
    
    func getUserName() -> String {
        if let results = executeQuery("SELECT login FROM USERLIST LIMIT 1"),
           let first = results.first,
           let login = first["login"] as? String {
            return login
        }
        return "Оператор"
    }
    
    func setUserName(_ name: String) {
        let escapedName = name.replacingOccurrences(of: "'", with: "''")
        executeUpdate("UPDATE USERLIST SET login = '\(escapedName)'")
        executeUpdate("UPDATE nagrada SET who_sozd = '\(escapedName)', who_red = '\(escapedName)'")
    }
    
    func getDatabasePath() -> String {
        return dbPath
    }
    
    func closeDatabase() {
        if let db = db {
            sqlite3_close(db)
            self.db = nil
        }
    }
    
    func openDatabase(at path: String) -> Bool {
        // Закрываем текущую базу, если открыта
        closeDatabase()
        
        // Обновляем путь
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            print("❌ Файл базы данных не существует: \(path)")
            return false
        }
        
        // Открываем новую базу
        let result = sqlite3_open(path, &db)
        
        if result != SQLITE_OK {
            var errorMessage = "Неизвестная ошибка"
            if let db = db {
                errorMessage = String(cString: sqlite3_errmsg(db))
                sqlite3_close(db)
            }
            print("❌ Ошибка открытия базы данных: \(errorMessage)")
            self.db = nil
            return false
        }
        
        // Обновляем путь к базе данных
        self.dbPath = path
        // Сохраняем путь в UserDefaults
        UserDefaults.standard.set(path, forKey: "DatabasePath")
        print("✅ База данных успешно открыта: \(path)")
        return true
    }
    
    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }
}

