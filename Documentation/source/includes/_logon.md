# CKTClient+Logon

## logon:completion:

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

## logon:password:completion:

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

This grant type should only be used if other flows are not viable. Also, it should only be used if the application is trusted by the user.

Parameter | Type |  Description
--------- | ----------- | ---------
username | string | Username (email) for Resource Owner Grant Type
password | string |  Password for Resource Owner Grant Type
completion | callback | A completion block that takes either a user or an error and returns void

## logout:completion:

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
