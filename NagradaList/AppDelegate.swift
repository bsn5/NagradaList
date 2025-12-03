//
//  AppDelegate.swift
//  NagradaList
//
//  Created by MACbook on 01.12.2025.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize database connection
        print("🚀 Инициализация DatabaseManager...")
        let dbManager = DatabaseManager.shared
        print("✅ DatabaseManager инициализирован, база открыта: \(dbManager.isDatabaseOpen())")
        
        // Close any windows opened by storyboard immediately
        for window in NSApplication.shared.windows {
            window.close()
        }
        
        // Create main window programmatically
        createMainWindowProgrammatically()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            createMainWindowProgrammatically()
        }
        return true
    }
    
    func createMainWindowProgrammatically() {
        // Don't create if already exists
        if let existingWindow = mainWindowController?.window, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        print("Creating main window programmatically...")
        
        let windowController = MainWindowController()
        mainWindowController = windowController
        
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Рабочее место оператора: \(DatabaseManager.shared.getUserName())"
        window.center()
        window.setFrameAutosaveName("MainWindow")
        window.isReleasedWhenClosed = false
        
        // Create content view with proper frame
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        // Create tab view
        let tabView = NSTabView(frame: contentView.bounds)
        tabView.autoresizingMask = [.width, .height]
        tabView.tabViewType = .topTabsBezelBorder
        
        // Create tabs
        createTabs(in: tabView, windowController: windowController)
        
        contentView.addSubview(tabView)
        window.contentView = contentView
        windowController.window = window
        
        // Setup window controller
        windowController.setupUI()
        windowController.loadInitialData()
        
        print("Window created, showing...")
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("Window should be visible now. Window count: \(NSApplication.shared.windows.count)")
    }
    
    func createTabs(in tabView: NSTabView, windowController: MainWindowController) {
        // Tab 1: Export to Word
        let tab1 = NSTabViewItem(identifier: "Export")
        tab1.label = "Выгрузка в word"
        let view1 = createExportView(windowController: windowController)
        tab1.view = view1
        tabView.addTabViewItem(tab1)
        
        // Tab 2: Table View
        let tab2 = NSTabViewItem(identifier: "Table")
        tab2.label = "Проверка в таблице"
        let view2 = createTableView(windowController: windowController)
        tab2.view = view2
        tabView.addTabViewItem(tab2)
        
        // Tab 3: Service
        let tab3 = NSTabViewItem(identifier: "Service")
        tab3.label = "Служебная"
        let view3 = createServiceView(windowController: windowController)
        tab3.view = view3
        tabView.addTabViewItem(tab3)
        
        // Tab 4: Number Conditions
        let tab4 = NSTabViewItem(identifier: "NumberConditions")
        tab4.label = "Условия на номера"
        let view4 = createNumberConditionsView(windowController: windowController)
        tab4.view = view4
        tabView.addTabViewItem(tab4)
        
        // Tab 5: Group Replacement
        let tab5 = NSTabViewItem(identifier: "GroupReplacement")
        tab5.label = "Групповая замена"
        let view5 = createGroupReplacementView(windowController: windowController)
        tab5.view = view5
        tabView.addTabViewItem(tab5)
        
        // Tab 6: Unload
        let tab6 = NSTabViewItem(identifier: "Unload")
        tab6.label = "Сдача папки"
        let view6 = createUnloadView(windowController: windowController)
        tab6.view = view6
        tabView.addTabViewItem(tab6)
        
        // Store tabView reference
        windowController.tabView = tabView
    }
    
    func createExportView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        let label = NSTextField(labelWithString: "Перед началом выгрузки закройте основную программу.")
        label.frame = NSRect(x: 20, y: 650, width: 600, height: 20)
        label.font = NSFont.boldSystemFont(ofSize: 13)
        view.addSubview(label)
        
        let groupBox = NSBox(frame: NSRect(x: 20, y: 450, width: 500, height: 200))
        groupBox.title = ""
        groupBox.boxType = .primary
        view.addSubview(groupBox)
        
        let checkRules = NSButton(checkboxWithTitle: "Проверка по правилам", target: windowController, action: nil)
        checkRules.frame = NSRect(x: 20, y: 150, width: 200, height: 20)
        checkRules.state = .on
        windowController.checkRules = checkRules
        groupBox.addSubview(checkRules)
        
        let checkOpredeleniya = NSButton(checkboxWithTitle: "Выгрузить определения", target: windowController, action: nil)
        checkOpredeleniya.frame = NSRect(x: 20, y: 120, width: 200, height: 20)
        checkOpredeleniya.state = .on
        windowController.checkOpredeleniya = checkOpredeleniya
        groupBox.addSubview(checkOpredeleniya)
        
        let labelStatus = NSTextField(labelWithString: "Состояние: готово")
        labelStatus.frame = NSRect(x: 20, y: 80, width: 400, height: 20)
        windowController.labelStatus = labelStatus
        groupBox.addSubview(labelStatus)
        
        let progressBar = NSProgressIndicator(frame: NSRect(x: 20, y: 50, width: 450, height: 20))
        progressBar.style = .bar
        windowController.progressBar = progressBar
        groupBox.addSubview(progressBar)
        
        let buttonMake = NSButton(title: "Сделать отчет", target: windowController, action: #selector(MainWindowController.buttonMakeClicked(_:)))
        buttonMake.frame = NSRect(x: 350, y: 10, width: 120, height: 30)
        windowController.buttonMake = buttonMake
        groupBox.addSubview(buttonMake)
        
        return view
    }
    
    func createTableView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        // Buttons at top
        let buttonOpenBase = NSButton(title: "Открыть", target: windowController, action: #selector(MainWindowController.buttonOpenBaseClicked(_:)))
        buttonOpenBase.frame = NSRect(x: 20, y: 650, width: 100, height: 30)
        windowController.buttonOpenBase = buttonOpenBase
        view.addSubview(buttonOpenBase)
        
        let buttonAdd = NSButton(title: "Добавить", target: windowController, action: #selector(MainWindowController.buttonAddClicked(_:)))
        buttonAdd.frame = NSRect(x: 130, y: 650, width: 100, height: 30)
        windowController.buttonAdd = buttonAdd
        view.addSubview(buttonAdd)
        
        let buttonOpenNagradaForm = NSButton(title: "Подробно", target: windowController, action: #selector(MainWindowController.buttonOpenNagradaFormClicked(_:)))
        buttonOpenNagradaForm.frame = NSRect(x: 240, y: 650, width: 100, height: 30)
        windowController.buttonOpenNagradaForm = buttonOpenNagradaForm
        view.addSubview(buttonOpenNagradaForm)
        
        // Group box for filtering
        let groupBox2 = NSBox(frame: NSRect(x: 20, y: 50, width: 250, height: 600))
        groupBox2.title = "Группировка"
        groupBox2.boxType = .primary
        view.addSubview(groupBox2)
        
        // Выпадающий список для группировки - размещаем ниже заголовка NSBox
        let comboGroup = NSComboBox(frame: NSRect(x: 10, y: 535, width: 230, height: 25))
        comboGroup.target = windowController
        comboGroup.action = #selector(MainWindowController.comboGroupChanged(_:))
        comboGroup.delegate = windowController  // Устанавливаем делегат для отслеживания изменений
        windowController.comboGroup = comboGroup
        groupBox2.addSubview(comboGroup)
        
        // Список значений - размещаем ниже выпадающего списка
        let scrollView = NSScrollView(frame: NSRect(x: 10, y: 10, width: 230, height: 520))
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .bezelBorder
        
        let listGroup = NSTableView(frame: scrollView.bounds)
        listGroup.headerView = nil
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Group"))
        column.width = 210
        listGroup.addTableColumn(column)
        
        // Настройка для автоматической высоты строк
        listGroup.usesAutomaticRowHeights = true
        listGroup.rowHeight = 20.0 // Минимальная высота
        listGroup.intercellSpacing = NSSize(width: 4, height: 4)
        
        listGroup.delegate = windowController
        listGroup.dataSource = windowController
        
        scrollView.documentView = listGroup
        windowController.listGroup = listGroup
        groupBox2.addSubview(scrollView)
        
        // Group box for table
        let groupBox3 = NSBox(frame: NSRect(x: 280, y: 50, width: 700, height: 600))
        groupBox3.title = "Таблица"
        groupBox3.boxType = .primary
        view.addSubview(groupBox3)
        
        let textSearch = NSTextField(frame: NSRect(x: 100, y: 560, width: 200, height: 25))
        textSearch.placeholderString = "Найти в таблице"
        windowController.textSearch = textSearch
        groupBox3.addSubview(textSearch)
        
        let scrollView2 = NSScrollView(frame: NSRect(x: 10, y: 100, width: 680, height: 450))
        scrollView2.hasVerticalScroller = true
        scrollView2.hasHorizontalScroller = true
        scrollView2.borderType = .bezelBorder
        
        let grid = NSTableView(frame: scrollView2.bounds)
        setupGridColumns(grid: grid)
        
        // Настройка внешнего вида таблицы
        grid.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
        grid.intercellSpacing = NSSize(width: 1, height: 4)
        grid.rowHeight = 24.0
        grid.usesAlternatingRowBackgroundColors = true
        
        // Настройка границ
        grid.gridColor = NSColor.separatorColor
        grid.backgroundColor = NSColor.controlBackgroundColor
        
        grid.delegate = windowController
        grid.dataSource = windowController
        
        scrollView2.documentView = grid
        windowController.grid = grid
        groupBox3.addSubview(scrollView2)
        
        return view
    }
    
    func setupGridColumns(grid: NSTableView) {
        let columns = [
            ("Type", "Тип", 65),
            ("Stepen", "Ст", 40),
            ("Nomer", "Номер", 75),
            ("FIO", "ФИО", 200),
            ("Dolzhnost", "Должность", 120),
            ("Chin", "Чин", 100),
            ("Chast", "Часть", 120),
            ("Podrazdel", "Подразделение", 150),
            ("DataSozd", "Дата создания", 130),
            ("DataIzm", "Дата изм.", 100),
            ("DrugieIst", "Другие ист.", 150),
            ("ID", "id", 0)
        ]
        
        for (identifier, title, width) in columns {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
            column.title = title
            column.width = CGFloat(width)
            if identifier == "ID" {
                column.isHidden = true
            }
            grid.addTableColumn(column)
        }
    }
    
    func createServiceView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        let textOperatorName = NSTextField(frame: NSRect(x: 350, y: 600, width: 400, height: 25))
        textOperatorName.placeholderString = "Имя оператора"
        windowController.textOperatorName = textOperatorName
        view.addSubview(textOperatorName)
        
        let buttonSetOperatorName = NSButton(title: "Установить", target: windowController, action: #selector(MainWindowController.buttonSetOperatorNameClicked(_:)))
        buttonSetOperatorName.frame = NSRect(x: 760, y: 600, width: 100, height: 30)
        windowController.buttonSetOperatorName = buttonSetOperatorName
        view.addSubview(buttonSetOperatorName)
        
        let textFilePath = NSTextField(frame: NSRect(x: 350, y: 550, width: 500, height: 25))
        textFilePath.isEditable = false
        windowController.textFilePath = textFilePath
        view.addSubview(textFilePath)
        
        return view
    }
    
    func createNumberConditionsView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        // Basic implementation
        return view
    }
    
    func createGroupReplacementView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        // Basic implementation
        return view
    }
    
    func createUnloadView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        // Basic implementation
        return view
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

