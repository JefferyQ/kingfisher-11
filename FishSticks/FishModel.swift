//
//  FishModel.swift
//  FishSticks
//
//  Created by Miwand Najafe on 2016-04-24.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import Foundation

class FishModel {
    private var _species: String!
    private var _length:String!
    private var _weight:String!
    private var _breadth:String!
    private var _sex:String!
   
    var species:String {
        return _species
    }
    var length:String {
        return _length
    }
    var weight:String {
        return _weight
    }
    var breadth:String {
        return _breadth
    }
    var sex:String {
        return _sex
    }
    init(species:String, length:String,weight:String,breadth:String,sex:String) {
        self._species = species
        self._weight = weight
        self._sex = sex
        self._breadth = breadth
        self._length = length
    }
}