//
//  MoviesViewController.m
//  Flix
//
//  Created by Caroline Reiser on 6/24/20.
//  Copyright © 2020 Caroline Reiser. All rights reserved.
//

#import "DetailsViewController.h"
#import "MovieCell.h"
#import "MoviesViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *movies;
@property (strong, nonatomic) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end

static const NSString *kMovieCellIdentifier = @"MovieCell";

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set table view datasource and delegate to self
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
            
    //get the movies from the database
    [self fetchMovies];
    
    //refresh when user swipes to top
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchMovies {
   // Do any additional setup after loading the view.cvlivckvggilengidncrkffhbvlruuet
   //show animation when movies are loading
   [self.activityIndicator startAnimating];
   //request to Movies DB
   NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
   NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
   NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
   NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          //store what is returned in a movies array
          if (error != nil) {   //no network connection
              NSLog(@"%@", [error localizedDescription]);
              //stop the activity indicator
              [self.activityIndicator stopAnimating];
              
              [self showNetworkError];
          }
          else {            //display the movies
              NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
              
              //get array of movies from the API call
              self.movies = dataDictionary[@"results"];
              self.filteredMovies = [self.movies arrayByAddingObjectsFromArray:self.filteredMovies];

              //show updated version in table
              [self.tableView reloadData];
          }
       //stop refreshing (for when a user swiped down to refresh)
       [self.refreshControl endRefreshing];
       //stop the activity indicator
       [self.activityIndicator stopAnimating];
    }];
   [task resume];
}

- (void)showNetworkError
{
    //show an alert when there is no network conn
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies" message: @"The Internet connection appears to be offline" preferredStyle:(UIAlertControllerStyleAlert)];
    
    //when user clicks try again, load movies again
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
          [self fetchMovies];
    }];
    
    //add try again to the alert
    [alert addAction:tryAgainAction];
    
    //display alert
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissKeyboard
{
    [self.searchBar resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to get the moviecells
    __weak MovieCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMovieCellIdentifier forIndexPath:indexPath];
    
    //get the movies from the query
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    //get movie poster URL
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];

    
    //fade in poster image
    cell.posterView.image = nil;
    [cell.posterView setImageWithURLRequest:request placeholderImage:nil
    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
        
        // imageResponse will be nil if the image is cached
        if (imageResponse) {
            cell.posterView.alpha = 0.0;
            cell.posterView.image = image;
            
            //Animate UIImageView back to alpha 1 over 0.3sec
            [UIView animateWithDuration:0.3 animations:^{
                cell.posterView.alpha = 1.0;
            }];
        }
        else {
            cell.posterView.image = image;
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
        cell.posterView.image = nil;
    }];
    
    cell.posterView.layer.cornerRadius = 50;
    cell.posterView.clipsToBounds = YES;
    
    
    return cell;
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
    
    [self.tableView reloadData];
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
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}


@end
