//
//  DBQueryHelper.swift
//  SignIn
//
//  Created by shengjie on 2022/6/20.
//

import UIKit
import WCDBSwift

class DBQueryHelper: NSObject {
    /// 创建数签到表
    static func createDB(uuid: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/" + uuid
        return DBManager.shared.createDB(path: path, uid: uuid)
    }

    /// 创建签到表
    static func createSignInTable() -> Bool {
        return DBManager.shared.createTable(table: DBTable.sign, of: SignInModel.self)
    }

    /// 记录签到数据
    static func sign(_ model: SignInModel) -> Bool {
        return DBManager.shared.insertToDb(objects: [model], intoTable: DBTable.sign)
    }

    /// 更新签到数据
    static func update(_ models: [SignInModel]) {
        DBManager.shared.insertOrReplaceDB(objects: models, intoTable: DBTable.sign)
    }

    /// 查询指定日期的所有签到数据
    static func query(_ date: Int64) -> [SignInModel] {
        let query = SignInModel.Properties.date == date
        return DBManager.shared.qureyFromDb(fromTable: DBTable.sign, cls: SignInModel.self, where: query, orderBy: nil) ?? []
    }

    /// 查询所有签到数据
    static func queryTotleList() -> [SignInModel] {
        return DBManager.shared.qureyFromDb(fromTable: DBTable.sign, cls: SignInModel.self, where: nil, orderBy: nil) ?? []
    }

    /// 查询总的打卡天数
    static func queryTotalSignInDays() -> Int {
        return DBManager.shared.qureyDistinctCountFromDb(on: SignInModel.Properties.date, fromTable: DBTable.sign)
    }

    ///  查询历史最大连续打卡天数
    static func queryMaxContinuousSignInDays() -> Int {
        return DBManager.shared.qureyVauleFromDb(on: SignInModel.Properties.continuousSignCount.max(), fromTable: DBTable.sign, where: nil)
    }

    /// 删除指定打卡数据
    static func delete(identifier: Int) -> Bool {
        let query = SignInModel.Properties.identifier == identifier
        return DBManager.shared.deleteFromDb(fromTable: DBTable.sign, where: query)
    }
    
    /// 删除所有数据
    static func deleteTotleDatas() -> Bool {
        return DBManager.shared.deleteFromDb(fromTable: DBTable.sign, where: nil)
    }

    /* /// 更新连续打卡天数
     static func updateContinuousSignInDays(date: Int64, count: Int64) -> Void {

     } */

    /// 查询指定日期之后第一个签到数据
    static func queryFirstBegainSignIn(after date: Int64) -> [SignInModel] {
        let query = (SignInModel.Properties.date > date) || (SignInModel.Properties.continuousSignCount == 1)
        return DBManager.shared.qureyFromDb(fromTable: DBTable.sign, cls: SignInModel.self, where: query, orderBy: nil, limit: 1) ?? []
    }

    /// 查询最新的一个签到数据
    static func queryNewestSignIn() -> SignInModel? {
        let query = SignInModel.Properties.date > 0
        let orderBy: [OrderBy] = [SignInModel.Properties.dateTime.asOrder(by: .descending)]
        return DBManager.shared.qureyFromDb(fromTable: DBTable.sign, cls: SignInModel.self, where: query, orderBy: orderBy)?.first
    }

    /// 查询指定区间的所有签到数据（不包含）
    static func query(startDate: Int64, endDate: Int64) -> [SignInModel] {
        let query = (SignInModel.Properties.date > startDate) || (SignInModel.Properties.date < endDate)
        return DBManager.shared.qureyFromDb(fromTable: DBTable.sign, cls: SignInModel.self, where: query, orderBy: nil) ?? []
    }
}
