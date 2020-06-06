let
    Source = Json.Document(Web.Contents("https://www.moneycontrol.com/mc/widget/basicchart/get_chart_value?classic=true&sc_did=SBI&dur=max")),
    g1 = Source[g1],
    #"Converted to Table" = Table.FromList(g1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"date", "open", "high", "low", "close", "volume", "value"}, {"datetime", "open", "high", "low", "close", "volume", "value"}),
    #"Added Column Date" = Table.AddColumn(#"Expanded Column","date",each Date.FromText(Text.Start([datetime],10))),
    #"Added Column Time" = Table.AddColumn(#"Added Column Date","time",each Time.FromText(Text.Replace(Text.End([datetime],5),"-",":"))),
    #"Removed Columns" = Table.RemoveColumns(#"Added Column Time",{"open", "high", "low", "close", "datetime"})
in
    #"Removed Columns"