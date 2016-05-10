//
//  GraphTests.swift
//  GraphTests
//
//  Created by Carlos Rodríguez Domínguez on 7/5/16.
//  Copyright © 2016 Everyware Technologies. All rights reserved.
//

import XCTest
import Graph

class GraphTests: XCTestCase {
    private var testGraph:Graph<Int,Int>! = nil
    
    override func setUp() {
        super.setUp()

        let sharedFinalNode:Node<Int,Int> = Node(value:3)
        let sharedNode:Node<Int,Int> = Node(value:11, edges:[Edge(to: sharedFinalNode)])
        
        // 7 --> 8
        // |
        //  ---> (11<->11) <--> 3
        //       ^
        //       |
        // 5-----
        testGraph = Graph(nodes:[
            Node(value:7, edges:[
                Edge(to: Node(value:8), weight: 66),
                Edge(to: sharedNode),
                ]),
            Node(value:5, edges:[
                Edge(to: sharedNode)
                ])
        ])
        
        testGraph.connect(edgeFrom: sharedNode, to: sharedNode, weight: nil)
        testGraph.connect(edgeFrom: sharedFinalNode, to: sharedNode, weight: 98)
    }
    
    func testNewGraphShouldHaveAsManyNodesAsItemsInList(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        XCTAssert(graph.allNodes.count == 2)
    }
    
    func testCopiedGraphShouldHaveAsManyNodesAsOriginalGraph(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        let copy = Graph(graph: graph)
        XCTAssert(graph.allNodes.count == copy.allNodes.count)
    }
    
    func testCopiedGraphShouldNotHaveReferencesToOriginalGraph(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        let copy = Graph(graph: graph)
        
        graph.add(nodeValue: 9)
        XCTAssert(copy.allNodes.count == 2)
    }
    
    func testAddingANodeIncrementsNodeCount(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        graph.add(nodeValue: 10)
        XCTAssert(graph.allNodes.count == 3)
    }
    
    func testAddingAnExistingNodeDoesNothing(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        graph.add(nodeValue: 5)
        XCTAssert(graph.allNodes.count == 2)
    }
    
    func testAddingANodeReturnsACopyOfGraphWithTheNewNode(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        let extendedGraph = graph.adding(nodeValue: 10)
        XCTAssert(graph.allNodes.count == 2)
        XCTAssert(extendedGraph.allNodes.count == 3)
    }
    
    func testRemovingANodeDecrementsNodeCount(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        graph.remove(Node(value: 5))
        XCTAssert(graph.allNodes.count == 1)
    }
    
    func testRemovingANonExistingNodeDoesNothing(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        graph.remove(Node(value: 10))
        XCTAssert(graph.allNodes.count == 2)
    }
    
    func testRemovingANodeReturnsACopyOfTheGraphWithoutTheNode(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        let smallerGraph = graph.removing(Node(value: 5))
        XCTAssert(graph.allNodes.count == 2)
        XCTAssert(smallerGraph.allNodes.count == 1)
    }
    
    func testAnEmptyGraphDescriptionShouldBeEmptyParenthesis(){
        let graph : Graph<Int, Int> = Graph(nodes: [])
        let description = graph.description
        XCTAssert(description == "()")
    }
    
    func testANonEmptyGraphDescriptionShouldListOneNodeWithEdgesWithWeighsPerLine() {
        let description = testGraph.description
        let testDescription = "(7)->{[66](8),(11)}\n(5)->(11)\n(8)\n(11)->{(3),(11)}\n(3)->[98](11)\n"
        XCTAssert(description == testDescription)
    }
    
    func testGraphShouldFindNodeIfItIsIncluded(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        XCTAssertNotNil(graph.find(nodeValue: 5))
        XCTAssertNotNil(graph[5])
    }
    
    func testGraphShouldNotFindNodeIfItIsNotIncluded(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        XCTAssertNil(graph.find(nodeValue: 10))
        XCTAssertNil(graph[10])
    }
    
    func testANodeIsAdjacentToAnotherIfThereIsAnEdgeBetweenThem(){
        XCTAssertTrue(testGraph.isAdjacent(node: Node(value : 11), ancestor: Node(value : 7)))
    }
    
    func testANodeIsNotAdjacentToAnotherIfThereIsNotAnEdgeBetweenThem(){
        XCTAssertFalse(testGraph.isAdjacent(node: Node(value : 7), ancestor: Node(value : 11)))
    }
    
