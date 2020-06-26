//
//  TrailerViewController.m
//  Flix
//
//  Created by Caroline Reiser on 6/26/20.
//  Copyright © 2020 Caroline Reiser. All rights reserved.
//

#import "TrailerViewController.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) NSString *videoKey;
@property (strong, nonatomic) NSDictionary *dataDictionary;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //get movie ID
    
    //append id to API call
    NSString *id =  self.movie[@"id"];
    NSString *tempURLString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US", id];
    //make API call to get video link
    NSURL *url = [NSURL URLWithString:tempURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(error != nil)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            self.dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.videoKey = self.dataDictionary[@"results"][0][@"key"];
            NSLog(@"KEY: %@", self.videoKey);
            //append video key to youtube link
            NSString *tempVideoString = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.videoKey];
            NSLog (@"%@", tempVideoString);
            NSURL *videoURL = [NSURL URLWithString:tempVideoString];
            
            //redirect to youtube
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:videoURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
            [self.webView loadRequest:urlRequest];
        }
    }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
