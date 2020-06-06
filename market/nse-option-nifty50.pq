/*
    Live data fetching of NSE - Option Chain - NIFTY50
*/
let
    Source = Json.Document(Web.Contents("https://nseindia.com/api/liveEquity-derivatives?index=nse50_opt", [Headers=[#"User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36", #"Accept-Encoding"="gzip, deflate", #"Accept-Language"="en-GB,en-US;q=0.9,en;q=0.8,hi;q=0.7", Cookie="D4ABA0C764C211BD823CC5EB9C2EB8CB~5VIXshJdu4xId2K+NthIgVyT8DyfKFho4j8Wh0XJsxIEX9DYtGMD9G+i8h0dxB0c3mEqt4csbUvknV81AupMmIEZnVgE+AgQ4hUiCocQBVAhP2YuaBuJGkxOy4FPmhaMvP3+pXtpQinxKp/3y3VFWXKA/th2Ed2Szh30fEiBKnM="]])),
    data = Source[data],
    #"Converted to Table" = Table.FromList(data, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"underlying", "identifier", "instrumentType", "instrument", "contract", "expiryDate", "optionType", "strikePrice", "lastPrice", "change", "pChange", "volume", "totalTurnover", "value", "premiumTurnOver", "underlyingValue", "openInterest", "noOfTrades"}),
    #"Parsed Date" = Table.TransformColumns(#"Expanded Column1",{{"expiryDate", each Date.From(DateTimeZone.From(_)), type date}})
in
    #"Parsed Date"