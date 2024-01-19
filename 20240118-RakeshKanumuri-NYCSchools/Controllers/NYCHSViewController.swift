//
//  ViewController.swift
//  20240118-RakeshKanumuri-NYCSchools
//
//  Created by Rakesh kanumuri on 18/01/24.
//

import UIKit
import MapKit

class NYCHSViewController: UIViewController {
    // UI Components
    
    @IBOutlet var reloadBtn: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var nycHSList: [NYCHighSchools]?
    
    var filteredNycHSList = [NYCHighSchools]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "NYC high schools".uppercased()

        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchNYCHighSchoolInformation()
        }
    }
    
    // MARK: - Private instance methods
    
    func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Schools"
        searchController.searchBar.backgroundColor = UIColor.clear
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredNycHSList = (nycHSList?.filter({( schools : NYCHighSchools) -> Bool in
            return schools.schoolName!.lowercased().contains(searchText.lowercased())
        }))!
        
        tableView.reloadData()
    }
    
    @IBAction func reloadAction(_ sender: Any) {
        print("Reloading...")
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchNYCHighSchoolInformation()
        }
    }
    
    //MARK: - Fetch API and parse JSON data
    private func fetchNYCHighSchoolInformation(){
        guard let highSchoolsURL = URL(string: Constants.highSchoolsURL) else {
            return
        }
        
        let request = URLRequest(url:highSchoolsURL)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (highSchoolsData, response, error)  in
            if highSchoolsData != nil{
                do{
                    let highSchoolsObject = try JSONSerialization.jsonObject(with: highSchoolsData!, options: [])
                    self?.nycHSList = Utils.fetchNYCHsWithJsonData(highSchoolsObject)
                    self?.fetchHighSchoolSATSore()
                }catch{
                    print("NYC HS JSON error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    
    // This method will get data of High school SAT Score and add to model array
    private func fetchHighSchoolSATSore(){
        guard let highSchoolsSATScoreURL = URL(string: Constants.schoolWithSATScoreURL) else {
            return
        }
        let requestForSATScore = URLRequest(url:highSchoolsSATScoreURL)
        let task = URLSession.shared.dataTask(with: requestForSATScore) {[weak self] (schoolsWithSATScoreData, response, error) in
            if schoolsWithSATScoreData != nil{
                do{
                    let satScoreObject = try JSONSerialization.jsonObject(with: schoolsWithSATScoreData!, options: [])
                    self?.addSatScoreToHighSchool(satScoreObject)
                    DispatchQueue.main.async {[weak self] in
                        self?.tableView.reloadData()
                    }
                }catch{
                    debugPrint("high school with sat score json error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    // This method is used to add the SAT score to the high school
    // - Parameter satScoreObject: Data of Array composed with Dictionary
    private func addSatScoreToHighSchool(_ satScoreObject: Any){
        guard let highSchoolsWithSatScoreArr = satScoreObject as? [[String: Any]] else{
            return
        }
        
        for  highSchoolsWithSatScore in highSchoolsWithSatScoreArr{
            if let matchedDBN = highSchoolsWithSatScore["dbn"] as? String{
                //This will get the High School with the Common DBN
                let matchedHighSchools = self.nycHSList?.first(where: { (nycHighSchool) -> Bool in
                    return nycHighSchool.dbn == matchedDBN
                })
                
                guard matchedHighSchools != nil else{
                    continue
                }
                
                if let satReadingScoreObject =  highSchoolsWithSatScore["sat_critical_reading_avg_score"] as? String{
                    matchedHighSchools!.satCriticalReadingAvgScore = satReadingScoreObject
                }
                
                if let satMathScoreObject = highSchoolsWithSatScore["sat_math_avg_score"] as? String{
                    matchedHighSchools!.satMathAvgScore = satMathScoreObject
                }
                
                if let satWritingScoreObject =  highSchoolsWithSatScore["sat_writing_avg_score"] as? String{
                    matchedHighSchools!.satWritinAvgScore = satWritingScoreObject
                }
                
            }
        }
    }
    
    // MARK: Selector Functions
    
    // This method call to particular high school phone number
    @objc func callNumber(_ sender: UIButton){
    
        
        var nycHighSchoolList: NYCHighSchools
        
        if isFiltering() {
            nycHighSchoolList = filteredNycHSList[sender.tag]
        } else {
            nycHighSchoolList = self.nycHSList![sender.tag]
        }
        
        let schoolPhoneNumber = nycHighSchoolList.schoolTelephoneNumber
        
        if let url = URL(string: "tel://\(String(describing: schoolPhoneNumber))"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            let alertView = UIAlertController(title: "Error!", message: "Please run on a real device to call \(schoolPhoneNumber!)", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alertView.addAction(okayAction)
            
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    }

extension NYCHSViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


// MARK: UITableViewDataSource and UITableViewDelegate Extensions
extension NYCHSViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return self.filteredNycHSList.count
        }
        
        return self.nycHSList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NYCHSTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: Constants.hsCellIdentifier, for: indexPath) as! NYCHSTableViewCell
        
        tableView.rowHeight = 195
        
        var nycHighSchoolList: NYCHighSchools
        
        if isFiltering() {
            nycHighSchoolList = filteredNycHSList[indexPath.row]
        } else {
            nycHighSchoolList = self.nycHSList![indexPath.row]
        }
        
        
        if let schoolName = nycHighSchoolList.schoolName {
            cell.schoolNameLbl.text = schoolName
        }
        
        if let schoolAddr = nycHighSchoolList.schoolAddress {
            let address = Utils.getCompleteAddressWithoutCoordinate(schoolAddr)
            cell.schoolAddrLbl.text = "Address: \(address)"
            
        }
        
        if let phoneNum = nycHighSchoolList.schoolTelephoneNumber{
            cell.schoolPhoneNumBtn.setTitle("Phone # \(phoneNum)", for: .normal)
            
            cell.schoolPhoneNumBtn.tag = indexPath.row
            cell.schoolPhoneNumBtn.addTarget(self, action: #selector(self.callNumber(_:)), for: .touchUpInside)
        }
        
        
        
        
        return cell
    }
    
    //MARK: - UITable View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var nycHighSchoolList: NYCHighSchools
        
        if isFiltering() {
            nycHighSchoolList = filteredNycHSList[indexPath.row]
        } else {
            nycHighSchoolList = self.nycHSList![indexPath.row]
        }
        
        let selectedHighSchool = nycHighSchoolList
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "HSWithSATScore") as! NYCHSDetailTableViewController
        vc.HSWithSatScore = selectedHighSchool
        navigationController?.pushViewController(vc, animated: true)
        
    }
}


