# unity-ios-keychain
Use IOSKeyChain in Unity
## How to use
1. copy UnityIOSKeyChain.mm repo/Plugins/iOS/
2. select UnityIOSKeyChain.mm and check "Security" in platform settings 

### code
```
#if UNITY_IOS
    [DllImport("__Internal")]
	static extern string _Get(string dataType);
    [DllImport("__Internal")]
    static extern int _AddItem(string dataType, string value);
    [DllImport("__Internal")]
	static extern int _Delete(string dataType);
#endif
```
