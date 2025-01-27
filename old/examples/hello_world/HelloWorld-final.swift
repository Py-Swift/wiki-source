//HelloWorld.swift
import Foundation

class HelloWorld {
    
    init() {
        InitHelloWorld_Delegate(delegate: self)
    }
}

extension HelloWorld: HelloWorld_Delegate {

    func send_string(string: String) {
        print(string)
    }

}
