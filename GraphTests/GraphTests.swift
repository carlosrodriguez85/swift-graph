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
    
    func testConnectingNodesWithAnEdgeMakesThemAdjactent(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value : 5), Node(value : 6) ])
        XCTAssertFalse(graph.isAdjacent(node: Node(value : 6), ancestor: Node(value : 5)))
        graph.connect(edgeFrom: Node(value : 5), to: Node(value : 6), weight: nil)
        XCTAssertTrue(graph.isAdjacent(node: Node(value : 6), ancestor: Node(value : 5)))
    }
    
    func testDisconnectingNodesMakesThemNotToBeAdjacent(){
        let graph : Graph<Int, Int> = Graph(nodes : [ Node(value: 5, edges: [Edge(to: Node(value : 6))])])
        XCTAssertTrue(graph.isAdjacent(node: Node(value : 6), ancestor: Node(value: 5)))
        graph.disconnect(edgeFrom: Node(value : 5), to: Node(value: 6))
        XCTAssertFalse(graph.isAdjacent(node: Node(value : 6), ancestor: Node(value: 5)))
    }
    
}
