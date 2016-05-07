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
    }
    
    func testAdjacent() {
        //TODO
    }
    
    func testNeighbours() {
        //TODO
    }
    
    func testAdding() {
        //TODO
    }
    
    func testRemoving() {
        let newGraph = testGraph.removing(node: testGraph.find(nodeValue: 11)!)
        
        XCTAssertTrue(newGraph.allNodes.count == 3)
        XCTAssertTrue(testGraph.allNodes.count == 5)
        
        XCTAssertNil(newGraph.find(nodeValue: 11))
        XCTAssertNotNil(testGraph.find(nodeValue: 11))
    }
}
