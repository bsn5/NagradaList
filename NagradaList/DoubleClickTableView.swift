//
//  DoubleClickTableView.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Cocoa

class DoubleClickTableView: NSTableView {
    weak var mainController: MainWindowController?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        // Проверяем двойной клик
        if event.clickCount == 2 {
            let point = self.convert(event.locationInWindow, from: nil)
            let row = self.row(at: point)
            
            if row >= 0 {
                // Выбираем строку перед обработкой двойного клика
                self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                // Вызываем обработчик двойного клика
                DispatchQueue.main.async { [weak self] in
                    self?.mainController?.openNagradaFromGrid()
                }
            }
        }
    }
}

