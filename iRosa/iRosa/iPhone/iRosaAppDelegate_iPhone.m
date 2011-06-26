/*
 * Copyright © 2011 Michael Willekes
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

#import "iRosaAppDelegate_iPhone.h"
#import "KeychainItemWrapper.h"
#import "ocRosa.h"

@implementation iRosaAppDelegate_iPhone

@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [super application:application didFinishLaunchingWithOptions:launchOptions];
    [self.window addSubview:self.tabBarController.view];
    
    // Attempt to get the username (usually an email address) and password from the keychain
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"OPENROSA" accessGroup:nil];
    NSString *username = [keychain objectForKey:(id)kSecAttrAccount];
    NSString *password = [keychain objectForKey:(id)kSecValueData];
    [keychain release];
    
    if ([username length] == 0 || [password length] == 0) {
        
        LoginViewController* loginController 
                = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
        
        [self.tabBarController presentModalViewController:loginController animated:YES];
    
    } else {
        
        // Login using the username and password from the keychain 
        id<OpenRosaServer> server = [[EpiSurveyor alloc] init];
        server.delegate = self;
        server.username = username;
        server.password = password;
        [server login];
    }
    
    return YES;
}

- (void)dealloc {
    [tabBarController release];
	[super dealloc];
}

- (void)requestSuccessful:(id<OpenRosaServer>)server {
    // Login succeeded
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"OPENROSA" accessGroup:nil];
    NSString *username = [keychain objectForKey:(id)kSecAttrAccount];
    NSString *password = [keychain objectForKey:(id)kSecValueData];
    [keychain release];

    NSError *error = nil;
    self.formManager = [FormManager createEncryptedFormManager:username passphrase:password error:&error];
    
    [server release];
}

- (void)requestFailed:(id<OpenRosaServer>)server withMessage:(NSString *)message {
    // Login failed
}

@end
