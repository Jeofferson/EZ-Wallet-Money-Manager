//
//  Constants.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/16/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation


class Constants {
    
    
    static let PREV_LIGHT = "prev_light"
    static let NEXT_LIGHT = "next_light"
    static let PREV_DISABLED_LIGHT = "prev_disabled_light"
    static let NEXT_DISABLED_LIGHT = "next_disabled_light"
    
    static let MALE_DEFAULT_ICON_FILENAME = "male_default_icon.png"
    static let FEMALE_DEFAULT_ICON_FILENAME = "female_default_icon.png"
    
    
    static let IMAGE_HELP_FILE_NAME_LIST = [
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h"
    ]
    
    
    static let HELP_DESCRIPTION_LIST = [
        "Monitor your yearly expenses and savings.",
        "Budget your monthly balance.",
        "Record the actual expenses.",
        "Plenty of categories for you to choose from. You can also create your own!",
        "Record your borrowers so you won't forget them. You can also set an interest rate!",
        "Keep track of all the money you lent with ease.",
        "Record your borrower's payments. Interests are automatically recorded!",
        "Interactive charts that will give you the overview of your money transactions!"
    ]
    
    
    static let MONTHS_OF_THE_YEAR = [
        1: ["Jan", "January"],
        2: ["Feb", "February"],
        3: ["Mar", "March"],
        4: ["Apr", "April"],
        5: ["May", "May"],
        6: ["June", "June"],
        7: ["July", "July"],
        8: ["Aug", "August"],
        9: ["Sep", "September"],
        10: ["Oct", "October"],
        11: ["Nov", "November"],
        12: ["Dec", "December"]
    ]
    
    static let YEAR_LIST = [
        Year(id: 0, yearName: "2020")
    ]
    
    static let MONTH_LIST = [
        Month(id: 0, monthName: "January", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 1, monthName: "February", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 2, monthName: "March", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 3, monthName: "April", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 4, monthName: "May", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 5, monthName: "June", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 6, monthName: "July", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 7, monthName: "August", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 8, monthName: "September", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 9, monthName: "October", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 10, monthName: "November", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0),
        Month(id: 11, monthName: "December", yearName: "2020", startingBalance: 0.0, totalExpenses: 0.0, totalSavings: 0.0)
    ]
    
    static let CATEGORY_LIST = [
        Category(id: 0, categoryName: "Mobile"),
        Category(id: 1, categoryName: "Bike"),
        Category(id: 2, categoryName: "Rent"),
        Category(id: 3, categoryName: "Shopping"),
        Category(id: 4, categoryName: "Clothes"),
        Category(id: 5, categoryName: "Eating Out"),
        Category(id: 6, categoryName: "Kids"),
        Category(id: 7, categoryName: "Gifts"),
        Category(id: 8, categoryName: "Fuel"),
        Category(id: 9, categoryName: "Holidays"),
        Category(id: 10, categoryName: "Travel"),
        Category(id: 11, categoryName: "Entertainment"),
        Category(id: 12, categoryName: "Sports"),
        Category(id: 13, categoryName: "General"),
        Category(id: 14, categoryName: "Other"),
    ]
    
    static let AMORTIZATION_SCHEDULE_OPTIONS = [
        "Daily",
        "Weekly",
        "Monthly",
        "Quarterly",
        "Semiannually",
        "Annually"
    ]
    
    
}
