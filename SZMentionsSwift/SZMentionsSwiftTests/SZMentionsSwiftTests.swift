//
//  SZMentionsSwiftTests.swift
//  SZMentionsSwiftTests
//
//  Created by Steven Zweier on 1/16/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import XCTest
import SZMentionsSwift

class SZExampleMention: SZCreateMentionProtocol {
    private(set) var szMentionName: String = ""
    var szMentionId: Int = 0
    
    /**
     @brief A mention string that can be shared
     */
    public func toString() -> String {
        return "@[\(szMentionName)][\(szMentionId)]"
    }
    
    public init(withName name: String){
        self.szMentionName = name
    }
}

class SZMentionsSwiftTests: XCTestCase, SZMentionsManagerProtocol, UITextViewDelegate {
    let textView = UITextView.init()
    var hidingMentionsList = true
    var mentionString = ""
    var mentionsListener: SZMentionsListener?

    override func setUp() {
        super.setUp()
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
        let attribute2 = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.black)

        mentionsListener = SZMentionsListener.init(mentionTextView: textView,
            mentionsManager: self,
            textViewDelegate: self,
            mentionTextAttributes: [attribute],
            defaultTextAttributes: [attribute2],
            spaceAfterMention: false,
            addMentionOnReturnKey: true)
    }

    func testThatAddingAttributesThatDoNotMatchThrowsAnError() {
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
        let attribute2 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)

        let defaultAttributes = [attribute]
        let mentionAttributes = [attribute, attribute2]

        XCTAssert(mentionsListener!.attributesSetCorrectly(mentionAttributes, defaultAttributes: defaultAttributes) == false)
    }

    func testThatAddingAttributesThatDoMatchDoesNotThrowAnError() {
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
        let attribute2 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)

        let defaultAttributes = [attribute, attribute2]
        let mentionAttributes = [attribute2, attribute]

        XCTAssert(mentionsListener!.attributesSetCorrectly(mentionAttributes, defaultAttributes: defaultAttributes) == true)
    }

    func testMentionListIsDisplayed() {
        textView.insertText("@t")
        XCTAssert(hidingMentionsList == false)
    }

    func testMentionListIsHidden() {
        textView.insertText("@t")
        XCTAssert(hidingMentionsList == false)
        textView.insertText(" ")
        XCTAssert(hidingMentionsList == true)
    }
  
    func testMentionsCanBePlacedInAdvance() {
        textView.text = "Testing Steven Zweier and Tiffany get mentioned correctly";

        let mentionData = SZExampleMention(withName: "Steve")
        let mention = SZMention.init(location:8, mentionData: mentionData)

        
        let mentionData2 = SZExampleMention(withName: "Tiff")
        let mention2 = SZMention.init(location:26, mentionData: mentionData2)
        

        let insertMentions : Array<SZMention> = [mention, mention2]

        mentionsListener!.insertExistingMentions(insertMentions)

        XCTAssert(mentionsListener!.mentions.count == 2)
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 9, effectiveRange: nil)! as AnyObject).isEqual( UIColor.red))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 21, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 27, effectiveRange: nil)! as AnyObject).isEqual( UIColor.red))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 33, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
    }

    func testMentionIsAdded() {
        textView.insertText("@t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.count == 1)
    }

    func testMentionPositionIsCorrectToStartText() {
        textView.insertText("@t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
    }

    func testMentionPositionIsCorrectInTheMidstOfText() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 8)
    }

    func testMentionLengthIsCorrect() {
        textView.insertText("@t")
        var mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.length == 6)

        textView.insertText("Testing @t")
        mention = SZExampleMention(withName: "Steven Zweier")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[1].mentionRange.length == 13)
    }

    func testMentionLocationIsAdjustedProperly() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 8)

        var beginning = textView.beginningOfDocument
        var start = textView.position(from: beginning, offset: 0)
        var end = textView.position(from: start!, offset: 3)

        var textRange = textView.textRange(from: start!, to: end!)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 3), replacementText: "") == true {
            textView.replace(textRange!, withText: "")
        }

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 5)

        beginning = textView.beginningOfDocument
        start = textView.position(from: beginning, offset: 0)
        end = textView.position(from: start!, offset: 5)

        textRange = textView.textRange(from: start!, to: end!)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 5), replacementText: "") == true {
            textView.replace(textRange!, withText: "")
        }

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
    }

    func testMentionLocationIsAdjustedProperlyWhenAMentionIsInsertsBehindAMentionSpaceAfterMentionIsFalse() {
        textView.insertText("@t")
        var mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.length == 6)

        textView.selectedRange = NSMakeRange(0, 0)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 0), replacementText: "@t") == true {
            textView.insertText("@t")
        }
        mention = SZExampleMention(withName: "Steven Zweier")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[1].mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions[1].mentionRange.length == 13)
        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 13)
    }

    func testMentionLocationIsAdjustedProperlyWhenAMentionIsInsertsBehindAMentionSpaceAfterMentionIsTrue() {
        mentionsListener?.setValue(true, forKey: "spaceAfterMention")
        textView.insertText("@t")
        var mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.length == 6)

        textView.selectedRange = NSMakeRange(0, 0)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 0), replacementText: "@t") == true {
            textView.insertText("@t")
        }
        mention = SZExampleMention(withName: "Steven Zweier")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[1].mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions[1].mentionRange.length == 13)
        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 14)
    }

    func testEditingTheMiddleOfTheMentionRemovesTheMention() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.count == 1)

        textView.selectedRange = NSMakeRange(11, 1)

        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") == true {
            textView.deleteBackward()
        }

        XCTAssert(mentionsListener?.mentions.count == 0)
    }

    func testEditingTheEndOfTheMentionRemovesTheMention() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.count == 1)

        textView.selectedRange = NSMakeRange(13, 1)

        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") == true {
            textView.deleteBackward()
        }

        XCTAssert(mentionsListener?.mentions.count == 0)
    }

    func testEditingAfterTheMentionDoesNotDeleteTheMention() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)

        textView.insertText(" ")

        XCTAssert(mentionsListener?.mentions.count == 1)

        textView.selectedRange = NSMakeRange(14, 1)

        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") == true {
            textView.deleteBackward()
        }

        XCTAssert(mentionsListener?.mentions.count == 1)
    }

    func testPastingTextBeforeLeadingMentionResetsAttributes() {
        textView.insertText("@s")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)
        textView.selectedRange = NSMakeRange(0, 0)
        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "test") == true {
            textView.insertText("test")
        }
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
    }

    func hideMentionsList() {
        hidingMentionsList = true
    }

    func showMentionsListWithString(_ mentionsString: String) {
        hidingMentionsList = false
        mentionString = mentionsString
    }

    func testMentionsLibraryReplacesCorrectMentionRangeIfMultipleExistAndThatSelectedRangeWillBeCorrect()
    {
        textView.insertText(" @st")
        textView.selectedRange = NSMakeRange(0, 0)
        textView.insertText("@st")

        let mention = SZExampleMention(withName: "Steven")

        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 0);
        XCTAssert(self.textView.selectedRange.location == 6);
    }

    func testMentionsLibraryReplacesCorrectMentionRangeIfMultipleExistAndThatSelectedRangeWillBeCorrectWithSpaceAfterMentionEnabled()
    {
        mentionsListener?.setValue(true, forKey: "spaceAfterMention")
        textView.insertText(" @st")
        textView.selectedRange = NSMakeRange(0, 0)
        textView.insertText("@st")

        let mention = SZExampleMention(withName: "Steven")

        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 0);
        XCTAssert(self.textView.selectedRange.location == 7);
    }

    func testAddingTestImmediatelyAfterMentionChangesToDefaultText()
    {
        textView.insertText("@s")
        let mention = SZExampleMention(withName: "Steven")
        self.mentionsListener?.addMention(mention)

        if mentionsListener?.textView(textView, shouldChangeTextIn: self.textView.selectedRange, replacementText: "test") == true {
            textView.insertText("test")
        }
        
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: textView.selectedRange.location - 1, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
    }
    
    func testMentionListOnNewlineIsDisplayed() {
        textView.insertText("\n@t")
        XCTAssert(hidingMentionsList == false)
    }
    
    func testMentionListOnNewLineIsHidden() {
        textView.insertText("\n@t")
        XCTAssert(hidingMentionsList == false)
        textView.insertText(" ")
        XCTAssert(hidingMentionsList == true)
    }
    
    func testMentionPositionIsCorrectToStartTextOnNewline() {
        textView.insertText("\n@t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)
        
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 1)
    }
    
    func testMentionPositionIsCorrectInTheMidstOfNewlineText() {
        textView.insertText("Testing \nnew line @t")
        let mention = SZExampleMention(withName: "Steven")
        mentionsListener?.addMention(mention)
        
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 18)
    }
  
    func testShouldAddMentionOnReturnKeyShouldCalledWhenHitReturnKey() {
      
      mentionsListener?.setValue(true, forKey: "addMentionAfterReturnKey")
      
      textView.insertText("@t")
      XCTAssert(hidingMentionsList == false)

      if mentionsListener?.textView(textView, shouldChangeTextIn: self.textView.selectedRange, replacementText: "\n") == true {
        textView.insertText("\n")
      }
      
      XCTAssertTrue(shouldAddMentionOnReturnKeyCalled)
      XCTAssert(hidingMentionsList == true)
    }
  
    var shouldAddMentionOnReturnKeyCalled = false

    func shouldAddMentionOnReturnKey() {
      shouldAddMentionOnReturnKeyCalled = true
    }
    
    func testThatMentionsListenerReturnsTextFormattedBasedOnSZMentionConcreteFormatter(){
        let mention = SZExampleMention(withName: "John Appleseed")
        mention.szMentionId = 1234
        
        let mention2 = SZExampleMention(withName: "Ada Augusta Byron")
        mention2.szMentionId = 1235
        
        textView.insertText("Hi @J")
        mentionsListener?.addMention(mention)
        
        textView.insertText(". Do you know @A")
        mentionsListener?.addMention(mention2)
        
        textView.insertText("?.")
        
        
        XCTAssertEqual(mentionsListener?.textForSharing(),"Hi @[John Appleseed][1234]. Do you know @[Ada Augusta Byron][1235]?.","Messaged returned by listener should be @[John Appleseed][1234]")
    }
    
    func testShouldShowMentionsListWhenTextInsertedIsEqualToMinimumCharactersToTrigger(){
        mentionsListener = SZMentionsListener.init(mentionTextView: textView, mentionsManager: self, textViewDelegate: self, mentionTextAttributes: nil, defaultTextAttributes: nil, spaceAfterMention: true, addMentionOnReturnKey: true, trigger: "@", cooldownInterval: 0.5, minimumCharactersForTrigger: 2)
        
        textView.insertText("@j")
        
        XCTAssert(hidingMentionsList == true,"ShowMentionsList shouldn't be displayed until we type at least 2 characters after the trigger.")
        
        textView.insertText("o")
        
        XCTAssert(hidingMentionsList == false, "ShowMentionsList should be displayed when we type de minimum characters to trigger the mention.")
    }
  
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
