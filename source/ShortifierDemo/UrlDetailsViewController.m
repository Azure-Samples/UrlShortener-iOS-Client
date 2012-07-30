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

#import "UrlDetailsViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface UrlDetailsViewController ()

@end

@implementation UrlDetailsViewController
@synthesize delegate;
@synthesize isEditable;
@synthesize btnSaveUrl;
@synthesize urlSlug;
@synthesize fullUrl;
@synthesize txtUrlSlug;
@synthesize txtFullUrl;
@synthesize txtShortyUrl;
@synthesize btnGoToUrl;
@synthesize lblGoToUrl;
@synthesize lblShortyUrl;

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
    
    self.txtUrlSlug.delegate = self;
    self.txtFullUrl.delegate = self;
    //Turn on or off editability of text fields
    self.txtUrlSlug.enabled = self.isEditable;
    self.txtFullUrl.enabled = self.isEditable;
    self.txtShortyUrl.enabled = self.isEditable;
    
    if (self.isEditable == NO) {
        self.txtShortyUrl.text = [kShortifierRootUrl stringByAppendingFormat:urlSlug];
        self.title = @"URL Details";
        //Hide the Save bar button item
        [[self navigationItem] setRightBarButtonItem:nil];
        self.txtUrlSlug.text = urlSlug;
        self.txtFullUrl.text = fullUrl;        
    } else {
        self.title= @"Add URL";  
        self.btnGoToUrl.hidden = YES;
        self.lblGoToUrl.hidden = YES;
        self.lblShortyUrl.hidden = YES;
        self.txtShortyUrl.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [self setTxtUrlSlug:nil];
    [self setTxtFullUrl:nil];
    [self setTxtShortyUrl:nil];
    [self setBtnGoToUrl:nil];
    [self setLblGoToUrl:nil];
    [self setLblShortyUrl:nil];
    [self setBtnSaveUrl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)tapGoToUrl:(id)sender {
    NSURL *url = [ [ NSURL alloc ] initWithString: 
                  [kShortifierRootUrl stringByAppendingFormat:urlSlug] ];
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)tapSaveUrl:(id)sender {
    NSString *newUrlSlug = self.txtUrlSlug.text;
    NSString *newFullUrl = self.txtFullUrl.text;
    
    //Check to see if this urlSlug has already been used
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    id valueForSlug = [appDelegate.urls objectForKey:newUrlSlug];
    if (valueForSlug != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to Create Shortened URL" 
                                                        message:@"This URL Slug has already been used.  Please use a different slug." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }    
    //Pass the details of this URL back to the ViewController
	[self.delegate urlDetailsViewController:self didAddUrlWithSlug:newUrlSlug andFullUrl:newFullUrl];
}

/**
 Prevents text entry past acceptable sizes
 */
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
        replacementString:(NSString *)string {
    if (textField == self.txtUrlSlug) {
        NSInteger newTextLength = [textField.text length] - range.length + [string length];        
        //if this is the URL Slug, limit it to 45 characters
        if (newTextLength > 45) {
            return NO;
        }
        return YES;
        
    }
    else if (textField == self.txtFullUrl) {
        NSInteger newTextLength = [textField.text length] - range.length + [string length];        
        //if this is the full url, limit it to 500 charactes
        if (newTextLength > 500) {
            return NO;
        }
        return YES;
    }
    return YES;
}
@end
