//
//  CCChatViewController.h
//  MatchedUp
//
//  Created by Eliot Arntz on 12/12/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface CCChatViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource>

@property (strong, nonatomic) PFObject *chatroom;

@end
