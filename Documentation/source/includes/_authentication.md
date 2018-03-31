# Authentication

## initializeSDK

```objective_c
[client initializeSDK:@"ADD CLIENT_ID"
    oAuthClientSecret:@"ADD CLIENT_SECRET"
            oAuthScope:@"ADD OAUTH_SCOPE"];
```

```swift
CKTClient().initializeSDK("ADD CLIENT ID",
    oAuthClientSecret: "ADD CLIENT SECRET",
            oAuthScope: "ALL")
```


It's a good idea to initialize the SDK when the application launches,
this can be done in the AppDelegate file.

Application scope should be a comma delimited string that can contain any of
the following:

| SCOPE               |
|---------------------|
| ALL                 |
| READ_USER_PROFILE   |
| WRITE_USER_PROFILE  |
| READ_CONVERSATIONS  |
| WRITE_CONVERSATIONS |
| READ_USER           |
| CALLS               |

We use a framework called AppAuth to help with OAuth 2.0 authentication.

AppAuth takes your [**`CLIENT_ID`**](#authorization) and [**`CLIENT_SECRET`**](#authorization) and returns to you an **access token**,
you can the use this access token to logon.

See [AppAuth-iOS](https://github.com/openid/AppAuth-iOS) for examples using AppAuth

Remember to set your **redirectURI** you created when registering your application,
this **redirectURI** tells AppAuth how to get back to your application after
authentication has completed.

Setting your **redirectURI** can be done in the Info section of your applications
project settings

See the image below for an example:

![](/images/urlscheme.png)



## logon

```objective_c
[client logon:@"ADD YOUR ACCESS TOKEN" completion:^(NSDictionary *user, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().logon("ADD YOUR ACCESS TOKEN") { (user, error) in
  // Code goes here
}
```

Logs user into server via given access token. OAuth2 accessToken logon.

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either a user or an error and returns void

## logon

```objective_c
[self logon:@"USER_NAME" password:@"PASSWORD" completion:^(NSDictionary *user, NSError *error) {
// Code goes here
}];
```

```swift
CKTClient().logon("USER_NAME" , password: "PASSWORD") { (user, error) in
// Code goes here
}
```
Logs user into server via given credentials.

Parameter | Type |  Description
--------- | ----------- | ---------
username | string | Username (email) for Resource Owner Grant Type
password | string |  Password for Resource Owner Grant Type
completion | callback | A completion block that takes either a user or an error and returns void

## logout

```objective_c
[client logout:^{
  // Code goes here
}];
```

```swift
CKTClient().logout {
  // Code goes here
}
```

Log this client instance out. Logging out does not revoke the OAuth2
access token

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes no arguments and returns void

## renewToken

```objective_c
[client renewToke:^{
  // Code goes here
}];
```

```swift
CKTClient().renewToken {
  // Code goes here
}
```
Renew the OAuth2 access token of the current user

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either a new access token or an error and returns void

## revokeToken

```objective_c
[client revokeToken:@"ACCESS TOKEN"
         completion:^{
  // Code goes here
}];
```

```swift
CKTClient().revokeToken("ACCESS TOKEN", { (token, error) in
  // Code goes here
})
```

Revoke the OAuth2 access token

Required OAuth2 scopes: N/A

Parameter | Type |  Description
--------- | ----------- | ---------
token | string | Access token, if omitted the internally used access toke is revoked.
completion | callback | A completion block that takes either a new access token or an error and returns void

## validateToken

```objective_c
[client validateToken:@"ACCESS TOKEN"
           completion: ^{
  // Code goes here           
}];
```

```swift
CKTClient().validateToken("ACCESS TOKEN", {
  // Code goes here
})
```

Validates the OAuth2 access token

Required OAuth2 scopes: N/A

Parameter | Type |  Description
--------- | ----------- | ---------
accessToken | string | Access token, if not provided, current access token of the client instance is validated.
completion | callback | A completion block that takes no arguments and returns void.
