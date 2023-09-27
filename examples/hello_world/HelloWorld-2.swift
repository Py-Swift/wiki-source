//HelloWorld.swift
import Foundation

class HelloWorld {
    
    init() {

    }
}

extension HelloWorld: HelloWorld_Delegate {

    func send_string(string: String) {
        print(string)
    }

}
