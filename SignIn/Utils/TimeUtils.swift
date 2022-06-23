//
//  TimeUtil.swift
//  SignIn
//
//  Created by shengjie on 2022/6/20.
//

import UIKit

/// 时间格式转换工具类
class TimeUtils: NSObject {
    /// 计算年与日时间戳
    static func timeIntervalByYYYYMMdd(_ time: String) -> Int64 {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: time)
        return (Int64(date?.timeIntervalSince1970 ?? 0)) * 1000
    }

    /// 计算当前年月日时间戳
    static func nowTimeIntervalByYYYYMMdd() -> Int64 {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let time = formatter.string(from: Date())
        return timeIntervalByYYYYMMdd(time)
    }

    /// 时间转换
    static func dateFormat(_ time: Int64, _ format: String) -> String {
        // 创建格式化器
        let date = Date(timeIntervalSince1970: Double(time / 1000))
        let dateFormatter = DateFormatter()
        // 设置需要的格式
        dateFormatter.dateFormat = format
        // 格式化
        return dateFormatter.string(from: date)
    }

    /// 获取指定日期时间戳（毫秒）
    static func dateTimeStamp(date: Date) -> Int64 {
        let calendar = NSCalendar(identifier: .chinese)
        let components = calendar?.components([.year, .month, .day], from: date)
        return Int64((calendar?.date(from: components!))!.timeIntervalSince1970 * 1000)
    }

    /// 将时间搓转换为年-月-日
    static func dateYYYYMMdd(_ time: Int64) -> String {
        return dateFormat(time, "yyyy-MM-dd")
    }

    /// 将时间搓转换为时-分-秒
    static func dateHHmmss(_ time: Int64) -> String {
        return dateFormat(time, "HH:mm:ss")
    }
}
