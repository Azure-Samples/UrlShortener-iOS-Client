// ----------------------------------------------------------------------------------
// Microsoft Developer & Platform Evangelism
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
// The example companies, organizations, products, domain names,
// e-mail addresses, logos, people, places, and events depicted
// herein are fictitious.  No association with any real company,
// organization, product, domain name, email address, logo, person,
// places, or events is intended or should be inferred.
// ----------------------------------------------------------------------------------

#import "ViewController.h"
#import "AppDelegate.h"
#import "UrlDetailsViewController.h"
#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Hit the server for URL data
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: 
                        [NSURL URLWithString: kGetAllUrl]];
        [self performSelectorOnMainThread:@selector(fetchedData:) 
                               withObject:data waitUntilDone:YES];
    });
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
              JSONObjectWithData:responseData
              
              options:kNilOptions 
              error:&error];
    
    NSString* status =[json objectForKey:@"Status"];
    NSLog(@"status: %@", status);
    _success = [status isEqualToString:@"SUCCESS"];
    
    //If we successfuly pulled the URLs, show them
    if (_success) {
        NSDictionary* urls = [json objectForKey:@"Urls"];
        NSLog(@"urls: %@", urls);
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.urls = [urls mutableCopy];
        
        [self.tableView reloadData];
    } else {
        //Otherwise, show an error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                    message:@"There was an error loading the URL data.  Please try again later." 
                   delegate:self 
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil];
        [alert show];
    }
}    


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewUrlDetails"])
	{
        UrlDetailsViewController *urlDetailsViewController = segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)sender;
        urlDetailsViewController.urlSlug = cell.textLabel.text;
        urlDetailsViewController.isEditable = NO;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        urlDetailsViewController.fullUrl = [appDelegate.urls objectForKey:cell.textLabel.text];        
	} else if ([segue.identifier isEqualToString:@"AddUrl"])
	{
        UrlDetailsViewController *urlDetailsViewController = segue.destinationViewController;
		urlDetailsViewController.delegate = self;
        urlDetailsViewController.isEditable = YES;
	}
}

//Save the URL to the cloud
- (void)urlDetailsViewController:(UrlDetailsViewController *)controller didAddUrlWithSlug:
                                (NSString *)urlSlug andFullUrl:(NSString *)fullUrl {
    
    // Create the request.
    NSMutableURLRequest *theRequest=[NSMutableURLRequest 
                                     requestWithURL:
                                     [NSURL URLWithString: kAddUrl]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:60.0];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];    
    //build an info object and convert to json
    NSDictionary* jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"my_key", @"key",
                                    fullUrl, @"url",
                                    urlSlug, @"url_slug",
                                    nil];
    //convert JSON object to data
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary 
                                            options:NSJSONWritingPrettyPrinted error:&error];    
    [theRequest setHTTPBody:jsonData];        
    //prints out JSON
    NSString *jsonText =  [[NSString alloc] initWithData:jsonData                                        
                                                encoding:NSUTF8StringEncoding];
    NSLog(@"JSON: %@", jsonText);
    
    // create the connection with the request and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
    } else {
        // We should inform the user that the connection failed.
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Add shortened URL locally
    [appDelegate.urls setObject:fullUrl forKey:urlSlug];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:appDelegate.urls.count -1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:
                    [NSArray arrayWithObject:indexPath] 
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];    
}


#pragma NSUrlConnectionDelegate Methods

-(void)connection:(NSConnection*)conn didReceiveResponse:(NSURLResponse *)response 
{
    if (receivedData == NULL) {
        receivedData = [[NSMutableData alloc] init];
    }
    [receivedData setLength:0];
    NSLog(@"didReceiveResponse: responseData length:(%d)", receivedData.length);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData. 
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    NSString *responseText = [[NSString alloc] initWithData:receivedData encoding: NSASCIIStringEncoding];
    NSLog(@"Response: %@", responseText);    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:receivedData                     
                          options:kNilOptions 
                          error:&error];    
    NSString *status = (NSString *)[json valueForKey:@"Status"];
    NSLog(@"Status response from creating URL: %@", status);
    if ([status isEqualToString:@"SUCCESS"]) {
        
    } else if ([status isEqualToString:@"Already Exists"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to Create Shortened URL" 
                              message:@"This URL Slug has already been used.  Please use a different slug." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if ([status isEqualToString:@"FAILURE"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to Create Shortened URL" 
                              message:@"There was an error creating this shortened URL.  Please try again." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to Create Shortened URL" 
                              message:@"There was an error creating this shortened URL.  Please try again." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}









#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    // Return the number of rows in the section.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.urls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSLog( @"Indexpath %i", [ indexPath row ] );
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *keys = [[appDelegate.urls allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *key = [keys objectAtIndex:[indexPath row]];
    cell.textLabel.text = key;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
}



@end
