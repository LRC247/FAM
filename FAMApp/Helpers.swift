//
//  Helpers.swift
//  FAMApp
//
//  Created by Rohit Krishnan on 8/19/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}


extension SetBudgetController: UICollectionViewDataSource, RemoveCategoryDelegate {
    func removeCat(name: String) {
        var index = 0
        for i in 0...self.budgetType.categories.count - 1 {
            let cat = self.budgetType.categories[i]
            if name == cat.name {
                index = i
            }
        }
        self.budgetType.categories.remove(at: index)
        self.budgetCategories.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.budgetType?.categories.count)! + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < self.budgetType.categories.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BudgetItemCell", for: indexPath) as! BudgetItemCell
            cell.delegate = self
            cell.lblHeader.text = self.budgetType.categories[indexPath.row].name
            cell.lblPercent.text = "\(String(Int(round(self.budgetType.categories[indexPath.row].percentage))))%"
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddItemCell", for: indexPath) as! AddItemCell
            return cell
        }
    }
}

extension SetBudgetController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.item == self.budgetType.categories.count) {
            self.performSegue(withIdentifier: "addCategorySegue", sender: self)
        } else {
            chosenCategoryForEdit = self.budgetType.categories[indexPath.item]
            self.performSegue(withIdentifier: "editCategorySegue", sender: self)
        }
    }
}
