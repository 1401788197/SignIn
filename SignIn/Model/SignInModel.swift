//
//  DetailModel.swift
//  SignIn
//
//  Created by shengjie on 2022/6/19.
//

import UIKit
import WCDBSwift

/// 签到模型
class SignInModel: NSObject, TableCodable {
    
    /// 主键自增id
    var identifier: Int?
    /// 签到日期时间戳（当天0点，毫秒）
    var date: Int64 = 0
    /// 签到时间戳（毫秒）
    var dateTime: Int64 = 0
    /// 是否是补签（默认为正常打卡）
    var supplementary: Bool = false
    /// 连续签到天数
    var continuousSignCount: Int32 = 0
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = SignInModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case identifier = "id"
        case supplementary
        case dateTime
        case date
        case continuousSignCount
        
        // 设置主键
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                .identifier: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
}
