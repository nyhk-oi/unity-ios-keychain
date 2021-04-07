# unity-ios-keychain
Use IOSKeyChain in Unity
## How to use
1. copy UnityIOSKeyChain.mm repo/Plugins/iOS/
2. select UnityIOSKeyChain.mm and check "Security" in platform settings 

### Define
```
#if UNITY_IOS
    [DllImport("__Internal")]
	static extern string _Get(string dataType);
    [DllImport("__Internal")]
    static extern int _Add(string dataType, string value);
    [DllImport("__Internal")]
	static extern int _Delete(string dataType);
#endif
```

### Add
```
public int Add(string name, string value)
{
   int x = _AddItem(name, value);
   return x;

}
```
Registered name, value are 
argument.
when successed, return 0
### search and get
    ```
    public string Load(string name)
    {
        string x = _Get(name);
        return x;
    }
    ```

argument is registered name. when item is not exist or error, return null.
### Delete
```  
public int delete(string name)
{
   int x = _Delete(name);
   return x;
}
```
when successed, return 0
