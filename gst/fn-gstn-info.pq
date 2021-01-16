/*
    Power Query: Customized function that returns Party name for the corresponding GSTN

    gstn = 15 digit GST Number to search for
    return value = If valid GSTN then name of the party otherwise #Invalid GSTN# is displayed

    Note: This techniques requires session cookie and headers from browser of successful login to GSTN portal (as below)
    BrowserVersion = User Agent HTTP header (i.e. technical browser internal identification code)
    Cookies = AuthToken=<value>;
    (refer YouTube video for tutorial)
*/
(gstn as text) as text =>
let
    BrowserVersion = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36",
    Cookies = "AuthToken=87838557c2f44d80bdb9f687bdb5d1cb;",
    Source = Json.Document(Web.Contents("https://return.gst.gov.in/returns/auth/api/gstr1/userdetails?ctin=" & gstn , [Headers=[#"User-Agent" = BrowserVersion, #"Accept-Encoding"="gzip, deflate", #"Accept-Language"="en-GB,en-US;q=0.9,en;q=0.8,hi;q=0.7", #"Content-Type"="application/json", Referer="https://return.gst.gov.in/returns/auth/gstr1/b2b/invoice/add", Cookie = Cookies]])),
    VendorName = if Source[status] = 1 then Source[data][regName] else "#Invalid GSTN#"
in
    VendorName