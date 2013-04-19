MasterShareSDK
==============

This is a simple open source project to make interfacing with social APIs easier. 
Instead of creating web interfaces or server managers for every social API you use, this SDK handles that interface for you.


How to use:

1- Establish what social network you will use.
2- Create an account to access the developer section.
3- Search on the SDK files and select the implement file of the social network that you'll use.
4- Modify the constants at the top of the implement file, fill with the developer data (i.e. CLIENTID, SECRETKEY ) that you received when you created the account on the API.
5- Import "RMMasterSDK.h". It will give you access to the methods.
6- Simply call a method in this way: [[RMMasterSDK SOCIAL-NETWORK] METHOD-TO-CALL];

You will receive a response data, to handle this data, please go to the SDK file and find the method that your are using. 
Now you need to use the delegate system to handle the data.


Note: Almost every social network has an authentication system where you have to sign in with an account.
To handle this issue in an App, you need to modify the plists file of your app. Each API, on each web, has the URL Scheme that you
have to add on the plists file.
