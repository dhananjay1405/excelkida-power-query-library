let
    Source = Web.Page(Web.Contents("https://www.valueresearchonline.com/stocks/financials-annual-standalone/1764")),
    Data0 = Source{0}[Data],
    #"Changed Type" = Table.TransformColumnTypes(Data0,{{"", type text}, {"TTM", type text}, {"Mar-19", type text}, {"Mar-18", type text}, {"Mar-17", type text}, {"Mar-16", type text}, {"Mar-15", type text}, {"Mar-14", type text}, {"Mar-13", type text}, {"Mar-12", type text}, {"Mar-11", type text}, {"Mar-10", type text}, {"Column13", type text}, {"Column14", type text}, {"Column15", type text}, {"Column16", type text}, {"Column17", type text}, {"Column18", type text}, {"Column19", type text}, {"Column20", type text}, {"Column21", type text}, {"Column22", type text}, {"Column23", type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"", "Particulars"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Head", each if [Particulars] = [TTM] then [Particulars] else null),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "KeepRow", each if ([Particulars]=[TTM]) then 0 else 1),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom1",{"Mar-14", "Mar-13", "Mar-12", "Mar-11", "Mar-10", "Column13", "Column14", "Column15", "Column16", "Column17", "Column18", "Column19", "Column20", "Column21", "Column22", "Column23"}),
    #"Filled Down" = Table.FillDown(#"Removed Columns",{"Head"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Filled Down",{"Head", "Particulars", "TTM", "Mar-19", "Mar-18", "Mar-17", "Mar-16", "Mar-15", "KeepRow"}),
    #"Filtered Rows" = Table.SelectRows(#"Reordered Columns", each ([KeepRow] = 1)),
    #"Removed Columns1" = Table.RemoveColumns(#"Filtered Rows",{"KeepRow"})
in
    #"Removed Columns1"