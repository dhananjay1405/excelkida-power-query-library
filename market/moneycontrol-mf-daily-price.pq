let
    Source = Json.Document(Web.Contents("https://www.moneycontrol.com/mc/widget/mfnavonetimeinvestment/get_chart_value?isin=INF846K01DP8&dur=ALL&ind_id=9&classic=true&type=benchmark&investmentType=Equity")),
    g1 = Source[g1],
    #"Converted to Table" = Table.FromList(g1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"navDate", "navValue", "navValueAdjusted"}, {"navDate", "navValue", "navValueAdjusted"}),
    #"Removed Columns" = Table.RemoveColumns(#"Expanded Column1",{"navValueAdjusted"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns",{{"navDate", type date}, {"navValue", type number}})
in
    #"Changed Type"