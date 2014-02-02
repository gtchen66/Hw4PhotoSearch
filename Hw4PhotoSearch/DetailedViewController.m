//
//  DetailedViewController.m
//  Hw4PhotoSearch
//
//  Created by George Chen on 2/2/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import "DetailedViewController.h"

@interface DetailedViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *detailedImage;

@end

@implementation DetailedViewController

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
    // Do any additional setup after loading the view from its nib.
    NSLog(@"viewDidLoad");
    
//    NSURL *detailUrl = [NSURL URLWithString:[self.imageResults[indexPath.item] valueForKeyPath:@"url"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setURL:detailUrl forKey:@"detailUrl"];
    NSURL *detailURL = [defaults URLForKey:@"detailUrl"];
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:detailURL];
    self.detailedImage.image = [UIImage imageWithData:imageData];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
