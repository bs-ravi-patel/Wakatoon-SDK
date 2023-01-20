# Wakatoon SDK

This SDK is compatible with iOS 12 or above.

## How to add SDK
Open your Xcode Project and add WakatoonSDK.xcframework in the framework or library section.

## Setup

1) import the wakatoonSDK module:
```
import wakatoonSDK
```

2) Create an instance for the SDK like below.
```bash
var wakatoonSDK: WakatoonSDK?
```

3) Setup SDK as below

 You have to enter a valid API Key, UserID, and ProfileID.
   
 If you want to see logs then set up enableDebugMode as true while setup the SDK.

 If you want to set the language for SDK then select the language code in setLanguage method. However, the default language is set as English.
   
```bash
wakatoonSDK = WakatoonSDK.Builder().initSDK(API_KEY: API_KEY, USER_ID: USER_ID, PROFILE_ID: PROFILE_ID)
            .enableDebugMode(true)
            .setLanguage(.en)
            .build()
```
## Usage

### Update User/UserID
   If you want to update any user/userID then use the below function. 
```
wakatoonSDK?.setUser(USER_ID: USER_ID, completion: {_ in})

```

### Update Profile/ProfileID
   If you want to update any profile/profileID then use the below function.
```
wakatoonSDK?.setProfile(PROFILE_ID: PROFILE_ID, completion: {_ in})
```

### To display the SDK Terms popup then use the below function.
 You have to enter a valid UserID, seasonID and episodeID.
```
wakatoonSDK?.showEulaConfirmationPopUP(controller: UINavigationController, completion: @escaping((_ isAccept: Bool)->()))
```

### To Check if the artwork was drawn or not.
use the below function which gives you a response in Data or Error.
```
wakatoonSDK?.getTheArtwork(storyID: storyID, seasonID: seasonID, episodeId: episodeId, completion: @escaping((_ response: Data?, _ error: Error?)->()))
```

### For Episode Play

 Here image will be the episode thumbnail and you have to enter a valid storyID, seasonID, episodeID and Total episodes in that seasons.

```
wakatoonSDK?.artworkPreview(controller: UINavigationController, image: image, storyID: storyID, seasonID: seasonID, episodeId: episodeId, totalEpisodes: totalEpisodes)
```
##### If you have any video URL of the particular episode then use the below function to directly play the video.
```
wakatoonSDK?.gotoEpisodeOverviewPreview(controller: controller, storyID: storyID, seasonID: seasonID, episodeId: episodeId, videoURLString: videoURLString, totalEpisodes: totalEpisodes)
```
# Delegates

### Access Delegates
```
wakatoonSDK?.delegate = self (where self was class)
```
### Invalid API Key

If your API key is invalid then you will be notified in the above function.

```
func invalidAPIKey()
```

### Episode Drawn

You will be notified when any video will be saved as catch with some user and episode details with saved video URL String.

```
func episodeDrawn(userID: String, profileID: String, storyID: String, seasonId: Int, episodeId: Int, savedURLString: String)
```

### Video Playback Started

You will be notified in the above function when the video will start Playing.

```
func videoPlaybackStarted()
```

### Video Playback Stopped

You will be notified in the above function when the video will stop Playing.

```
func videoPlaybackStopped()
```