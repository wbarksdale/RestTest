#RestTest, an demo using RestKit on iOS

This project uses RestKit do demo object mapping of user objects, it works with the my other repo RestKitServer.

To open the project, simply double click the RestTest.xcworkspace file. (It won't work if you try to open using the .xcproj file)

You will then want to modify the following line in the `RestTest-Prefix.pch` file (which can be found in the `Supporting Files` group in Xcode):

```C
#define SERVER_BASE_URL @"http://192.168.1.96:80"
```

You can set that to point to a Local Area Network IP, such as your own machine, or a remote server url.

There are also comments in the project that explain basically what is going on.