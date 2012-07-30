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

#import <UIKit/UIKit.h>

@class UrlDetailsViewController;

@protocol UrlDetailsViewControllerDelegate <NSObject>
- (void)urlDetailsViewController:(UrlDetailsViewController *)controller didAddUrlWithSlug:(NSString *)urlSlug andFullUrl:(NSString *)fullUrl;
@end

@interface UrlDetailsViewController : UIViewController <UITextFieldDelegate>
    @property (nonatomic, weak) id <UrlDetailsViewControllerDelegate> delegate;
    @property (nonatomic, weak) NSString *urlSlug;
    @property (nonatomic, weak) NSString *fullUrl;
    @property (weak, nonatomic) IBOutlet UITextField *BmakUItxtUrlSlug;
    @property (weak, nonatomic) IBOutlet UITextField *txtFullUrl;
    @property (weak, nonatomic) IBOutlet UITextField *txtShortyUrl;
    @property (weak, nonatomic) IBOutlet UITextField *txtUrlSlug;
    @property (weak, nonatomic) IBOutlet UIButton *btnGoToUrl;
    @property (weak, nonatomic) IBOutlet UILabel *lblGoToUrl;
    @property (weak, nonatomic) IBOutlet UILabel *lblShortyUrl;
    @property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSaveUrl;
    @property BOOL isEditable;
    - (IBAction)tapGoToUrl:(id)sender;
    - (IBAction)tapSaveUrl:(id)sender;
@end
