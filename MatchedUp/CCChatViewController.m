//
//  CCChatViewController.m
//  MatchedUp
//
//  Created by Eliot Arntz on 12/12/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import "CCChatViewController.h"

@interface CCChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) NSTimer *getNewChatsTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation CCChatViewController

/* Lazy Instantiation */

-(NSMutableArray *)messages
{
    if (!_messages){
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

-(NSMutableArray *)timestamps
{
    if (!_timestamps){
        _timestamps = [[NSMutableArray alloc] init];
    }
    return _timestamps;
}

-(NSMutableArray *)chats
{
    if (!_chats){
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self checkForNewChats];
    
    
    /* setup the chat */
    
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.title = @"Messages";
    self.messageInputView.textView.placeHolder = @"New Message";
    //    [self setBackgroundColor:[UIColor whiteColor]];
    
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatroom[@"user1"];
    if ([testUser1.objectId isEqual:currentUser.objectId]) {
        self.withUser = self.chatroom[@"user2"];
    }
    else {
        self.withUser = self.chatroom[@"user1"];
    }
    
    self.title = self.withUser[@"profile"][@"firstName"];
    self.initialLoadComplete = NO;
    
    self.getNewChatsTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

- (void)buttonPressed:(UIButton *)sender
{
    // Testing pushing/popping messages view
    CCChatViewController *vc = [[CCChatViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.getNewChatsTimer invalidate];
    self.getNewChatsTimer = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text
{
    if (text.length != 0) {
        
    }
    
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    [chat setObject:self.chatroom forKey:@"chatroom"];
    [chat setObject:[PFUser currentUser] forKey:@"fromUser"];
    [chat setObject:self.withUser forKey:@"toUser"];
    [chat setObject:text forKey:@"text"];
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"save complete");
        [self.chats addObject:chat];
        [JSMessageSoundEffect playMessageSentSound];
        [self.tableView reloadData];
    }];
    
    
    //    [self.messages addObject:text];
    //
    //    [self.timestamps addObject:[NSDate date]];
    
    
    /* If we are sending the message do:
     
     
     
     [self.subtitles addObject:arc4random_uniform(100) % 2 ? kSubtitleCook : kSubtitleWoz];
     
     else
     
     
     [JSMessageSoundEffect playMessageReceivedSound];
     
     [self.subtitles addObject:kSubtitleJobs];
     
     */
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* If we are doing the sending return JSBubbleMessageTypeOutgoing
     else JSBubbleMessageTypeIncoming
     
     */
    
    PFObject *chat = self.chats[indexPath.row];
    
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testFromUser = chat[@"fromUser"];
    
    if ([testFromUser.objectId isEqual:currentUser.objectId])
    {
        return JSBubbleMessageTypeOutgoing;
        ;
    }
    else{
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];

    PFUser *currentUser = [PFUser currentUser];
    PFUser *testFromUser = chat[@"fromUser"];
    if ([testFromUser.objectId isEqual:currentUser.objectId])
    {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleGreenColor]];
    }
    else{
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /* JSMessagesViewAvatarPolicyNone */
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    /* change style */
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL


- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if(cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSString *message = chat[@"text"];
    return message;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Helper Methods

-(void) checkForNewChats
{
    int oldChatCount = [self.chats count];
    
    PFQuery *queryForChats  = [PFQuery queryWithClassName:@"Chat"];
    [queryForChats whereKey:@"chatroom" equalTo:self.chatroom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]){
                
                self.chats = [objects mutableCopy];
                
                for (PFObject *object in _chats) {
                    [_messages addObject:object[@"text"]];
                    [_timestamps addObject:object.createdAt];
                }
                [self.tableView reloadData];
                self.initialLoadComplete = YES;
            }
        }
    }];
}

@end
