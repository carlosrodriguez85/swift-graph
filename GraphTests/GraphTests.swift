//
//  GraphTests.swift
//  GraphTests
//
//  Created by Carlos Rodríguez Domínguez on 7/5/16.
//  Copyright © 2016 Everyware Technologies. All rights reserved.
//

import XCTest
@testable import Graph

class GraphTests: XCTestCase {
    private var testGraph:Graph<Int,Int>! = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let sharedNode:Node<Int,Int> = Node(value:11, edges:[Edge(node: Node(value:3))])
        
        // 7 --> 8
        // |
        //  ---> 11--> 3
        //       ^
        //       |
        // 5-----
        testGraph = Graph(nodes:[
            Node(value:7, edges:[
                Edge(node: Node(value:8), weight: 66),
                Edge(node: sharedNode),
                ]),
            Node(value:5, edges:[
                Edge(node: sharedNode)
                ])
        ])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAllNodes() {
        XCTAssertTrue(testGraph.allNodes.count == 5)
    }
    
    func testFind(){
        XCTAssertNotNil(testGraph.find(nodeValue: 11))
        XCTAssertNil(testGraph.find(nodeValue: 35))
        
        XCTAssertNotNil(testGraph[11])
        XCTAssertNil(testGraph[35])
    }
    
    func testAdjacent() {
        XCTAssertTrue(testGraph.isAdjacent(node: testGraph[11]!, ancestor: testGraph[7]!))
        
        XCTAssertFalse(testGraph.isAdjacent(node: testGraph[7]!, ancestor: testGraph[11]!))
        
        XCTAssertFalse(testGraph.isAdjacent(node: testGraph[7]!, ancestor: testGraph[5]!))
    }
    
    func testNeighbours() {
        //TODO
    }
    
    func testAddingNode() {
        //TODO
    }
    
    func testAddingEdge() {
        //TODO
    }
    
    func testDescription() {
        let description = testGraph.description
        let testDescription = "(7)\n\t-[66]->(8)\n\t-->(11)-->(3)\n\n(5)-->(11)-->(3)\n\n"
        
        XCTAssertTrue(description == testDescription)
    }
    
    func testIteration() {
        var count = 0
        var allNodes:[Node<Int,Int>] = []
        for node in testGraph {
            count += 1
            allNodes.append(node)
        }
        
        XCTAssertTrue(count == testGraph.allNodes.count)
        XCTAssertTrue(allNodes == testGraph.allNodes)
    }
    
    func testRemoving() {
        let newGraph = testGraph.removing(node: testGraph[11]!)
        
        XCTAssertTrue(newGraph.allNodes.count == 3)
        XCTAssertTrue(testGraph.allNodes.count == 5)
        
        XCTAssertNil(newGraph[11])
        XCTAssertNotNil(testGraph[11])
    }
}
