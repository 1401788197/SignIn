//
//  DetailViewController.swift
//  SignIn
//
//  Created by shengjie on 2022/6/19.
//

import UIKit

class DetailViewController: UITableViewController {
    /// 签到日期
    var signDate: Int64 = 0
    /// 当前日期签到数据
    var datas = [SignInModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = TimeUtils.dateYYYYMMdd(signDate) + "侧滑能删除打卡"
        setUp()
        queryData()
    }

    func queryData() {
        datas = DBQueryHelper.query(signDate)
        tableView.reloadData()
    }

    func setUp() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        let btn = UIButton(frame: .init(x: 0, y: 0, width: 60, height: 44))
        btn.setTitle("打卡", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }

    /// 签到
    @objc func signUp() {
        let nowTime = TimeUtils.nowTimeIntervalByYYYYMMdd()
        var supplementary = false
        /// 如果当前签到时间大日历日期 则为补签
        if nowTime > signDate {
            supplementary = true
        }
        print(supplementary ? "补卡" : "正常打卡")
        SignInManager.shared.signIn(date: Date.init(timeIntervalSince1970: Double(signDate)/1000), supplementary: supplementary) { sign in
            guard let sign = sign else {
                return
            }
            self.datas.append(sign)
            self.tableView.reloadData()
            NotificationCenter.default.post(name: .init(rawValue: kRefreshSignCount), object: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = TimeUtils.dateHHmmss(datas[indexPath.row].dateTime)
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let hide = UIContextualAction(style: .destructive, title: "删除") { _, _, completion in
            let model = self.datas[indexPath.row]
            SignInManager.shared.delete(model: model) { _ in
                self.datas.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                NotificationCenter.default.post(name: .init(rawValue: kRefreshSignCount), object: nil)
            }
            completion(true)
        }
        let conf = UISwipeActionsConfiguration(actions: [hide])

        return conf
    }

    deinit {
        print("---deinit\(Self.self)")
    }
}
