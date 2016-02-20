//
//  Hyphenator.swift
//  Hyphenator
//
//  Created by YanHan on 16/1/31.
//  Copyright © 2016年 Takefive Interactive. All rights reserved.
//
//  Ported to Swift, Original from:
//	http://nedbatchelder.com/code/modules/hyphenate.py

import Foundation
import PySwiftyRegex


public class TrieNode {
    var hash = [Character : TrieNode]()
    var None: [String?]!
    init() {
        for char in "abcdefghijklmnopqrstuvwxyz".characters {
            hash[char] = nil
        }
        
    }
    // str not ""
    func insert(str: String, point: [String?]) {
        
        if hash[str.characters.first!] == nil{
            hash[str.characters.first!] = TrieNode()
        }
        if str.characters.count > 1{
            var str_substring = str as NSString
            
            str_substring = str_substring.substringWithRange(NSRange(location: 1, length: str.characters.count-1))
            hash[str.characters.first!]?.insert(str_substring as String, point: point)
        }else{
            None = point
        }
        
    }
    
}


class Hyphenator:NSObject {
    
    var tree = TrieNode()
    var self_exceptions = [String:[String]]()
    override init () {
        
        super.init()
        for pattern in patterns {
            self._insert_pattern(pattern)
            
            }
        for ex in exceptions {
            //Convert the hyphenated pattern into a point array for use later.
            
            var out = re.split("[a-z]", ex)
            var num_out = [String]()
            for el in out {
                if el == "" {
                    num_out.append("0")
                }
                else if el == "-" {
                    num_out.append("1")
                }
            }
            self_exceptions[
                ex.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                ] = ["0"]+num_out
        }
        
    }
    
    func _insert_pattern(pattern: String) {
        //Convert the a pattern like 'a1bc3d4' into a string of chars 'abcd'
        //and a list of points [ 1, 0, 3, 4 ].
        var chars = re.sub("[0-9]", "", pattern)
        var out = re.split("[.a-z]", pattern)
        
        var points = [String?]()
        for el in out {
            if el == "" {
                points.append("0")
            }
            else if el == "-" {
                points.append(el)
            }
        }
        
        //        points.removeAtIndex(0)
        var index = 0
        for el in points {
            if el == "" {
                points[index] = "0"
            }
            index += 1
        }
        
        //Insert the pattern into the tree.  Each character finds a dict
        //another level down in the tree, and leaf nodes have the list of
        //points.
        
        self.tree.insert(chars,point: points)
        
    }
    func hyphenate_word(word:String) -> [String] {
        //Given a word, returns a list of pieces, broken at the possible
        //hyphenation points.
        
        //Short words aren't hyphenated.
        if word.characters.count <= 4 {
            return [word]
        }
        
        var points = [String]()
        
        //If the word is an exception, get the stored points.
        if exceptions.contains(word.lowercaseString) {
            points = self_exceptions[word]!
        }
        else {
            var work = "." + word.lowercaseString + "."
            points = [String](count: work.characters.count + 1, repeatedValue: "0")
            
            for i in 0...work.characters.count {
                var t = self.tree
                
                var str = work as NSString
                
                var str_substring = str.substringWithRange(NSRange(location: i, length: work.characters.count-i))
                
                for c in str_substring.characters {
                    if t.hash.keys.contains(c) {
                        t = t.hash[c]!
                        if t.None != nil {
                            var p = t.None
                            for j in 0..<p.count {
                                points[i+j] = max(points[i+j], p[j]!)
                            }
                        }
                    }
                    else {
                        break
                    }
                }
            }
            
            //No hyphens in the first two chars or the last two.
            points[1] = "0"
            points[2] = "0"
            points[points.count-2] = "0"
            points[points.count-3] = "0"
            
        }
        //Examine the points to build the pieces list.
        var pieces = [""]
        
        var new_points = (points[2..<points.count])
        
        for (c, p) in zip(word.characters, Array(new_points) ) {
            pieces[pieces.count-1] += String(c)
            
            if (Int(p)!) % 2 == 1{
                pieces.append("")
            }
        }
        return pieces
    
    }
}






