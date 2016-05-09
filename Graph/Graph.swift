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
    
    func ancestors(node node:Node<NodeType,WeightType>) -> [Node<NodeType,WeightType>]?
    func neighbours(node:Node<NodeType,WeightType>) -> [Node<NodeType,WeightType>]?
    func isAdjacent(node node:Node<NodeType,WeightType>, ancestor:Node<NodeType,WeightType>) -> Bool
    func add(node:Node<NodeType,WeightType>)
    func add(nodeValue nodeValue:NodeType)
    func adding(node:Node<NodeType,WeightType>) -> Graph<NodeType,WeightType>
    func adding(nodeValue nodeValue:NodeType) -> Graph<NodeType,WeightType>
    func connect(edgeFrom edgeFrom:Node<NodeType,WeightType>, to:Node<NodeType,WeightType>, weight:WeightType?)
    func disconnect(edgeFrom edgeFrom:Node<NodeType,WeightType>, to:Node<NodeType,WeightType>)
    func weight(from nodeFrom:Node<NodeType,WeightType>, to:Node<NodeType,WeightType>) -> WeightType?
    func remove(node:Node<NodeType,WeightType>)
    func removing(node:Node<NodeType,WeightType>) -> Graph<NodeType,WeightType>
    func find(nodeValue nodeValue:NodeType) -> Node<NodeType,WeightType>?
    subscript(nodeValue:NodeType) -> Node<NodeType, WeightType>? { get }
}

class Graph<T:Comparable, U:Comparable> : GraphProtocol {
    private var nodes:[Node<T,U>] = []
    
    init(nodes:[Node<T,U>]){
        self.nodes = nodes
    }
    
    init(graph:Graph<T,U>){
        self.nodes = deepCopyNodes(graph.allNodes)
    }
    
    private func deepCopyNodes(nodes:[Node<T,U>]) -> [Node<T,U>]{
        var map:[(original:Node<T,U>, copy:Node<T,U>)] = []
        let result = nodes.map({(node:Node<T,U>) -> Node<T,U> in
            let copy = Node<T,U>(node:node)
            map.append((original: node, copy: copy))
            return copy
        })
        
        //make the edges to point to the nodes in the "self" graph
        for node in result{
            for edge in node.edges {
                //lookup for edge.node in the map
                if let newNode = map.filter({$0.original == edge.node}).first?.copy {
                    node.disconnect(edge: edge)
                    node.connect(to: newNode, weight: edge.weight)
                }
            }
        }
        return result
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
        
        while let n = nextNode(visitedNodes: &visitedNodes, lastVisitedNode: &lastVisitedNode){
            print(n)
        }
        
        return visitedNodes
    }
    
    func ancestors(node node:Node<T,U>) -> [Node<T,U>]? {
        if self.allNodes.contains(node){
            var result = [Node<T,U>]()
            for otherNode in self.allNodes {
                if isAdjacent(node: node, ancestor: otherNode) {
                    result.append(otherNode)
                }
            }
            return result
        }
        else{
            return nil
        }
    }
    
    func neighbours(node:Node<T,U>) -> [Node<T,U>]? {
        if self.allNodes.contains(node){
            return node.edges.map{$0.node}
        }
        else{
            return nil
        }
    }
    
    private func nextNode(inout visitedNodes visitedNodes:[Node<T,U>], inout lastVisitedNode:Node<T,U>?) -> Node<T,U>? {
        if self.nodes.isEmpty {
            return nil
        }
        else if let node = self.nodes.first where self.nodes.count == 1{
            defer{
                if !visitedNodes.contains(node){
                    visitedNodes.append(node)
                }
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
    
    func weight(from nodeFrom:Node<T,U>, to nodeTo:Node<T,U>) -> U? {
        return nodeFrom.connection(to: nodeTo)?.weight
    }
    
    func isAdjacent(node node:Node<T,U>, ancestor ancestorNode:Node<T,U>) -> Bool {
        return ancestorNode.edges.map{$0.node}.contains(node)
    }
    
    func add(nodeValue nodeValue: T) {
        let node = Node<T,U>(value: nodeValue)
        self.add(node)
    }
    
    func add(node: Node<T, U>) {
        if !self.allNodes.contains(node) {
            self.nodes.append(node)
        }
    }
    
    func adding(node:Node<T,U>) -> Graph<T,U> {
        let newGraph = Graph<T,U>(graph: self)
        newGraph.add(node)
        return newGraph
    }
    
    func adding(nodeValue nodeValue:T) -> Graph<T,U> {
        let node = Node<T,U>(value: nodeValue)
        return adding(node)
    }
    
    func connect(edgeFrom edgeFrom: Node<T, U>, to edgeTo: Node<T, U>, weight: U?) {
        for node in self {
            if node == edgeFrom {
                node.connect(to: edgeTo, weight: weight)
                break
            }
        }
    }
    
    func disconnect(edgeFrom edgeFrom:Node<T,U>, to edgeTo:Node<T,U>) {
        edgeFrom.filterEdges(predicate: {$0.node != edgeTo})
        for node in self.allNodes {
            if node == edgeFrom {
                node.filterEdges(predicate: {$0.node != edgeTo})
                break
            }
        }
    }
    
    func find(nodeValue nodeValue:T) -> Node<T,U>? {
        for node in self.allNodes {
            if node.value == nodeValue{
                return node
            }
        }
        
        return nil
    }
    
    func remove(node: Node<T, U>) {
        self.nodes = self.nodes.filter{$0 != node}.map{Node<T,U>(node:$0)}
        if let ancestors = self.ancestors(node: node) {
            for ancestor in ancestors {
                ancestor.filterEdges(predicate: {$0.node != node})
            }
        }
    }
    
    func removing(node: Node<T, U>) -> Graph<T,U> {
        let newNodes = deepCopyNodes(self.nodes.filter{$0 != node}.map{Node<T,U>(node:$0)})
        let newGraph = Graph(nodes: newNodes)
        newGraph.remove(node)
        
        return newGraph
    }
}

extension Graph : CustomStringConvertible {
    var description: String{
        if self.nodes.isEmpty {
            return "()"
        }
        else {
            return allNodes.reduce("", combine: {$0+"\($1)\n"})
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

