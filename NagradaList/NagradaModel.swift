//
//  NagradaModel.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Foundation

struct Nagrada {
    var id: String
    var фамилия: String?
    var имя: String?
    var отчество: String?
    var komp: String?
    var nagrada: Int?
    var nomer: Int?
    var stepen: Int?
    var chast: String?
    var podrazdel1: String?
    var podrazdel2: String?
    var chin: String?
    var dolzhnost: String?
    var prikaz: String?
    var data_prik: String?
    var nomer_prik: String?
    var otnosh: String?
    var data_otnosh: String?
    var nomer_otnosh: String?
    var arxiv: String?
    var fond: String?
    var opis: String?
    var delo: String?
    var list: String?
    var drugie_ist: String?
    var otlichie: String?
    var komment: String?
    var sluzh_otm: String?
    var data_sozd: String?
    var data_izm: String?
    var who_sozd: String?
    var who_red: String?
    var Деревня: String?
    var Уезд: String?
    var Губерния: String?
    
    init(from dict: [String: Any]) {
        // ID может быть строкой или числом
        if let idString = dict["id"] as? String {
            id = idString
        } else if let idInt = dict["id"] as? Int64 {
            id = String(idInt)
        } else if let idInt = dict["id"] as? Int {
            id = String(idInt)
        } else {
            id = UUID().uuidString
        }
        
        фамилия = dict["фамилия"] as? String
        имя = dict["имя"] as? String
        отчество = dict["отчество"] as? String
        komp = dict["komp"] as? String
        
        // nagrada, nomer, stepen могут быть Int или Int64
        if let nagradaInt = dict["nagrada"] as? Int {
            nagrada = nagradaInt
        } else if let nagradaInt64 = dict["nagrada"] as? Int64 {
            nagrada = Int(nagradaInt64)
        }
        
        if let nomerInt = dict["nomer"] as? Int {
            nomer = nomerInt
        } else if let nomerInt64 = dict["nomer"] as? Int64 {
            nomer = Int(nomerInt64)
        }
        
        if let stepenInt = dict["stepen"] as? Int {
            stepen = stepenInt
        } else if let stepenInt64 = dict["stepen"] as? Int64 {
            stepen = Int(stepenInt64)
        }
        chast = dict["chast"] as? String
        podrazdel1 = dict["podrazdel1"] as? String
        podrazdel2 = dict["podrazdel2"] as? String
        chin = dict["chin"] as? String
        dolzhnost = dict["dolzhnost"] as? String
        prikaz = dict["prikaz"] as? String
        data_prik = dict["data_prik"] as? String
        nomer_prik = dict["nomer_prik"] as? String
        otnosh = dict["otnosh"] as? String
        data_otnosh = dict["data_otnosh"] as? String
        nomer_otnosh = dict["nomer_otnosh"] as? String
        arxiv = dict["arxiv"] as? String
        fond = dict["fond"] as? String
        opis = dict["opis"] as? String
        delo = dict["delo"] as? String
        list = dict["list"] as? String
        drugie_ist = dict["drugie_ist"] as? String
        if let otl = dict["otlichie"] {
            if let intVal = otl as? Int {
                otlichie = String(intVal)
            } else {
                otlichie = otl as? String
            }
        }
        komment = dict["komment"] as? String
        sluzh_otm = dict["sluzh_otm"] as? String
        data_sozd = dict["data_sozd"] as? String
        data_izm = dict["data_izm"] as? String
        who_sozd = dict["who_sozd"] as? String
        who_red = dict["who_red"] as? String
        Деревня = dict["Деревня"] as? String
        Уезд = dict["Уезд"] as? String
        Губерния = dict["Губерния"] as? String
    }
    
    func getNagradaTypeShort() -> String {
        guard let nagradaType = nagrada else { return "-" }
        let names = [
            "ГК", "ГМ", "Св. Анна с 1864", "Св. Анна до 1864",
            "ГМ до 1913", "ГК до 1856", "ГК до 1913", "ГК для нехристиан",
            "Союзникам за войну 1812", "Куб. ледяной", "Степной", "ГК с 2008"
        ]
        if nagradaType >= 0 && nagradaType < names.count {
            return names[nagradaType]
        }
        return "-"
    }
    
    func getFullName() -> String {
        var parts: [String] = []
        if let f = фамилия, !f.isEmpty { parts.append(f) }
        if let i = имя, !i.isEmpty { parts.append(i) }
        if let o = отчество, !o.isEmpty { parts.append(o) }
        return parts.joined(separator: " ")
    }
}


