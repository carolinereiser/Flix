//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Caroline Reiser on 6/24/20.
//  Copyright © 2020 Caroline Reiser. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "DetailsViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"


@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    // Do any additional setup after loading the view.
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - (layout.minimumInteritemSpacing * (postersPerLine-1))) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
}

- (void)fetchMovies {
   // Do any additional setup after loading the view.
   // API call to get superhero movies
    [self.activityIndicator startAnimating];
   NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/618344/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1"];
   NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
   NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
   NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          //store what is returned in a movies array
          if (error != nil) {
              NSLog(@"%@", [error localizedDescription]);
              //stop the activity indicator
              [self.activityIndicator stopAnimating];
              
              //show an alert when there is no network connection
              UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies" message: @"The Internet connection appears to be offline" preferredStyle:(UIAlertControllerStyleAlert)];
              
              //when user clicks try again, load movies again
              UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
                    [self fetchMovies];
              }];
              
              //add try again to the alert
              [alert addAction:tryAgainAction];
              
              //display alert
              [self presentViewController: alert animated: YES completion: nil];          }
          else {
              NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
              NSLog(@"%@", dataDictionary);
              
              //get array of movies
              self.movies = dataDictionary[@"results"];
              self.filteredMovies = [self.movies arrayByAddingObjectsFromArray:self.filteredMovies];
              [self.collectionView reloadData];
          }
       //stop the activity indicator animation
       [self.activityIndicator stopAnimating];
      }];
   [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    
    //get poster image URL
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains [cd] %@", searchText];
        
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredMovies);
        
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.collectionView reloadData];
}

//dismiss the keyboard when a user presses search
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}




@end
