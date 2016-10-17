//
//  SZExampleMention.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

class SZExampleMention: SZCreateMentionProtocol {
    @objc var szMentionName: String = ""
    @objc var szMentionRange: NSRange = NSMakeRange(0, 0)
    var szMentionId: Int = 0
    
    /**
     @brief A mention string that can be shared
     */
    public func toString() -> String {
        return "@[\(szMentionName)][\(szMentionId)]"
    }
}
