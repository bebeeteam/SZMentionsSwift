//
//  SZMention.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

open class SZMention: NSObject {
    /**
     @brief The location of the mention within the attributed string of the UITextView
     */
    open var mentionRange: NSRange {
        get{
            return NSMakeRange(self.location, self.mentionData.szMentionName.utf16.count)
        }
    }
    
    open var location: Int

    /**
     @brief Contains a reference to the object sent to the addMention: method
     */
    open fileprivate(set) var mentionData: SZCreateMentionProtocol

    /**
     @brief initializer for creating a mention object
     @param mentionRange: the range of the mention
     @param mentionData: the object of your mention (assuming you get extra data you need to store and retrieve later)
     */
    public init(location: Int, mentionData: SZCreateMentionProtocol) {
        self.location = location
        self.mentionData = mentionData;
    }
}
