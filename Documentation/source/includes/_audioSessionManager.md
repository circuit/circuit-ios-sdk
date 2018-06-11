# CKTAudioSessionManager


## setAudioSessionEnabled:

```objective_c
[CKTAudioSessionManager setAudioSessionEnabled:YES];
```

```swift
CKTAudioSessionManager.setAudioSessionEnabled(true)
```





Disable / Enable the active WebRTC audio session

Application can disable / enable the active WebRTC audio session. It is a system wide parameter.
If application disabled WebRTC audio then it is the application's responsibility to enable back it again.
Until this is enabled by application again, all the calls will have no speech path

It is recommended that application shall use this property only upon events that indicate external
usage of audio session.


Parameter | Type |  Description
--------- | ----------- | ---------
enabled | bool | enabled/disabled active audio session
