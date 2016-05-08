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
            return "(\(value))\(edges.first!)\n"
        }
        else{
            return edges.reduce("(\(value))\n", combine: { $0 + "\t\($1)\n" })
        }
    }
    
    var neighbours:[Node]{
        return edges.map{$0.node}
    }
    
    func connect(to node:Node<T,U>, weight:U?){
        let newEdge = Edge(node: node, weight: weight)
        edges.append(newEdge)
    }
    
    func isConnected(to node:Node<T,U>) -> Bool {
        return neighbours.contains(node)
    }
    
    func remove(edge edge:Edge<T,U>) {
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
