# URL Shortener - The iOS Client
This is an iOS client for a URL Shortening service.  The client depends on a web service backend written in PHP which is [available here](https://github.com/WindowsAzure-Samples/UrlShortener-PHP).  Once the PHP site is up and running in Windows Azure Websites, the iOS client will allow users to view shortened URLs as well as adding their own.  This sample was built using XCode and the iOS Framework.

Below you will find requirements and deployment instructions.

## Requirements
* OSX - This sample was built on OSX Lion (10.7.4) but should work with more current releases of OSX.
* XCode - This sample was built with XCode 4.4 and requires at least XCode 4.0 due to use of storyboards and ARC.
* Windows Azure Account - Needed to run the PHP website.  [Sign up for a free trial](https://www.windowsazure.com/en-us/pricing/free-trial/).

## Additional Resources
Click the links below for more information on the technologies used in this sample.
* Blog Post - [Starting the iOS Client - Displaying a list of shortened URLs](http://chrisrisner.com/Windows-Azure-Websites-and-Mobile-Clients-Part-3---The-iOS-Client).
* Blog Post - [Displaying shortened URL Detials](http://chrisrisner.com/Windows-Azure-Websites-and-Mobile-Clients-Part-4--The-iOS-Client-Continued).
* Blog Post - [Adding new Shortened URLs from the iOS Client](http://chrisrisner.com/Windows-Azure-Websites-and-Mobile-Clients-Part-5--The-iOS-Client-Finished).

#Specifying your site's subdomain.
Once you've set up your PHP backend with Windows Azure Websites, you will need to enter your site's subdomain into the source/ShortifierDemo/Constants.m file.  Replace all of the <your-subdomain> with the subdomain of the site you set up.

    NSString *kShortifierRootUrl = @"http://<your-subdomain>.azurewebsites.net/";
    NSString *kGetAllUrl = @"http://<your-subdomain>.azurewebsites.net/api-getall";
    NSString *kAddUrl = @"http://<your-subdomain>.azurewebsites.net/api-add";

## Contact

For additional questions or feedback, please contact the [team](mailto:chrisner@microsoft.com).