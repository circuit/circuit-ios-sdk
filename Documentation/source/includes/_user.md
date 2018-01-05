# User

## getLoggedOnUser

```objective_c
[client getLoggedOnUser:^(NSDictionary *user, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getLoggedOnUser({ (user, error) in
  // Code goes here
})
```

Returns the current logged on user in JSON format

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either the current logged on user or an error

## getPresence

```objective_c
[client getPresence:@[ "USER ID(s)" ],
               full:YES,
         completion:^(id presence, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getPresence([ "USER ID(s)" ],
            full: true) { (presence, error) in
  // Code goes here            
}
```

Get the presence for a list of user id's

Required OAuth 2 scopes: READ_USER or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
userIds | array | Array of single or multiple user id's
full | boolean | If true, detailed presence is returned, which also includes long/lat, timezone, etc
completion | callback | A completion block that takes either presence or an error and returns void

## getStatusMessage

```objective_c
[client getStatusMessage:^(id status, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getStatusMessage { (status, error) in
  // Code goes here
}
```

Get the status message of the logged in user

Required OAuth2 scopes: READ_USER_PROFILE or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either a status message or an error and returns void.

## getTenantUsers

```objective_c
[client getTenantUsers:@{ OPTIONS },
            completion:^(id users, NSError *error) {
  // Code goes here            
}];
```

```swift
CKTClient().getTenantUsers(["OPTIONS DICTIONARY"]) { (users, error) in
  // Code goes here
}
```

Get the users for this tenant/domain. This API required tenant admin privileges

Required OAuth2 scopes: ALL and only by tenant admins

Parameter | Type |  Description
--------- | ----------- | ---------
options | dictionary | Filter options
completion | callback | A completion block that takes either users or an error and returns void.

## getUserByEmail

```objective_c
[client getUserByEmail:@"ADD EMAIL" completion:^(NSDictionary *user, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getUserByEmail("ADD EMAIL") { (user, error) in
  // Code goes here
}
```

Returns the user in JSON format by the given user email.

Parameter | Type |  Description
--------- | ----------- | ---------
email | string | Email of the user to retrieve
completion | callback | A completion block that takes either a user or an error and returns void

## getUsersByEmail

```objective_c
[client getUsersByEmail:@[ "ADD EMAIL" ] completion:^(NSDictionary *users, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getUsersByEmail([ "ADD EMAIL" ]) { (users, error) in
  // Code goes here
}
```

Returns the users in JSON format by the given array of email addresses.

Parameter | Type |  Description
--------- | ----------- | ---------
emails | array | Array of email addresses of the users to retrieve
completion | callback | A completion block that takes either a user or an error and retutns void

## getUserById

```objective_c
[client getUserById:@"ADD USER ID" completion:^(NSDictionary *user, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getUserById("ADD USER ID") { (user, error) in
  // Code goes here
}
```

Returns the user in JSON format by the given user id

Parameter | Type |  Description
--------- | ----------- | ---------
userId | string | ID of the user to retrieve
completion | callback | A completion block that takes either a user or an error and returns void

## getUsersById

```objective_c
[client getUsersById:@[ "ADD USER ID" ] completion:^(NSDictionary *users, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getUsersById([ "ADD USER ID" ]) { (users, error) in
  // Code goes here
}
```

Returns the users in JSON format by the given array of user id's

Parameter | Type |  Description
--------- | ----------- | ---------
userId | string | ID of the user to retrieve
completion | callback | A completion block that takes either users or an error and returns void

## getUserSettings

```objective_c
[client getUserSettings:^(id settings, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getUserSettings { (settings, error) in
  // Code goes here
}
```

Get all the user settings of the logged in user

Required OAuth2 scopes: READ_USER_PROFILE or ALL

## getUserById

```objective_c
[client getUserById:@"ADD USER ID" completion:^(NSDictionary *user, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getUserById("ADD USER ID") { (user, error) in
  // Code goes here
}
```

Returns the user in JSON format by the given user id

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either user settings or an error and returns void.

## updateUser

```objective_c
[client updateUser:@["USER ATTRIBUTES"] completion:^(void) {
// Code goes here
}];
```

```swift
CKTClient().updateUser("USER ATTRIBUTE") { (void) in
// Code goes here
}
```
Parameter | Type |  Description
--------- | ----------- | ---------
user | dictionary | ictionary containing the user attributes to update
completion | callback | A completion block that takes no arguments and returns void.


## Response

```jsonnet
{
    accounts =     (
                {
            accountId = "USER ACCOUNT ID";
            accountStatus = ACTIVE;
            accountTemplateName = USER;
            canLogon = 1;
            creationTime = 0;
            isDefault = 1;
            isExpired = 0;
            isInGracePeriod = 0;
            lastAccess = LAST ACCESS TIME;
            parentPackageId = "PARENT PACKAGE ID";
            parentPackageName = "PARENT PACKAGE NAME";
            permissions = ( ARRAY OF SYSTEM PERMISSION );
            tags =  ( ARRAY OF SYSTEM TAGS );
            tenantId = "USER TENANT ID";
            userId = "USER ID";
        }
    );
    apiVersion = "SDK API VERSION";
    avatar = "USER AVATAR URL";
    avatarLarge = "USER LARGE AVATAR URL";
    callerId = "";
    clientId = "CLIENT ID";
    company = "";
    cstaNumber = "";
    displayName = "USER FULL NAME";
    emailAddress = "USER EMAIL ADDRESS";
    firstName = "USER FIRST NAME";
    hasAvatar = 1;
    hasPermission =     {
    };
    isExternallyManaged = 0;
    jobTitle = "USER JOB TITLE";
    lastName = "USER LAST NAME";
    locale = "LOCALE SPECIFICATION";
    phoneNumber = "USER PHONE NUMBER";
    userId = "USER ID";
    userPresenceState =     {
        isOptedOut = 0;
        mobile = 0;
        poor = 0;
        state = OFFLINE;
        userId = "USER ID";
    };
    userState = ACTIVE;
    userType = REGULAR;
}
```
Parameter | Type |  Description
--------- | ----------- | ---------
accounts | array | User account details
apiVersion | string | JavaScript sdk api version
avatar | string | User avatar url
avatarLarge | string | User large avatar url
callerId | string |
clientId | string | Client ID
company | string | User company name
cstaNumber | string |
displayName | string | User full name
emailAddress | string | User email address
firstName | string | User first name
hasAvatar | bool | If the user has an avatar
hasPermission | json | Permission the user has
isExternallyManaged | bool |
jobTitle | string | User job title
lastName | string | User last name
locale | string | Locale specification
phoneNumber | string | User phone number
userId | string | User id
userPresenceState | json |
userState | string | Current user status
userType | string | User type
