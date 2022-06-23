//
//  DBManager.swift
//  SignIn
//
//  Created by shengjie on 2022/6/19.
//

import UIKit
import WCDBSwift

/// 数据库管理类
class DBManager: NSObject {
    
    static let shared = DBManager()

    /// 数据库
    var dataBase: Database?

    /// 创建表
    func createDB(path: String, uid: String) -> Bool {
        
        let filePath = path + "/sign"
        let dataBasePath = URL(fileURLWithPath: filePath)
        
        print("数据库地址" + filePath)
        
        dataBase = Database(withFileURL: dataBasePath)

        if dataBase!.canOpen {
            return true
        } else {
            return false
        }
    }

    /// 创建表
    func createTable<T: TableDecodable>(table: String, of ttype: T.Type) -> Bool {
        do {
            try dataBase?.create(table: table, of: ttype)
        } catch let error {
            debugPrint("create table error \(error.localizedDescription)")
            return false
        }
        return true
    }

    /// 插入
    func insertToDb<T: TableEncodable>(objects: [T], intoTable table: String) -> Bool {
        do {
            try dataBase?.insert(objects: objects, intoTable: table)
        } catch let error {
            debugPrint(" insert obj error \(error.localizedDescription)")
            return false
        }
        return true
    }

    /// 替换
    func insertOrReplaceDB<T: TableEncodable>(objects: [T], intoTable table: String) -> Void {
        do {
            try dataBase?.insertOrReplace(objects: objects, intoTable: table)
        } catch let error {
            debugPrint(" insert obj error \(error.localizedDescription)")
        }
    }

    /// 修改
    func updateToDb<T: TableEncodable>(table: String, on propertys: [PropertyConvertible], with object: T, where condition: Condition? = nil) -> Void {
        do {
            try dataBase?.update(table: table, on: propertys, with: object, where: condition)
        } catch let error {
            debugPrint(" update obj error \(error.localizedDescription)")
        }
    }

    func updateToProperty(table: String, on propertys: PropertyConvertible..., with objcet: [ColumnEncodable], where condition: Condition? = nil) {
        do {
            try dataBase?.update(table: table, on: propertys, with: objcet, where: condition)

        } catch let error {
            debugPrint(" update obj error \(error.localizedDescription)")
        }
    }

    /// 删除
    func deleteFromDb(fromTable: String, where condition: Condition? = nil) -> Bool {
        do {
            try dataBase?.delete(fromTable: fromTable, where: condition)
        } catch let error {
            debugPrint("delete error \(error.localizedDescription)")
            return false
        }
        return true
    }

    /// 查询
    func qureyFromDb<T: TableDecodable>(fromTable: String, cls cName: T.Type, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil) -> [T]? {
        do {
            let allObjects: [T] = try (dataBase?.getObjects(fromTable: fromTable, where: condition, orderBy: orderList, limit: limit))!
            return allObjects
        } catch let error {
            debugPrint("no data find \(error.localizedDescription)")
        }
        return nil
    }
    
    func qureyDistinctCountFromDb(on: ColumnResultConvertible, fromTable: String) -> Int {
        do {
            let allObjects = try (dataBase?.getDistinctColumn(on: on, fromTable: fromTable))
            return allObjects?.count ?? 0
        } catch let error {
            debugPrint("no data find \(error.localizedDescription)")
        }
        return 0
    }
    
    func qureyVauleFromDb(on: ColumnResultConvertible, fromTable: String, where condition: Condition? = nil) -> Int {
        do {
            let allObjects = try (dataBase?.getValue(on: on, fromTable: fromTable, where: condition))
            return Int(allObjects?.int64Value ?? 0)
        } catch let error {
            debugPrint("no data find \(error.localizedDescription)")
        }
        return 0
    }

    /// 查询一个数据
    func qureyOneObjecFromDB<T: TableDecodable>(fromTable: String, cls cName: T.Type, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil) -> T? {
        do {
            return try (dataBase?.getObject(fromTable: fromTable, where: condition))

        } catch let error {
            debugPrint("no data find \(error.localizedDescription)")
        }
        return nil
    }

    /// 删除数据表
    func dropTable(table: String) {
        do {
            try dataBase?.drop(table: table)
        } catch let error {
            debugPrint("drop table error \(error)")
        }
    }

    /// 删除所有与该数据库相关的文件
    func removeDbFile() {
        do {
            try dataBase?.close(onClosed: {
                try dataBase?.removeFiles()
            })
        } catch let error {
            debugPrint("not close db \(error)")
        }
    }
}
