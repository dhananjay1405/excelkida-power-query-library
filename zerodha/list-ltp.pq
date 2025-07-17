let
    AuthToken = "token <api_key>:<access_token>", /* replace with your API Key and Access Token */
    Symbols = {"NSE:NIFTY 50", "NSE:INFY", "BSE:JSWSTEEL"}, /* List of Securities in the format EXCHANGE:SYMBOL */
    ReqHeaders = [#"Authorization"=AuthToken],
    Symbol_List = Text.Combine(List.Transform(Symbols, each "i=" & _), "&"),
    TargetURL = "https://api.kite.trade/quote/ltp?" & Symbol_List,
    Source = Json.Document(Web.Contents(TargetURL, [Headers= ReqHeaders])),
    data = Source[data],
    #"Converted to Table" = Record.ToTable(data),
    #"Expanded Value" = Table.ExpandRecordColumn(#"Converted to Table", "Value", {"instrument_token", "last_price"}, {"instrument_token", "last_price"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Value",{{"instrument_token", Int64.Type}, {"last_price", type number}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type",{"instrument_token"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"last_price", "LTP"}})
in
    #"Renamed Columns"