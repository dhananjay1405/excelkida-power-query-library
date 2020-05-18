/*
    Extracts into tabular format, NAV of various Mutual Fund Schemes
    Certain processing on data is done before output as follows
    1) Two columns are introduced MF and Scheme, which contains name of Fund House and Scheme Type
    2) Empty rows are removed
*/
let
    Source = Csv.Document(Web.Contents("https://www.amfiindia.com/spages/NAVAll.txt"),[Delimiter=";", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Use First Row as Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Change Type" = Table.TransformColumnTypes(#"Use First Row as Headers",{{"Scheme Code", type text}, {"ISIN Div Payout/ ISIN Growth", type text}, {"ISIN Div Reinvestment", type text}, {"Scheme Name", type text}, {"Net Asset Value", type text}, {"Date", type date}}),
    Tbl01 = Table.SelectRows(#"Change Type", each [Scheme Code] <> " "),
    Tbl02 = Table.AddColumn(Tbl01, "MF", each if Text.EndsWith([Scheme Code],"Mutual Fund") then [Scheme Code] else null),
    Tbl03 = Table.AddColumn(Tbl02, "Scheme", each if Text.Contains([Scheme Code],"Schemes") then [Scheme Code] else null),
    Tbl04 = Table.FillDown(Tbl03, {"MF", "Scheme"}),
    Tbl05 = Table.SelectRows(Tbl04, each [Net Asset Value] <> "")
in
    Tbl05