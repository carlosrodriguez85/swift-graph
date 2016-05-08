//
//  Edge.swift
//  Graph
//
//  Created by Carlos Rodríguez Domínguez on 8/5/16.
//  Copyright © 2016 Everyware Technologies. All rights reserved.
//

import Foundation

protocol GraphProtocol {
    associatedtype NodeType : Comparable
    associatedtype WeightType : Comparable
    
    func isAdjacent(node node:Node<NodeType,WeightType>, ancestor ancestorNode:Node<NodeType,WeightType>) -> Bool
    func adding(node node:Node<NodeType,WeightType>) -> Graph<NodeType,WeightType>
    func adding(nodeValue nodeValue:NodeType) -> Graph<NodeType,WeightType>
    func removing(node node:Node<NodeType,WeightType>) -> Graph<NodeType,WeightType>
    func find(nodeValue nodeValue:NodeType) -> Node<NodeType,WeightType>?
    subscript(nodeValue:NodeType) -> Node<NodeType, WeightType>? { get }
}

struct Graph<T:Comparable, U:Comparable> : GraphProtocol {
    private var nodes:[Node<T,U>]
    
    init(nodes:[Node<T,U>]){
        self.nodes = nodes
    }
    
    subscript(nodeValue:T) -> Node<T,U>? {
        return find(nodeValue: nodeValue)
    }
    
    private func isVisited(node:Node<T,U>, visitedNodes:[Node<T,U>]) -> Bool {
        return visitedNodes.contains{(n:Node<T,U>)->Bool in n == node}
    }
    
    var allNodes:[Node<T,U>]{
        var visitedNodes:[Node<T,U>] = []
        var lastVisitedNode:Node<T,U>? = nil
        
        while let _ = nextNode(visitedNodes: &visitedNodes, lastVisitedNode: &lastVisitedNode){ }
        
        return visitedNodes
    }
    
    func ancestors(node node:Node<T,U>) -> [Node<T,U>] {
        var result = [Node<T,U>]()
        for otherNode in self.allNodes {
            if otherNode.isConnected(to: node) {
                result.append(otherNode)
            }
        }
        return result
    }
    
    private func nextNode(inout visitedNodes visitedNodes:[Node<T,U>], inout lastVisitedNode:Node<T,U>?) -> Node<T,U>? {
        if self.nodes.isEmpty {
            return nil
        }
        else if let node = self.nodes.first where self.nodes.count == 1{
            defer{
                visitedNodes.append(node)
            }
            return isVisited(node, visitedNodes: visitedNodes) ? nil : node
        }
        else{
            for node in nodes{
                if !isVisited(node, visitedNodes: visitedNodes) {
                    visitedNodes.append(node)
                    lastVisitedNode = node
                    return node
                }
            }
            
            //if we didn't return, take next level
            for node in nodes{
                for edge in node.edges{
                    if !isVisited(edge.node, visitedNodes: visitedNodes){
                        visitedNodes.append(edge.node)
                        lastVisitedNode = edge.node
                        return edge.node
                    }
                }
            }
            
            //if we didn't return, try with the lastVisitedNode
            if let edges = lastVisitedNode?.edges {
                for edge in edges {
                    if !isVisited(edge.node, visitedNodes: visitedNodes){
                        visitedNodes.append(edge.node)
                        lastVisitedNode = edge.node
                        return edge.node
                    }
                }
            }
        }
        
        return nil
    }
    
    func isAdjacent(node node:Node<T,U>, ancestor ancestorNode:Node<T,U>) -> Bool {
        for edge in ancestorNode.edges{
            if edge.node == node{
                return true
            }
        }
        
        return false
    }
    
    func adding(node node:Node<T,U>) -> Graph<T,U> {
        return Graph<T,U>(nodes: self.nodes + [node])
    }
    
    func adding(nodeValue nodeValue:T) -> Graph<T,U> {
        let node = Node<T,U>(value: nodeValue)
        return Graph<T,U>(nodes: self.nodes + [node])
    }
    
    func find(nodeValue nodeValue:T) -> Node<T,U>? {
        for node in self.allNodes{
            if node.value == nodeValue{
                return node
            }
        }
        
        return nil
    }
    
    func removing(node node: Node<T, U>) -> Graph<T,U> {
        let newNodes = self.nodes.filter{$0 != node}.map{$0.copyWithZone(nil) as! Node<T,U>}
        let newGraph = Graph(nodes: newNodes)
        let ancestors = newGraph.ancestors(node: node)
        for ancestor in ancestors {
            ancestor.filterEdges(predicate: {$0.node != node})
        }
        
        return newGraph
    }
}

extension Graph : CustomStringConvertible {
    var description: String{
        if self.nodes.isEmpty {
            return "()"
        }
        else {
            return nodes.reduce("", combine: {$0+"\($1)"})
        }
    }
}

struct GraphGenerator<T:Comparable,U:Comparable> : GeneratorType {
    private var generatorVisitedNodes:[Node<T,U>] = []
    private var generatorLastVisitedNode:Node<T,U>? = nil
    private var graph:Graph<T,U>
    
    init(graph:Graph<T,U>){
        self.graph = graph
    }
    
    mutating func next() -> Node<T,U>? {
        let result = graph.nextNode(visitedNodes: &generatorVisitedNodes, lastVisitedNode: &generatorLastVisitedNode)
        if result == nil {
            generatorVisitedNodes = []
            generatorLastVisitedNode = nil
        }
        
        return result
    }
}

extension Graph : SequenceType {
    func generate() -> GraphGenerator<T,U> {
        return GraphGenerator(graph: self)
    }
    
    func underestimateCount() -> Int {
        return self.nodes.count
    }
}

