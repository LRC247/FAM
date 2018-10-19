//
//  StartingBalanceController.swift
//  FAMApp
//
//  Created by Rohit Krishnan on 8/23/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import Foundation
import UIKit
import Charts

class ChartsController: UIViewController {
    var budgetType: BudgetType!;
    var chartTitle: String!;
    
    @IBOutlet weak var txtChartTitle: UILabel!
    
    @IBAction func btnDone(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    let pieChart: PieChartView = {
        let p = PieChartView()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.noDataText = "No date to display"
        return p
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        setupPieChart()
        fillChart()
        self.txtChartTitle.text = chartTitle
    }
    
    func setupPieChart() {
        view.addSubview(pieChart)
        pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        pieChart.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        pieChart.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        pieChart.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 1
        pieChart.data?.setValueFormatter(DefaultValueFormatter())
    }
    
    func fillChart() {
        var dataEntries = [PieChartDataEntry]()

        
        for category in self.budgetType.categories {
            
            let entry = PieChartDataEntry(value: category.amount!, label: category.name)
            dataEntries.append(entry)
        }
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.material()
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 5

        let chartData = PieChartData(dataSet: chartDataSet)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        pieChart.data = chartData
    }
}
