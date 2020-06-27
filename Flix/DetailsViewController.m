//
//  DetailsViewController.m
//  Flix
//
//  Created by Caroline Reiser on 6/24/20.
//  Copyright © 2020 Caroline Reiser. All rights reserved.
//

#import "DetailsViewController.h"
#import "TrailerViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIView *labelView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *recsButton;


@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labelView.layer.cornerRadius =30;
    
    // Do any additional setup after loading the view.
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";

    //get the URL for the backdrop poster and set it to the image
    if([self.movie[@"backdrop_path"] isKindOfClass:[NSString class]])
    {
       NSString *backdropURLString = self.movie[@"backdrop_path"];
       NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
       NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
       [self.backdropView setImageWithURL:backdropURL];
    }
    
    if([self.movie[@"title"] isKindOfClass:[NSString class]])
    {
        self.titleLabel.text = self.movie[@"title"];
    }
    if([self.movie[@"overview"] isKindOfClass:[NSString class]])
    {
        self.synopsisLabel.text = self.movie[@"overview"];
        //include entire movie description, no matter the length
        [self.synopsisLabel sizeToFit];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"trailerSegue"])
    {
        TrailerViewController  *trailerViewController = [segue destinationViewController];
        trailerViewController.movie = self.movie;
    }
}


@end
