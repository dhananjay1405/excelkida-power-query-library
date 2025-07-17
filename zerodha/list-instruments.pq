let
    AuthToken = "token <api_key>:<access_token>",
    Source = Csv.Document(Web.Contents("https://api.kite.trade/instruments", [Headers=[#"Authorization"=AuthToken]]),[Delimiter=",", Columns=12, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"instrument_token", Int64.Type}, {"exchange_token", Int64.Type}, {"tradingsymbol", type text}, {"name", type text}, {"last_price", Int64.Type}, {"expiry", type date}, {"strike", Int64.Type}, {"tick_size", type number}, {"lot_size", Int64.Type}, {"instrument_type", type text}, {"segment", type text}, {"exchange", type text}})
in
    #"Changed Type"