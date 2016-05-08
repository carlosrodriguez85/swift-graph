//
//  Edge.swift
//  Graph
//
//  Created by Carlos Rodríguez Domínguez on 8/5/16.
//  Copyright © 2016 Everyware Technologies. All rights reserved.
//

import Foundation

class Edge<T:Comparable,U:Comparable> : NSCopying {
    private(set) var node:Node<T, U>
    private(set) var weight:U?
    
    init(node:Node<T,U>, weight:U? = nil){
        self.node = node
        self.weight = weight
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let edge = Edge(node: node.copyWithZone(zone) as! Node<T, U>, weight: weight)
        return edge
    }
}

extension Edge : CustomStringConvertible, Comparable {
    var description:String{
        if let weight = weight {
            return "-[\(weight)]->\(node)"
        }
        else{
            return "-->\(node)"
        }
    }
}

func == <T:Comparable, U:Comparable>(a:Edge<T,U>, b:Edge<T,U>) -> Bool{
    let firstNode = a.node
    let secondNode = b.node
    
    return firstNode == secondNode && a.weight == b.weight
}

func < <T:Comparable, U:Comparable>(a:Edge<T,U>, b:Edge<T,U>) -> Bool{
    return a.weight < b.weight
}
