//
//  YMNetworkTool.swift
//  TodayNews
//
//  Created by 杨蒙 on 16/7/30.
//  Copyright © 2016年 hrscy. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON
import MJRefresh

class YMNetworkTool: NSObject {
    /// 单例
    static let shareNetworkTool = YMNetworkTool()
    
    /// ------------------------ 首 页 -------------------------
    //
    /// 获取首页顶部标题内容
    func loadHomeTitlesData(finished:(topTitles: [YMTopic])->()) {
        let url = BASE_URL + "article/category/get_subscribed/v1/?iid=\(IID)&aid=13"
        Alamofire
            .request(.GET, url)
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    SVProgressHUD.showErrorWithStatus("加载失败...")
                    return
                }
                if let value = response.result.value {
                    let json = JSON(value)
                    let dataDict = json["data"].dictionary
                    if let data = dataDict!["data"]!.arrayObject {
                        var topics = [YMTopic]()
                        for dict in data {
                            let title = YMTopic(dict: dict as! [String: AnyObject])
                            topics.append(title)
                        }
                        finished(topTitles: topics)
                    }
                }
        }
    }
    
    
    /// 首页 -> 添加标题，获取推荐标题内容
    func loadRecommendTopic(finished:(recommendTopics: [YMTopic]) -> ()) {
        let url = "https://lf.snssdk.com/article/category/get_extra/v1/?iid=\(IID)&aid=13"
        Alamofire
            .request(.GET, url)
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    SVProgressHUD.showErrorWithStatus("加载失败...")
                    return
                }
                if let value = response.result.value {
                    let json = JSON(value)
                    if let data = json["data"].arrayObject {
                        var topics = [YMTopic]()
                        for dict in data {
                            let title = YMTopic(dict: dict as! [String: AnyObject])
                            topics.append(title)
                        }
                        finished(recommendTopics: topics)
                    }
                }
        }
    }
    
    /// -------------------------- 视 频 --------------------------
    //
    /// 获取视频顶部标题内容
    func loadVideoTitlesData(finished:(topTitles: [YMVideoTopTitle])->()) {
        let url = BASE_URL + "video_api/get_category/v1/?iid=\(IID)&aid=13"
        Alamofire
            .request(.GET, url)
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    SVProgressHUD.showErrorWithStatus("加载失败...")
                    return
                }
                if let value = response.result.value {
                    let json = JSON(value)
                    if let data = json["data"].arrayObject {
                        var titles = [YMVideoTopTitle]()
                        for dict in data {
                            let title = YMVideoTopTitle(dict: dict as! [String: AnyObject])
                            titles.append(title)
                        }
                        finished(topTitles: titles)
                    }
                }
        }
    }
    
    /// -------------------------- 关 心 --------------------------
    //
    /// 获取新的 关心数据列表
    func loadNewConcernList(tableView: UITableView, finished:(topConcerns: [YMConcern], bottomConcerns: [YMConcern]) -> ()) {
        let url = BASE_URL + "concern/v1/concern/list/"
        let params = ["iid": IID,
                      "count": 20,
                      "offset": 0,
                      "type": "manage"]
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            Alamofire
                .request(.POST, url, parameters: params as? [String : AnyObject])
                .responseJSON { (response) in
                    tableView.mj_header.endRefreshing()
                    guard response.result.isSuccess else {
                        SVProgressHUD.showErrorWithStatus("加载失败...")
                        return
                    }
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let concern_list = json["concern_list"].arrayObject {
                            var topConcerns = [YMConcern]()
                            var bottomConcerns = [YMConcern]()
                            for dict in concern_list {
                                let concern = YMConcern(dict: dict as! [String: AnyObject])
                                (concern.concern_time != 0) ? topConcerns.append(concern) : bottomConcerns.append(concern)
                            }
                            finished(topConcerns: topConcerns, bottomConcerns: bottomConcerns)
                        }
                    }
            }
        })
        tableView.mj_header.automaticallyChangeAlpha = true //根据拖拽比例自动切换透明度
        tableView.mj_header.beginRefreshing()
    }
    
    /// 获取新的 关心数据列表，不显示上拉刷新
    func loadNewConcernListHiddenPullRefresh(finished:(topConcerns: [YMConcern], bottomConcerns: [YMConcern]) -> ()) {
        let url = BASE_URL + "concern/v1/concern/list/"
        let params = ["iid": IID,
                      "count": 20,
                      "offset": 0,
                      "type": "manage"]
        Alamofire
            .request(.POST, url, parameters: params as? [String : AnyObject])
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    SVProgressHUD.showErrorWithStatus("加载失败...")
                    return
                }
                if let value = response.result.value {
                    let json = JSON(value)
                    if let concern_list = json["concern_list"].arrayObject {
                        var topConcerns = [YMConcern]()
                        var bottomConcerns = [YMConcern]()
                        for dict in concern_list {
                            let concern = YMConcern(dict: dict as! [String: AnyObject])
                            (concern.concern_time != 0) ? topConcerns.append(concern) : bottomConcerns.append(concern)
                        }
                        finished(topConcerns: topConcerns, bottomConcerns: bottomConcerns)
                    }
                }
        }
    }
    
    /// 获取更多 关心数据列表
    func loadMoreConcernList(tableView: UITableView, outOffset: Int, finished:(inOffset: Int, topConcerns: [YMConcern], bottomConcerns: [YMConcern]) -> ()) {
        let url = BASE_URL + "concern/v1/concern/list/"
        let params = ["iid": IID,
                      "count": 20,
                      "offset": outOffset,
                      "type": "recommend"]
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { 
            Alamofire
                .request(.POST, url, parameters: params as? [String : AnyObject])
                .responseJSON { (response) in
                    tableView.mj_footer.endRefreshing()
                    guard response.result.isSuccess else {
                        SVProgressHUD.showErrorWithStatus("加载失败...")
                        return
                    }
                    if let value = response.result.value {
                        let json = JSON(value)
                        let inOffset = json["offset"].int!
                        if let concern_list = json["concern_list"].arrayObject {
                            var topConcerns = [YMConcern]()
                            var bottomConcerns = [YMConcern]()
                            for dict in concern_list {
                                let concern = YMConcern(dict: dict as! [String: AnyObject])
                                (concern.concern_time != 0) ? topConcerns.append(concern) : bottomConcerns.append(concern)
                            }
                            finished(inOffset: inOffset, topConcerns: topConcerns, bottomConcerns: bottomConcerns)
                        }
                    }
            }
        })
    }
    
    /// 关心界面 -> 底部 cell 的『关心』按钮 点击
    func bottomCellDidClickedCareButton(concernID: String, tableView: UITableView, finish:(topConcerns: [YMConcern], bottomConcerns: [YMConcern])->()) {
        let url = BASE_URL + "concern/v1/commit/care/"
        let params = ["iid": IID, "concern_id": concernID]
        Alamofire
            .request(.POST, url, parameters: params as? [String : AnyObject])
        .responseJSON { (response) in
            guard response.result.isSuccess else {
                SVProgressHUD.showErrorWithStatus("加载失败...")
                return
            }
            YMNetworkTool.shareNetworkTool.loadNewConcernListHiddenPullRefresh({ (topConcerns, bottomConcerns) in
                finish(topConcerns: topConcerns, bottomConcerns: bottomConcerns)
            })
        }
        
    }
    
    /// 关心界面 -> 搜索关心类别和内容
    func loadSearchResult(keyword: String, finished:(keywords: [YMKeyword]) -> ()) {
        let url = BASE_URL + "2/article/search_sug/?keyword=\(keyword)"
        Alamofire
            .request(.GET, url)
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    SVProgressHUD.showErrorWithStatus("加载失败...")
                    return
                }
                if let value = response.result.value {
                    let json = JSON(value)
                    if let datas = json["data"].arrayObject {
                        var keywords = [YMKeyword]()
                        for data in datas {
                            let keyword = YMKeyword(dict: data  as! [String: AnyObject])
                            keywords.append(keyword)
                        }
                        finished(keywords: keywords)
                    }
                }
        }
    }
    
}
