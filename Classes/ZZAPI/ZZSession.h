//
//  ZZSession.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//
#import "ZZUser.h"
#import "FacebookSessionController.h"


#define ZZ_DEFAULTS_SESSION_KEY @"ZZSession"

/*
 # Create user step one or login.  Used in two step user creation.
 #
 # When creating a new user, we can spread the creation across two
 # steps.  The first step is to pass the email and password.
 # We check to see if the email already exists.  If it does and
 # matches a full user, we attempt login with the password given.
 # If the password is not correct we return an error.
 #
 # If the matched user via the email is an automatic user, we
 # set the password given and set the completed_step to 1 in the user
 # object.
 #
 # If the email matches no user, we create an auto_by_contact user
 # with the given password and set the step to 1.
 #
 # If the call is successful we set up and return the user_credentials
 # cookie.  This way, if a user visits the home page, we can redirect
 # to create step 2 to let them finish the sign up.
 #
 # As a alternative to logging in or creating an account with email
 # and password, you can instead use service and credentials.  The service
 # currently can only be facebook.  The credentials represent the API
 # token that the server then uses to obtain your facebook info and log
 # you in or performs join phase one for the case where you want to create
 # an account.
 #
 # Also, we allow for the full user creation to happen in one step if you
 # provide all necessary params to do so.  You need email, name, username,
 # and password, and set the create flag to true.
 #
 #
 #  Service Credential handling:
 #
 #  For credential login:
 #
 #  When you login you can do so via your service credentials. If the account has been
 #  previously linked we detect the match and associated you with the user that has the matching
 #  credentials. We also associate the remote services user id with our user id in case a user
 #  deletes the credentials. In this case we detect the remote_user_id -> user_id and then
 #  associate the credentials with that user.
 #
 #  If there is no existing link between the server credentials or service user id you must
 #  create an association. That can be done at login time by supplying the service credentials
 #  along with username/email and password. Assuming the email and password are correct you will
 #  be logged in as the user tied to that email. At the same time we also associate the
 #  credentials and service user id to that user. Any subsequent logins can be done with just
 #  the credentials.
 #
 #  For credential join:
 #
 #  When joining, you can provide the service credentials and optionally one or more of the
 #  values for email, username, name, password. Any arguments passed in will override those
 #  fetched from the service credentials. So, for instance, if you do not provide email we will
 #  use the email provided by the remote service. If we have collisions such as the email or
 #  username already existing an error will be returned and the call will fail. On success the
 #  credentials will automatically be associated with the new account. The general approach will
 #  probably be for the client UI to fetch the data from the remove service and present those to
 #  the user as defaults to give them the opportunity to change them
 #
 # This is called as (POST - https):
 #
 # /zz_api/login_or_create
 #
 # This call requires the caller to not be logged in.
 #
 # Input:
 # {
 #   :email => the email to create or login with, can also be username if logging in,
 #   :password => password to create or login with,
 #   :name => optional username, set with name if you want to do the full create in one step
 #   :username => optional name, set with username if you want to do the full create in one step
 #   :follow_user_id => optional id of user to follow - only used if creating the full user right now,
 #   :tracking_token => optional tracking token used to determine who invited you, for session based
 #     api clients (i.e. the web ui) this will be picked up from the session - only used if creating
 #     the full user in one step, otherwise pass in step 2 if needed,
 #   :service => as an alternative to email and password, you can log in via a third party
 #     service such as facebook (facebook is the only service we currently support),
 #   :credentials => the third party service credentials (API Token),
 #   :create => if this flag is present and true, we will assume a user that was not found should be created
 # }
 #
 #
 # Returns:
 # the credentials and user rights.  If the user is an automatic user then you are not
 # fully logged in when this call returns since you must proceed to step 2 to finish the
 # account creation.  If the user is a normal user then you are logged in if no error
 # is returned.
 #
 # {
 #   :user_id => id of this user,
 #   :user_credentials => a string representing the user credentials, to use, set
 #       the user_credentials cookie to this value
 #   :username => only if logging in in one step with username/pwd
 #   :completed_step => the completed step number (will be null when this step is done),
 #   :server => the host you are connected to
 #   :role => the system rights role for this user.  Can be one of
 #     the :available_roles such as:
 #     Admin,Hero,SuperModerator,Moderator,User
 #     The roles are shown from most access to least
 #     So, for example, if you need Moderator rights and you are an Admin
 #     you will be granted access.  On the other hand, if
 #     you are a User you will not be granted access.
 #   :available_roles => Ordered from most access to least lets you determine
 #     the available roles and their order
 #   :zzv_id => token used to user identifier for tracking via mixpanel,
 #   :user => user info as returned in user_info call
 # }
*/


@interface ZZSession : ZZJSONModel



@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSString *user_credentials;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSArray  *available_roles;
@property (nonatomic, strong) NSString *zzv_id;
@property (nonatomic, strong) ZZUser   *user;

@property (nonatomic, readonly) BOOL production;
@property (nonatomic, readonly, retain) NSHTTPCookie *auth_cookie;
@property (atomic) BOOL saved;

//factory methods
+(ZZSession *)currentSession;
+(ZZUser *)currentUser;
+(void) logout;
+(BOOL) loginWithUsername:(NSString*)username 
                      pwd:(NSString*)password 
                  success:(void (^)(void))success 
                  failure:(void (^)(NSError *error))failure;

+(BOOL) loginWithFacebookWithSuccessBlock:(void (^)(void))success 
                                  failure:(void (^)(NSError *error))failure;




-(void) logout;
//init methods
-(id)initWithDictionary:(NSDictionary *)serverJson;
-(NSHTTPCookie *)_makeCookie:(NSString *)userCredentials;
@end
