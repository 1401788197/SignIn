//
//  SignInManager.swift
//  SignIn
//
//  Created by shengjie on 2022/6/22.
//

import UIKit

/// 签到管理类
class SignInManager: NSObject {
    /// 实例
    static let shared = SignInManager()

    override private init() {
        super.init()
    }

    /**
     *  创建签到记录表
     *
     *  @return 创建结果
     */
    open func createTable() -> Bool {
        return DBQueryHelper.createSignInTable()
    }

    /**
     *  记录签到数据
     *
     *  @param date 签到日期
     *  @param supplementary 是否是补签（true：补签，false：正常打卡）
     *  @param result 签到结果回调（如果签到成功则返回签到模型，否则返回nil）
     */
    open func signIn(date: Date, supplementary: Bool, result: @escaping (SignInModel?) -> Void) {
        // 组装签到模型数据
        let signIn = SignInModel()
        signIn.dateTime = Int64(Date().timeIntervalSince1970 * 1000)
        signIn.supplementary = supplementary
        signIn.date = TimeUtils.dateTimeStamp(date: date)

        // 查询当前日期上一天签到数据
        query(date: date.addingTimeInterval(-3600 * 24)) { models in
            if models.count > 0 {
                signIn.continuousSignCount = models.first!.continuousSignCount + 1
            } else {
                signIn.continuousSignCount = 1
            }

            // 保存数据
            DispatchQueue.global().async {
                // 补签时需要重新计算连续签到次数
                if supplementary {
                    self.adjusContinuousSignInDays(date: signIn.date, count: signIn.continuousSignCount)
                }
                let success = DBQueryHelper.sign(signIn)
                DispatchQueue.main.async {
                    result(success ? signIn : nil)
                }
            }
        }
    }

    /**
     *  删除指定签到数据
     *
     *  @param model 签到记录数据
     *  @param result 删除结果回调
     */
    open func delete(model: SignInModel, result: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let success = DBQueryHelper.delete(identifier: model.identifier ?? 0)
            if success {
                self.adjusContinuousSignInDays(date: model.date, count: -model.continuousSignCount)
            }
            DispatchQueue.main.async {
                result(success)
            }
        }
    }

    /**
     *  删除所有签到数据
     *
     *  @param model 签到记录数据
     *  @param result 删除结果回调
     */
    open func deleteTotleDatas(result: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let success = DBQueryHelper.deleteTotleDatas()
            DispatchQueue.main.async {
                result(success)
            }
        }
    }

    /**
     *  查询指定日期的所有打卡数据
     *
     *  @param date 需要查询的日期
     *  @param result 查询结果回调
     */
    open func query(date: Date, result: @escaping ([SignInModel]) -> Void) {
        let timestamp = TimeUtils.dateTimeStamp(date: date)
        DispatchQueue.global().async {
            let signIns = DBQueryHelper.query(timestamp)
            DispatchQueue.main.async {
                result(signIns)
            }
        }
    }

    /**
     *  查询历史最大连续打卡次数
     *
     *  @param result 查询结果回调
     */
    open func queryMaxContinuousSignInDays(result: @escaping (Int) -> Void) {
        DispatchQueue.global().async {
            let days = DBQueryHelper.queryMaxContinuousSignInDays()
            DispatchQueue.main.async {
                result(days)
            }
        }
    }

    /**
     *  查询当前最大连续打卡次数
     *
     *  @param result 查询结果回调
     */
    open func queryNowMaxContinuousSignInDays(result: @escaping (Int) -> Void) {
        DispatchQueue.global().async {
            var model = DBQueryHelper.query(TimeUtils.nowTimeIntervalByYYYYMMdd()).first
            if model == nil {
                model = DBQueryHelper.query(TimeUtils.nowTimeIntervalByYYYYMMdd() - 24 * 60 * 60 * 1000).first
            }
            DispatchQueue.main.async {
                guard let model = model else {
                    result(0)
                    return
                }
                result(Int(model.continuousSignCount))
            }
        }
    }

    /**
     *  查询所有打卡次数
     *
     *  @param result 查询结果回调
     */
    open func queryTotleSignInCounts(result: @escaping (Int) -> Void) {
        DispatchQueue.global().async {
            let count = DBQueryHelper.queryTotleList().count
            DispatchQueue.main.async {
                result(count)
            }
        }
    }

    /**
     *  查询总的打卡天数
     *
     *  @param result 查询结果回调
     */
    open func queryTotalSignInDays(result: @escaping (Int) -> Void) {
        DispatchQueue.global().async {
            let signIns = DBQueryHelper.queryTotalSignInDays()
            DispatchQueue.main.async {
                result(signIns)
            }
        }
    }
}

extension SignInManager {
    /// 重新设置连续签到天数
    fileprivate func adjusContinuousSignInDays(date: Int64, count: Int32) {
        // 检查当天签到是否存在, 不存在才调整
        guard DBQueryHelper.query(date).count <= 0 else {
            return
        }

        // 查询下一天是否有数据, 没有则不调整
        guard DBQueryHelper.query(date + 3600 * 24).count <= 0 else {
            return
        }

        // 查询当前日期之后所有的连续签到数据
        let signInModel = queryFirstBegainSignIn(after: date)
        let timestamp = signInModel?.date ?? Int64.max
        let signInModels = query(startDate: date, endDate: timestamp)
        for item in signInModels {
            item.continuousSignCount += count
        }
        DBQueryHelper.update(signInModels)
    }

    /// 查询指定日期之后第一个签到数据
    fileprivate func queryFirstBegainSignIn(after date: Int64) -> SignInModel? {
        let result = DBQueryHelper.queryFirstBegainSignIn(after: date)
        return result.count > 0 ? result.first : nil
    }

    /// 查询指定区间的所有签到数据（不包含）
    fileprivate func query(startDate: Int64, endDate: Int64) -> [SignInModel] {
        return DBQueryHelper.query(startDate: startDate, endDate: endDate)
    }
}
