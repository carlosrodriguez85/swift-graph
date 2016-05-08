//
//  Node.swift
//  Graph
//
//  Created by Carlos Rodríguez Domínguez on 8/5/16.
//  Copyright © 2016 Everyware Technologies. All rights reserved.
//

import Foundation

class Node<T:Comparable, U:Comparable> : NSCopying {
    private(set) var value:T
    private(set) var edges:[Edge<T,U>]
    
    init(value:T, edges:[Edge<T,U>] = []){
        self.value = value
        self.edges = edges
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        return Node(value: value, edges: edges)
    }
    
    func filterEdges(predicate predicate:(Edge<T,U>)->Bool) {
        self.edges = self.edges.filter{predicate($0)}
    }
}

extension Node : CustomStringConvertible, Comparable {
    var description:String{
        if edges.isEmpty {
            return "(\(value))"
        }
        else if edges.count == 1 {
            return "(\(value))->\(edges.first!)"
        }
        else{
            var result = "(\(value))->{"
            for (idx, edge) in edges.enumerate() {
                if idx+1 == edges.endIndex {
                    result += "\(edge)}"
                }
                else{
                    result += "\(edge),"
                }
            }
            
            return result
        }
    }
    
    func connect(to node:Node<T,U>, weight:U?){
        if !self.edges.contains({ $0.node == node }) {
            let newEdge = Edge(to: node, weight: weight)
            edges.append(newEdge)
        }
    }
    
    func disconnect(edge edge:Edge<T,U>) {
        if let idx = edges.indexOf(edge) {
            edges.removeAtIndex(idx)
        }
    }
}

func == <T:Comparable, U:Comparable>(a:Node<T,U>, b:Node<T,U>) -> Bool{
    return a.value == b.value && a.edges == b.edges
}

func < <T:Comparable, U:Comparable>(a:Node<T,U>, b:Node<T,U>) -> Bool{
    return a.value < b.value
}