    func testANodeWithoutEdgesHasNoNeighbours(){
        let neighbours = testGraph.neighbours(Node(value: 8))
        XCTAssert(neighbours?.count == 0)
    }
    
    func testANodeHasAsManyNeighboursAsOutgoingEdges(){
        let neighbours = testGraph.neighbours(Node(value: 7))
        XCTAssert(neighbours?.count == 2)
    }
    
    func testAddingNode() {
        let newGraph = testGraph.adding(nodeValue:18)
        newGraph[18]!.connect(to: newGraph[7]!, weight: 32)
        
        XCTAssertTrue(testGraph.allNodes.count == 5)
        XCTAssertTrue(newGraph.allNodes.count == 6)
        
        XCTAssertTrue(newGraph.isAdjacent(node: newGraph[7]!, ancestor: newGraph[18]!))
        XCTAssertFalse(newGraph.isAdjacent(node: newGraph[18]!, ancestor: newGraph[7]!))
        
        XCTAssertFalse(testGraph.ancestors(node: testGraph[7]!)!.contains(newGraph[18]!))
        
        testGraph.add(nodeValue: 98)
        XCTAssertTrue(testGraph.allNodes.count == 6)
        XCTAssertNotNil(testGraph[98])
        
        XCTAssertNil(newGraph[98])
        XCTAssertTrue(newGraph.allNodes.count == 6)
    }
    
    func testEdgeManagement() {
        XCTAssertTrue(testGraph.isAdjacent(node: testGraph[11]!, ancestor: testGraph[3]!))
        XCTAssertTrue(testGraph.isAdjacent(node: testGraph[3]!, ancestor: testGraph[11]!))
        
        testGraph.connect(edgeFrom: testGraph[11]!, to: testGraph[8]!, weight: 48)
        XCTAssertFalse(testGraph.isAdjacent(node: testGraph[11]!, ancestor: testGraph[8]!))
        XCTAssertTrue(testGraph.isAdjacent(node: testGraph[8]!, ancestor: testGraph[11]!))
        XCTAssertTrue(testGraph.weight(from: testGraph[11]!, to: testGraph[8]!) == 48)
        XCTAssertNil(testGraph.weight(from: testGraph[8]!, to: testGraph[11]!))
        XCTAssertTrue(testGraph.allNodes.count == 5)
        
        testGraph.disconnect(edgeFrom: testGraph[3]!, to: testGraph[11]!)
        XCTAssertTrue(testGraph.isAdjacent(node: testGraph[3]!, ancestor: testGraph[11]!))
        XCTAssertFalse(testGraph.isAdjacent(node: testGraph[11]!, ancestor: testGraph[3]!))
    }
    
    func testIteration() {
        var count = 0
        var countReverse = 0
        
        var allNodes:[Node<Int,Int>] = []
        var reverseAllNodes:[Node<Int,Int>] = []
        
        var nodeString:String = ""
        for node in testGraph {
            count += 1
            nodeString += "\(node.value)"
            allNodes.append(node)
        }
        
        var reverseNodeString:String = ""
        for node in testGraph.reverse() {
            countReverse += 1
            reverseNodeString += "\(node.value)"
            reverseAllNodes.append(node)
        }
        
        XCTAssertTrue(count == testGraph.allNodes.count)
        XCTAssertTrue(countReverse == testGraph.allNodes.count)
        XCTAssertTrue(count == 5)
        XCTAssertTrue(countReverse == 5)
        XCTAssertTrue(nodeString == "758113")
        XCTAssertTrue(reverseNodeString == "311857")
        XCTAssertTrue(allNodes == testGraph.allNodes)
        XCTAssertTrue(reverseAllNodes == testGraph.allNodes.reverse())
    }
    
    func testRemoving() {
        let newGraph = testGraph.removing(testGraph[11]!)
        
        XCTAssertTrue(newGraph.allNodes.count == 3)
        XCTAssertTrue(testGraph.allNodes.count == 5)
        
        XCTAssertNil(newGraph[11])
        XCTAssertNotNil(testGraph[11])
        
        testGraph.remove(testGraph[11]!)
        XCTAssertNil(testGraph[11])
        XCTAssertNil(testGraph[3])
    }
}
