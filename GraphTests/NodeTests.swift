//
//  NodeTests.swift
//  Graph
//
//  Created by Carlos Rodríguez Domínguez on 10/5/16.
//  Copyright © 2016 Everyware Technologies. All rights reserved.
//

import XCTest
import Graph

class NodeTests: XCTestCase {
    func testNodesAreEqualIfTheirValueIsEqualAndTheyHaveTheSameEdgesWithTheSameWeights() {
        let node1 = Node(value: 6, edges: [
            Edge(to: Node(value: 6), weight: 30)
            ])
        
        let node2 = Node(value: 6, edges: [
            Edge(to: Node(value: 32), weight: 58)
            ])
        
        let node3 = Node(value: 6, edges: [
            Edge(to: Node(value: 6), weight: 60)
            ])
        
        let node4 = Node(value: 6, edges: [
            Edge(to: Node(value: 6), weight: 60),
            Edge(to: Node(value: 9), weight: 10)
            ])
        
        let node5 = Node(value: 6, edges: [
            Edge(to: Node(value: 6), weight: 60),
            Edge(to: Node(value: 9, edges: [
                Edge(to: Node(value:6), weight: nil)
                ]), weight: 10)
            ])
        
        let node6 = Node(value: 6, edges: [
            Edge(to: Node(value: 6), weight: 60),
            Edge(to: Node(value: 9, edges: [
                Edge(to: Node(value:6), weight: nil)
                ]), weight: 10)
            ])
        
        let node7 = Node(value: 6, edges: [
            Edge(to: Node(value: 6), weight: 60),
            Edge(to: Node(value: 9, edges: [
                Edge(to: Node(value:6), weight: 1)
                ]), weight: 10)
            ])
        
        XCTAssertFalse(node1 == node2)
        XCTAssertFalse(node1 == node3)
        XCTAssertFalse(node2 == node3)
        XCTAssertFalse(node3 == node4)
        XCTAssertTrue(node5 == node6)
        XCTAssertFalse(node6 == node7)
    }
}