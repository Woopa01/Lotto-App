//
//  ViewController.swift
//  lotto
//
//  Created by 조우진 on 14/11/2018.
//  Copyright © 2018 조우진. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var lottoNumbers = Array<Array<Int>>()
    var databasePath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileMgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0]
        databasePath = docsDir + "/lotto.db"
        
        if !fileMgr.fileExists(atPath: databasePath as String){
            let db : FMDatabase? = FMDatabase(path: databasePath as String)
            
            if db == nil{
                NSLog("db 생성 오류")
            }
            
            if ((db?.open()) != nil){
                let sql_statment = "Create table if not exists lotto( id integer primary key autoincrement, number1 integer, number2 integer, number3 integer, number4 integer, number5 integer, number6 integer)"
                
                db?.executeQuery(sql_statment, withArgumentsIn: ["10"])
            }
            
            db?.close()
        } else {
            NSLog("db 연결오류")
        }
    }


    @IBAction func doDraw(_ sender: Any) {
        lottoNumbers = Array<Array<Int>>()
        
        var originalNumbers = Array(1 ... 45)
        var index = 0
        
        for _ in 0 ... 4{
            originalNumbers = Array(1...45)
            var columnArray = Array<Int>()
            
            for _ in 0 ... 5{
                index = Int(arc4random_uniform(UInt32(originalNumbers.count)))
                columnArray.append(originalNumbers[index])
                originalNumbers.remove(at: index)
            }
            columnArray.sort(by: {$0 < $1})
            lottoNumbers.append(columnArray)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func doSave(_ sender: Any) {
        let db : FMDatabase? = FMDatabase(path: databasePath as String)
        
        if db?.open() != nil {
            db?.executeQuery("delete from lotto", withArgumentsIn: ["10"])

            for numbers in lottoNumbers{
                let insertQuery = "insert into lotto(number1, number2, number3, number4, number5, number6) values (\(numbers[0]), \(numbers[1]), \(numbers[2]), \(numbers[3]), \(numbers[4]), \(numbers[5])"
                
                db?.executeQuery(insertQuery, withArgumentsIn: ["10"])
            }
        }
    }
    
    @IBAction func doLoad(_ sender: Any) {
        lottoNumbers = Array<Array<Int>>()
        let db : FMDatabase? = FMDatabase(path: databasePath as String)
        
        if db?.open() != nil{
            let selectQuery = "select number1, number2, number3, number4, number5, number6 from lotto"
            let result : FMResultSet? =
                db?.executeQuery(selectQuery, withArgumentsIn: ["10"])
            
            if result != nil{
                while result!.next(){
                    var columArray = Array<Int>()
                    columArray.append(Int(result!.string(forColumn: "number1") ?? " " )!)
                    columArray.append(Int(result!.string(forColumn: "number2") ?? " " )!)
                    columArray.append(Int(result!.string(forColumn: "number3") ?? " " )!)
                    columArray.append(Int(result!.string(forColumn: "number4") ?? " " )!)
                    columArray.append(Int(result!.string(forColumn: "number5") ?? " " )!)
                    columArray.append(Int(result!.string(forColumn: "number6") ?? " " )!)
                    lottoNumbers.append(columArray)
                }
            }
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lottoNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lottoCell", for: indexPath as IndexPath) as! LottoCell
        
        let row = indexPath.row
        
        cell.number1.text = "\(lottoNumbers[row][0])"
        cell.number2.text = "\(lottoNumbers[row][1])"
        cell.number3.text = "\(lottoNumbers[row][2])"
        cell.number4.text = "\(lottoNumbers[row][3])"
        cell.number5.text = "\(lottoNumbers[row][4])"
        cell.number6.text = "\(lottoNumbers[row][5])"
        
        return cell
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

