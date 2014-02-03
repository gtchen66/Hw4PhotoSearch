//
//  SearchViewController.m
//  Hw4PhotoSearch
//
//  Created by George Chen on 2/2/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "DetailedViewController.h"

@interface SearchViewController () <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) NSMutableArray *imageResults;
@property (strong, nonatomic) NSString *lastSearch;

- (void)searchForImages:(NSString *)query startingAt:(NSInteger)startingAt;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Photo Search";
        self.imageResults = [NSMutableArray array];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
 //   self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController setTitle:@"hello"];
    
 //   [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    NSLog(@"Version is %@.", version);
    NSComparisonResult verComparison = [version compare:@"7.0"];
    if ((verComparison == NSOrderedSame) || (verComparison == NSOrderedDescending)) {
        // running 7.0 or higher.
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        NSLog(@"Setting values for 7.0");
        self.edgesForExtendedLayout = UIRectEdgeLeft;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
    UINib *cellnib = [UINib nibWithNibName:@"MyCell" bundle:nil];
    [self.photoCollectionView registerNib:cellnib forCellWithReuseIdentifier:@"PhotoCell"];
    self.photoCollectionView.dataSource = self;

    self.photoCollectionView.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"PhotoCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    const int IMAGE_TAG = 2;
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
    
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.item] valueForKeyPath:@"tbUrl"]]];
//    NSLog(@"retrieved image for item %d",indexPath.item);
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval;
    float x = [[self.imageResults[indexPath.item] valueForKeyPath:@"tbWidth"] floatValue];
    float y = [[self.imageResults[indexPath.item] valueForKeyPath:@"tbHeight"] floatValue];
    retval = CGSizeMake(x+2,y+2);
    NSLog(@"for item %d, set x,y to %.1f,%.1f",indexPath.item, x, y);
    return retval;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item number %d",indexPath.item);
    
    NSURL *detailUrl = [NSURL URLWithString:[self.imageResults[indexPath.item] valueForKeyPath:@"url"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setURL:detailUrl forKey:@"detailUrl"];
    
    [self.navigationController pushViewController:[[DetailedViewController alloc]init ] animated:YES];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"Scrolling is finished");
    NSInteger delta = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
    NSLog(@"Scrolling is finished, delta is %d",delta);
    
    if (delta < 20) {
        
        [self searchForImages:self.lastSearch startingAt:[self.imageResults count]];
        [self.navigationController setTitle:@"Scrolling..."];

    }
}

#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked");
    [searchBar setShowsCancelButton:NO animated:YES];
    
    // A (possibly) new search, but always clear first
    [self.imageResults removeAllObjects];
    self.lastSearch = searchBar.text;
    
    [self searchForImages:self.lastSearch startingAt:0];
    [self searchForImages:self.lastSearch startingAt:8];
    
    [searchBar resignFirstResponder];
    
}

- (void)searchForImages:(NSString *)query startingAt:(NSInteger)startingAt {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&start=%d&q=%@", startingAt, [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //        NSLog(@"%@",JSON);
        id results = [JSON valueForKeyPath:@"responseData.results"];
        NSLog(@"%@",results);
        if ([results isKindOfClass:[NSArray class]]) {
//            [self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            NSLog(@"before reloadData, %d entries",[self.imageResults count]);
            [self.photoCollectionView reloadData];
            NSLog(@"after reloadData, %d entries",[self.imageResults count]);
        }
        NSLog(@"Google returned objects, now total of %d",[self.imageResults count]);
    } failure:nil];
    
    [operation start];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

- (void) viewDidLayoutSubviews {
    NSLog(@"inside viewDidLayoutSubviews");
    //    NSLog(@"top: %.2f bottom: %.2f", self.topLayoutGuide.length, self.bottomLayoutGuide.length);
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //        CGRect viewBounds = self.view.bounds;
        //        CGFloat topBarOffset = self.topLayoutGuide.length;
        
        CGRect tmpFrame = self.navigationController.view.frame;
        tmpFrame.origin.y = 20;
        self.navigationController.view.frame = tmpFrame;
        
        NSLog(@"reset to -20, so now self.topLayoutGuide.length is %f",self.topLayoutGuide.length);
        
        //        // snaps the view under the status bar (iOS 6 style)
        //        viewBounds.origin.y = topBarOffset * -1;
        //
        //        // shrink the bounds of your view to compensate for the offset
        //        viewBounds.size.height = viewBounds.size.height + (topBarOffset * -1);
        //        self.view.bounds = viewBounds;
    }
    
}


@end
