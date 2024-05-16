//
//  ViewController.swift
//  MovieCMU
//
//  Created by Induk-cs  on 2024/05/02.
//

import UIKit

struct MovieData : Codable {
    let boxOfficeResult : BoxOfficeResult
}
struct BoxOfficeResult : Codable {
    let dailyBoxOfficeList : [DailyBoxOfficeList]
}
struct DailyBoxOfficeList : Codable {
    let movieNm : String
    let audiCnt : String
    let audiAcc : String
    let rank : String
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    var movieData : MovieData?
    var movieURL = "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=d9dfbf5b0a8b138015b48bd3b9ecfe2b&targetDt="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        movieURL += makeYesterdayString()
        
        getData()
        // Do any additional setup after loading the view.
    }
    func makeYesterdayString() -> String {
        let today = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let yesterdayString = formatter.string(from: yesterday)
        return yesterdayString
    }
    func getData() {
        guard let url = URL(string: movieURL) else {return}
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url)  { data, response, error in
            if error != nil {
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            print(JSONdata)
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(MovieData.self, from: JSONdata)
                self.movieData = decodedData
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }catch{
                
            }        }
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        guard let mRank = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].rank else {return UITableViewCell()}
        guard let mName = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].movieNm else {return UITableViewCell()}
        cell.movieName.text = "[\(mRank)위] \(mName)"
        if let aAcc = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiAcc {
            let numF = NumberFormatter()
            numF.numberStyle = .decimal
            let aAccl = Int(aAcc)!
            let result = numF.string(for: aAccl)!+"명"
            cell.audiAccumulate.text = "누적 : \(result)"
            //cell.audiCount.text = "어제:\(aCnt)명"
        }
        if let aCnt = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiCnt {
            let numF = NumberFormatter()
            numF.numberStyle = .decimal
            let aCount = Int(aCnt)!
            let result = numF.string(for: aCount)!+"명"
            cell.audiCount.text = "어제 : \(result)"
            //cell.audiCount.text = "어제:\(aCnt)명"
        }
        //print(indexPath.description)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.description)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "🍿박스오피스(영화진흥위원회제공:"+makeYesterdayString()+")🍿"
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "by choimu"
    }
}

