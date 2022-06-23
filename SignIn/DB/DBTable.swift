//
//  DBTable.swift
//  SignIn
//
//  Created by shengjie on 2022/6/20.
//

import UIKit

class DBTable: NSObject {
    
    /// 数据库 - 表名称
    private enum TableName: String {
        case signTable
    }

    /// 签到表名称
    static var sign: String {
        return TableName.signTable.rawValue
    }
}
