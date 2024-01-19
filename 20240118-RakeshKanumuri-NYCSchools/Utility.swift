//
//  Utils.swift
//  20240118-RakeshKanumuri-NYCSchools
//
//  Created by Rakesh kanumuri on 18/01/24.
//

import Foundation
import CoreLocation
import MapKit

class Utils {
    
    // This function will fetch the address without coodinates and returns: Stirng, address of the high school
    
    static func getCompleteAddressWithoutCoordinate(_ schoolAddr: String?) -> String{
        if let schoolAddress = schoolAddr{
            let address = schoolAddress.components(separatedBy: "(")
            return address[0]
        }
        return ""
    }
    
    // This method will fetch the coodinates for the selected High School location and returns: CLLocationCoordinate2D, coodinate of High School location
    static func getCoodinateForSelectedHighSchool(_ schoolAddr: String?) -> CLLocationCoordinate2D?{
        if let schoolAddress = schoolAddr{
            let coordinateString = schoolAddress.slice(from: "(", to: ")")
            let coordinates = coordinateString?.components(separatedBy: ",")
            if let coordinateArray = coordinates{
                let latitude = (coordinateArray[0] as NSString).doubleValue
                let longitude = (coordinateArray[1] as NSString).doubleValue
                return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            }
        }
        return nil
    }
    
    
    // This functions is used to fetch JSON data and assign parameter to the NYCHighSchools model
    //  Parameter json: Dictionany with Schools Detail
    //  Returns: High School Model type
    static func getHSInfoWithJSON(_ json: [String: Any]) -> NYCHighSchools?{
        if !json.isEmpty{
            let nycHighSchools = NYCHighSchools()
            if let dbnObject = json["dbn"] as? String{
                nycHighSchools.dbn = dbnObject
            }
            
            if let schoolNameOnject = json["school_name"] as? String{
                nycHighSchools.schoolName = schoolNameOnject
            }
            
            if let overviewParagraphObject = json["overview_paragraph"] as? String{
                nycHighSchools.overviewParagraph = overviewParagraphObject
            }
            if let schoolAddressObject = json["location"] as? String{
                nycHighSchools.schoolAddress = schoolAddressObject
            }
            if let schoolTelObject = json["phone_number"] as? String{
                nycHighSchools.schoolTelephoneNumber = schoolTelObject
            }
            
            if let websiteObject = json["website"] as? String{
                nycHighSchools.schoolWebsite = websiteObject
            }
            
            return nycHighSchools
        }
        return nil
    }
    
    // Pass the JSON and configure to the model type
    //  Parameter highSchoolsData: Data of Array composed with Dictionary
    //  Returns: Array of Model class
    
    static func fetchNYCHsWithJsonData(_ highSchoolsData: Any) -> [NYCHighSchools]?{
        guard let highSchoolsDictionaryArray = highSchoolsData as? [[String: Any]] else{
            return nil
        }
        var highSchoolModelArray = [NYCHighSchools]()
        for highSchoolsDictionary in highSchoolsDictionaryArray{
            if let highSchoolModels = Utils.getHSInfoWithJSON(highSchoolsDictionary){
                highSchoolModelArray.append(highSchoolModels)
            }
        }
        return highSchoolModelArray
    }
    
}

// (40.736526, -73.992727)
// added nd extension method Slice to divide lats and longs from "," to ")"
extension String {
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}


extension UIColor {
    
    // For random color of view in NYC hs custom cells
    class func randomColorForCardViewCell() -> UIColor {
        let lightRed: UIColor? = UIColor(red: 0.925, green: 0.290, blue: 0.255, alpha: 1.00)
        let lightBlue: UIColor? = UIColor(red: 0.000, green: 0.639, blue: 0.812, alpha: 1.00)
        let lightGray: UIColor? = UIColor(red: 0.773, green: 0.773, blue: 0.773, alpha: 1.00)
        let indigo: UIColor? = UIColor(red: 0.361, green: 0.420, blue: 0.753, alpha: 1.00)
        let green: UIColor? = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.00)
        let yellow: UIColor? = UIColor(red: 1.000, green: 0.933, blue: 0.345, alpha: 1.00)
        let deepOrange: UIColor? = UIColor(red: 1.000, green: 0.439, blue: 0.263, alpha: 1.00)
        
        let sideBarColorArr: [UIColor] = [lightRed!, lightBlue!, lightGray!, indigo!, green!, yellow!, deepOrange!]
        
        let randomNumber = arc4random_uniform(UInt32(sideBarColorArr.count))
        
        return sideBarColorArr[Int(randomNumber)]
    }
    
}
