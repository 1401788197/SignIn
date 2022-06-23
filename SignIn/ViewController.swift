//
//  ViewController.swift
//  SignIn
//
//  Created by shengjie on 2022/6/22.
//

import RxCocoa
import RxSwift
import UIKit
class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    /// 打卡信息
    @IBOutlet var stackInfoView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        notification()
        queryAction()
    }

    private func notification() {
        NotificationCenter.default.rx.notification(.init(rawValue: kRefreshSignCount)).subscribe(onNext: {
            [weak self] _ in
            self?.queryAction()
        }).disposed(by: disposeBag)
    }

    private func setUI() {
        let calendar = GFCalendarView(frameOrigin: .init(x: 10, y: 200), width: view.frame.width - 20)
        view.addSubview(calendar!)
        calendar?.didSelectDayHandler = {[weak self]
            year, month, day in
            let nowTime = TimeUtils.nowTimeIntervalByYYYYMMdd()
            let time = String(format: "%d-%02d-%02d", year, month, day)
            let calendarTime = TimeUtils.timeIntervalByYYYYMMdd(time)
            if calendarTime > nowTime {
                print("未来时间不能签到")
                return
            }
            let vc = DetailViewController()
            vc.signDate = calendarTime
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    /// 清空数据
    @IBAction func clearDatas(_ sender: Any) {
        SignInManager.shared.deleteTotleDatas { result in
            guard result else {
                print("删除失败")
                return
            }
            self.queryAction()
        }
    }
}

extension ViewController {
    /// 签到事件
    @objc func signInAction(_ sender: Any) {
        // 签到
        SignInManager.shared.signIn(date: Date().addingTimeInterval(3600 * 24 * 2), supplementary: true) { sign in
            print("签到结果: \(String(describing: sign))")
        }
    }

    /// 查询打卡数据
    func queryAction() {
        // 查询总的打卡天数
        SignInManager.shared.queryTotalSignInDays { count in
            (self.stackInfoView.subviews[0] as! UILabel).text = "总打卡天数: \(count)"
        }

        // 查询历史最大连续打卡天数
        SignInManager.shared.queryMaxContinuousSignInDays { count in
            (self.stackInfoView.subviews[1] as! UILabel).text = "历史最大连续打卡天数: \(count)"
        }
        // 查询总打卡次数
        SignInManager.shared.queryTotleSignInCounts { count in
            (self.stackInfoView.subviews[2] as! UILabel).text = "累计打卡次数: \(count)"
        }
        // 查询当前连续打卡天数
        SignInManager.shared.queryNowMaxContinuousSignInDays { count in
            (self.stackInfoView.subviews[3] as! UILabel).text = "当前最大连续打卡天数: \(count)"
        }
    }

    /// 删除打卡
    @objc func deleteAction(_ sender: Any) {
        // 签到
        SignInManager.shared.query(date: Date().addingTimeInterval(3600 * 24 * 1)) { models in
            for item in models {
                SignInManager.shared.delete(model: item) { _ in
                    debugPrint("删除成功")
                }
            }
        }
    }
}
