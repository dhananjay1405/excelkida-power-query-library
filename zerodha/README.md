# Power Query - Zerodha Kites API

## Background
Zerodha Kites Connect platform offers RESP API for automating orders / trades (which is free). The full suite of API offers fetching of latest market data (which is paid). Power Query has ability to utilize any API to fetch data.

## Pre-requisite
Below are the pre-requisite:
* Zerodha Demat Account
* Subscription of Zerodha Kites API

Detailed process of sign-up is documented on their official Developer website [Zerodha Kites API documentation](https://kite.trade/docs/connect/v3/)


## Generation of API keys
Once sign-up is complete, there is an option to create App (do not confuse it with Mobile App or Software). App is nothing but a gateway to generate API keys. Zerodha might require deduction of charges which can be completed via billing section of portal. Once app is created, it will provide two things as mention below:

* API Key (User ID)
* API Secret (Password)

The confusing part in App creation for non-technical users is **Redirect URL**. Zerodha Kites API server implements dual authentication system for security purpose. There are 2 parts in authentication process

1. **Browser based Authentication:** The first leg of authorization requires user to visit Zerodha API login page. User needs to specify API key in the login URL itself. The login page is similar to regular Zerodha Kites login page. If the login page finds user already logged into Zerodha Kites, then it will skip password field and simply display **Authorize** button. After pressing authorize, Zerodha will redirect the user to **Redirect URL** specified while creating App. The redirected page contains **request_token** in URL.
2. **Local PC based Authentication:**  The second leg of authorization needs to be done from the local PC of the user by making HTTP request. In this part, **API key** , **API Sccret**  and **request_token** needs to be provided along with **SHA256 checksum** of (API Key + Request Token + API Secret) to the API server. API server responds back with **access_token** if authentication is successful.

The **access_token** is sort of quasi-password which expires after few hours. All the subsequent market data fetching API request requires user to provide API Key and access_token in request header for authentication.

## Redirect URL
Zerodha website expects end-user to have their own website which can handle redirection after browser-base authentication is successful. If end-user has technical IT team, they should get this webpage implemented.

In the absense of own website or technical team, end-user can re-use the webpages created by author on his own website, for tutorial demonstration purpose, by specifying [https://erpcloudanalysis.in/utility/zerodha-auth-status](https://erpcloudanalysis.in/utility/zerodha-auth-status) in Redirect URL.

**Note:** Author website logging system captures *API keys* and *request_token* (since Zerodha website redirects back with both in URL). API keys and request_token cannot be used for any hacking, since the real authorization happens on Zerodha login page. API keys is user ID which is anyway sort of public stuff (just like your email ID). The *request_token* is useless, unless one knows the API secret key. If you have any privacy concerns, then it is recommended to get webpage developed for this on your website.

## Steps to generate Access Token
1. Complete browser based authentication to obtain **request_token**
2. Run PowerShell script zerodha-authenticate.ps1 which will ask for API Key, API Secret and request_token. Upon successful authentication, script will display **access_token** (which expires next day 6:00 AM or on logoff from Kites web portal, whichever happens earlier)