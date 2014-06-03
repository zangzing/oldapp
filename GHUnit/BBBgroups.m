//
//  Groups.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/31/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//
#import "ZZBaseTest.h"
#import "ZZGroup.h"


@interface BBBgroups : ZZBaseTest

@end


@implementation BBBgroups


- (void)setUp
{
    [super setUp];
    [self login:USERNAME password:PASSWORD];
    
}

- (void)testAAAGroupCreateDelete
{
    NSString *newGroupName = [[self.nameGenerator getName:YES male:YES prefix:YES postfix:YES]stringByAppendingString:@" Group"];

    //create group
    NSError *error = nil;
    ZZGroup *newGroup =[ZZGroup groupWithName:newGroupName error:&error];
    STAssertNotNil( newGroup, @"Unable to create group with initWithName and name: %@", newGroupName);
    STAssertTrue( newGroup.id >0, @"New Group id was  zero or less , it was : %llu", newGroup.id);

    //delete group
    BOOL result = [newGroup delete];
    STAssertTrue( result, @"The call to delete group returned false");
}

- (void)testBBBGroupFetch
{
    //Create new group
    NSString *newGroupName = [[self.nameGenerator getName:YES male:YES prefix:YES postfix:YES]stringByAppendingString:@" Group"];
    NSError *error = nil;
    ZZGroup *newGroup =[ZZGroup groupWithName:newGroupName error:&error];
    STAssertNotNil( newGroup, @"Unable to create group with initWithName and name: %@", newGroupName);
    ZZGroupID newGroupID = newGroup.id;
    
    //Fetch same group
    ZZGroup *retrievedGroup = [[ZZGroup alloc] initWithID:newGroupID];
    STAssertNotNil( retrievedGroup, @"Unable to retrieve just created group with id : %llu", newGroupID);
    STAssertTrue( retrievedGroup.id == newGroupID, @"The id of the retrieved group is <%llu> and does not match the one requested <%llu>", retrievedGroup.id, newGroupID );    

    //Delete created group
    BOOL result = [newGroup delete];
    STAssertTrue( result, @"The call to delete group returned false");

    // RE-Fetch group (should fail)
    retrievedGroup = [[ZZGroup alloc] initWithID:newGroupID];
    STAssertNil( retrievedGroup, @"I was able to retrieve just deleted group with id : %llu", newGroupID);
}

- (void)testCCCGroupEdit
{
    // Create new group
    NSString *newGroupName = [[self.nameGenerator getName:YES male:YES prefix:YES postfix:YES]stringByAppendingString:@" Group"];        
    NSError *error = nil;
    ZZGroup *newGroup =[ZZGroup groupWithName:newGroupName error:&error];
    STAssertNotNil( newGroup, @"Unable to create group with initWithName and name: %@", newGroupName);
    ZZGroupID newGroupID = newGroup.id;
    
    // Update name of the same group
    NSString *editedGroupName = [[self.nameGenerator getName:YES male:YES prefix:YES postfix:YES]stringByAppendingString:@" Group NEWNAME"];        
    ZZGroup *modifiedGroup = [newGroup updateName:  editedGroupName];
    STAssertNotNil(modifiedGroup,@"The call to update album name returned null");
    STAssertTrue(newGroupID == newGroup.id, @"The Edited Group id changed it was %llu its now %llu", newGroupID, newGroup.id);
    STAssertTrue( [editedGroupName isEqualToString:newGroup.name ], @"The existing album name %@ does not match the new name we set %@", newGroup.name, editedGroupName );

    //delete the group
    BOOL result = [newGroup delete];
    STAssertTrue( result, @"The call to delete group returned false");
}

- (void)testDDDGetGroups
{
    NSArray *groups = [_session.user getGroups];
    STAssertNotNil( groups, @"No Groups Were returned for this user");
}


-(void)testEEEAddRemoveMembers
{
    // Create new group
    NSString *newGroupName = [[self.nameGenerator getName:YES male:YES prefix:YES postfix:YES]stringByAppendingString:@" Group"];        
    NSError *error = nil;
    ZZGroup *newGroup =[ZZGroup groupWithName:newGroupName error:&error];
    STAssertNotNil( newGroup, @"Unable to create group with initWithName and name: %@", newGroupName);
   
    //create a few fake emails
    NSString *fakeEmail1 = [[self.nameGenerator getName:NO male:NO prefix:NO postfix:NO]stringByAppendingString:@"AUTOTEST@bucket.zangzing.com"];
    NSString *fakeEmail2 = [[self.nameGenerator getName:NO male:NO prefix:NO postfix:NO]stringByAppendingString:@"AUTOTEST@bucket.zangzing.com"];
    NSString *fakeEmail3 = [[self.nameGenerator getName:NO male:NO prefix:NO postfix:NO]stringByAppendingString:@"AUTOTEST@bucket.zangzing.com"];
    NSString *fakeEmail4 = [[self.nameGenerator getName:NO male:NO prefix:NO postfix:NO]stringByAppendingString:@"AUTOTEST@bucket.zangzing.com"];
    NSString *fakeEmail5 = [[self.nameGenerator getName:NO male:NO prefix:NO postfix:NO]stringByAppendingString:@"AUTOTEST@bucket.zangzing.com"];
    
    NSArray *longEmailArray = [NSArray arrayWithObjects:fakeEmail1, fakeEmail2, fakeEmail3, fakeEmail4, nil];
    NSArray *shortEmailArray = [NSArray arrayWithObjects:fakeEmail5,nil];
    
    NSArray *membersArray;
    // Add 4 emails
    membersArray = [newGroup addMembers:NULL userNames:NULL emails:longEmailArray];
    STAssertTrue( membersArray.count == 4, @"Added 4 members to empty group but addMembers returned an array of length %i", membersArray.count);
        
    //Remove one user
    NSArray *userIDs;
    ZZUser *userToRemove = [ membersArray objectAtIndex:0 ];
    userIDs = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedLongLong: userToRemove.id], nil]; 
    membersArray = [newGroup removeMembers:userIDs];
    STAssertTrue( membersArray.count == 3, @"Removed 1 member from 4 member group but removeMembers returned array with length of %i", membersArray.count);
    
    //Attempt to remove same user
    userIDs = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedLongLong: userToRemove.id], nil]; 
    NSArray *tmpArray = [newGroup removeMembers:userIDs];
    STAssertTrue( tmpArray.count == 3, @"Attempted to removed non-existing member from 3 member group but removeMembers returned array with length of %i", tmpArray.count);
    
    // Add 1 more email
    NSArray *secondMembersArray = [newGroup addMembers:NULL userNames:NULL emails:shortEmailArray];
    STAssertTrue( secondMembersArray.count == 4, @"Added 1 members to 3 member group but addMembers returned an array of length %i",secondMembersArray.count);
   
    //Remove two users
    ZZUser *userToRemove1 = [ secondMembersArray objectAtIndex:2 ];
    ZZUser *userToRemove2 = [ secondMembersArray objectAtIndex:3 ];
    userIDs = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedLongLong: userToRemove1.id],[NSNumber numberWithUnsignedLongLong: userToRemove2.id], nil]; 
    membersArray = [newGroup removeMembers:userIDs];
    STAssertTrue( membersArray.count == 2, @"Removed 2 member from 4 member group but removeMembers returned array with length of %i", membersArray.count);
      
    //delete the group
    BOOL result = [newGroup delete];
    STAssertTrue( result, @"The call to delete group returned false");

}
@end
