//
//  CCMatchViewController.m
//  MatchedUp
//
//  Created by Eliot Arntz on 12/12/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import "CCMatchViewController.h"

@interface CCMatchViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *matchedUserImageView;
@property (strong, nonatomic) IBOutlet UIImageView *currentUserImageView;

@end

@implementation CCMatchViewController

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
	// Do any additional setup after loading the view.
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.currentUserImageView.image = [UIImage imageWithData:data];
                self.matchedUserImageView.image = self.matchedUserImage;
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)viewChatsButtonPressed:(id)sender
{
    [self.delegate presentMatchesViewController];
}
- (IBAction)keepSearchingButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
