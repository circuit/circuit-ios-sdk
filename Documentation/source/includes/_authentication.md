# CKTClient+Auth

## initializeSDK:oAuthClientSecret:oAuthScope:

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


## renewToken:

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

## revokeToken:completion:

```objective_c
[client revokeToken:@"ACCESS TOKEN"
         completion:^{
  // Code goes here
}];
```

```swift
CKTClient().revokeToken("ACCESS TOKEN", {
  // Code goes here
})
```

Revoke the OAuth2 access token

Required OAuth2 scopes: N/A

Parameter | Type |  Description
--------- | ----------- | ---------
token | string | Access token, if omitted the internally used access toke is revoked.
completion | callback | A completion block that takes either a new access token or an error and returns void

## setOAuthConfig:clientSecret:

```objective_c
[client setOAuthConfig:@"CLIENT_ID" setOAuthConfig:@"CLIENT_SECRET"];
```

```swift
CKTClient().setOAuthConfig("CLIENT_ID", setOAuthConfig:"CLIENT_SECRET)
```

Sets the configuration for OAuth Authentication without scope

Use this method when you want the application to request all permissions

Parameter | Type |  Description
--------- | ----------- | ---------
clientId | string | Application [**`CLIENT_ID`**](#authorization)
clientSecret | string |  Application [**`CLIENT_SECRET`**](#authorization)

## setOAuthConfig:clientSecret:scope:


```objective_c
[client setOAuthConfig:@"CLIENT_ID"
        setOAuthConfig:@"CLIENT_SECRET"
        scope:@"SCOPE"];
```

```swift
CKTClient().setOAuthConfig("CLIENT_ID", setOAuthConfig:"CLIENT_SECRET, scope:"SCOPE")
```

Sets the configuration for OAuth Authentication with scope

Use this method when you want to determine which permissions the application requests.

This could be any of the following in a comma deliminated string

- ALL
- READ_USER_PROFILE
- WRITE_USER_PROFILE
- READ_CONVERSATIONS
- WRITE_CONVERSATION
- READ_USER
- CALLS

Parameter | Type |  Description
--------- | ----------- | ---------
clientId | string | Application [**`CLIENT_ID`**](#authorization)
clientSecret | string |  Application [**`CLIENT_SECRET`**](#authorization)
scope | string | Application scope

## validateToken:completion:

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
