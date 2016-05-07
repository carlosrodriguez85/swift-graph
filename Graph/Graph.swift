//: Playground - noun: a place where people can play

import UIKit

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

class Node<T:Comparable, U:Comparable> : NSCopying {
    private(set) var value:T
    private(set) var edges:[Edge<T,U>]
    
    init(value:T, edges:[Edge<T,U>] = []){
        self.value = value
        self.edges = edges
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        var newEdges = [Edge<T,U>]()
        for edge in edges{
            let newEdge = edge.copyWithZone(zone) as! Edge<T,U>
            newEdges.append(newEdge)
        }
        
        return Node(value: value, edges: newEdges)
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

struct Graph<T:Comparable, U:Comparable> {
    private var nodes:[Node<T,U>]
    
    init(nodes:[Node<T,U>]){
        self.nodes = nodes
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
    
    func nextNode(inout visitedNodes visitedNodes:[Node<T,U>], inout lastVisitedNode:Node<T,U>?) -> Node<T,U>? {
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
}

protocol GraphProtocol {
    associatedtype NodeType : Comparable
    associatedtype WeightType : Comparable
    
    func adjacent(firstNode firstNode:Node<NodeType,WeightType>, secondNode:Node<NodeType,WeightType>) -> Bool
    func adding(node node:Node<NodeType,WeightType>) -> Graph<NodeType,WeightType>
    func removing(node node:Node<NodeType,WeightType>) -> Graph<NodeType,WeightType>
    func find(nodeValue nodeValue:NodeType) -> Node<NodeType,WeightType>?
}

extension Graph : CustomStringConvertible, GraphProtocol {
    func adjacent(firstNode firstNode:Node<T,U>, secondNode:Node<T,U>) -> Bool {
        for edge in firstNode.edges{
            if edge.node == secondNode{
                return true
            }
        }
        
        return false
    }
    
    func adding(node node:Node<T,U>) -> Graph<T,U> {
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
            ancestor.edges = ancestor.edges.filter{$0.node != node}.map{$0.copyWithZone(nil) as! Edge<T,U>}
        }
        
        return newGraph
    }
    
    var description: String{
        if self.nodes.isEmpty {
            return "()"
        }
        else {
            return nodes.reduce("", combine: {$0+"\($1)"})
        }
    }
}

// 7 --> 8
// |
//  ---> 11--> 3
//       ^
//       |
// 5-----

let sharedEdge:Edge<Int,Int> = Edge(node: Node(value:3))
var sharedNode:Node<Int,Int> = Node(value:11, edges:[sharedEdge])

var graph:Graph = Graph(nodes:[
    Node(value:7, edges:[
        Edge(node: Node(value:8), weight: 66),
        Edge(node: sharedNode),
    ]),
    Node(value:5, edges:[
        Edge(node: sharedNode)
    ])
])

print(graph)
print(graph.allNodes.map{$0.value})

let node = graph.find(nodeValue: 5)

sharedNode.remove(edge: sharedEdge)
print(graph)

sharedNode.edges.append(sharedEdge)
print(graph)
print(graph.removing(node: graph.find(nodeValue: 11)!))
print(graph.find(nodeValue: 7)!.neighbours)
print(graph.ancestors(node: sharedNode))

