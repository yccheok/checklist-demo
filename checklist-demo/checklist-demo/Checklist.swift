//
//  Checklist.swift
//  checklist-demo
//
//  Created by Yan Cheng Cheok on 02/10/2021.
//

struct Checklist: Hashable, Codable {
    let id: Int64
    var text: String?
    var checked: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Checklist, rhs: Checklist) -> Bool {
        return lhs.id == rhs.id
    }
}
