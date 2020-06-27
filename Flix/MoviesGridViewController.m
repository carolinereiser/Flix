//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Caroline Reiser on 6/24/20.
//  Copyright © 2020 Caroline Reiser. All rights reserved.
//

#import "DetailsViewController.h"
#import "MovieCollectionCell.h"
#import "MoviesGridViewController.h"
#import "UIImageView+AFNetworking.h"


@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) NSArray* ids;
@property (nonatomic, strong) NSString* selectedId;

@end

@implementation MoviesGridViewController

static const NSString *kMovieCellIdentifier = @"MovieCollectionCell";


- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    self.picker.delegate = self;
    self.picker.dataSource =self;
    
    self.ids = @[@"618344", @"466282", @"530915", @"420817", @"157336"];
    
    // Do any additional setup after loading the view.
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - (layout.minimumInteritemSpacing * (postersPerLine - 1))) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
}

- (void)fetchMovies {
   // Do any additional setup after loading the view.
   // API call to get superhero movies
   [self.activityIndicator startAnimating];
    NSString *tempURLString = @"https://api.themoviedb.org/3/movie/618344/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1";
    if([self.selectedId isKindOfClass:[NSString class]])
    {
        tempURLString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1", self.selectedId];
    }

   NSURL *url = [NSURL URLWithString:tempURLString];
   NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
   NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
   NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          //store what is returned in a movies array
          if (error != nil) {
              NSLog(@"%@", [error localizedDescription]);
              //stop the activity indicator
              [self.activityIndicator stopAnimating];
              [self showNetworkError];
          }
          else {
              NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
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

- (void)showNetworkError
{
    //show an alert when there is no network connection
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

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMovieCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    
    //get poster image URL
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
    
    cell.posterView.layer.cornerRadius = 20;
    cell.clipsToBounds = YES;
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        //search for movies in array
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains [cd] %@", searchText];
        
        //update filteredmovies array
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
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

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedId = self.ids[row];
    [self fetchMovies];
    [self viewDidLoad];
}

//formatting and title for picker
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, pickerView.frame.size.width, 44)];
    label.textColor = [UIColor whiteColor];
    NSString* title = nil;
    switch(row)
    {
        case 0:
            title = @"Superhero";
            break;
        case 1:
            title = @"Young Adult";
            break;
        case 2:
            title = @"War";
            break;
        case 3:
            title = @"Disney";
            break;
        case 4:
            title = @"Sci-Fi";
            break;
    }
    label.text = [NSString stringWithFormat:@" %@", title];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
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
