//
//  Logger.swift
//  AlexChatAppFirebase
//
//  Created by Alex Lee on 31/05/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import Foundation

func alexPrint(
    _ contents: Any...,             //... 이게뭐라고??? 몇개가 들어올지 모를때???
    header: String = "",            // 위에있는 Any...이 몇개의 값을 받아올지모르기때문에 그 다음에 받아와주는 매개변수는 매개변수명이 존재해야함
    _ file: String = #file,
    _ fuction: String = #function,
    _ line: Int = #line
    ) {
    let fileUrl = URL(fileURLWithPath: file)
    let fileName = fileUrl.deletingPathExtension().lastPathComponent
    // deletingPathExtension => .swift같은 확장자명을 지워줌
    // lastPathComponent => 마지막 경로만을 추출
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    let timeStamp = dateFormatter.string(from: Date())
    
    let header = header.isEmpty ? "" : "\(header)"        // header를 매개변수로 넣어줬을때, 아닐때 구분해주기위해
    
    let content = contents.reduce(""){ $0 + " " + String(describing: $1) }      // (contents변수) Any에 들어가는 여러값들을 배열 기호와 ""를 제거해줘서 넣어주기위함
    
    print("⭐️ [\(timeStamp)_\(fileName)_\(fuction)_\(line)_\(header)]: \(content)")
}
