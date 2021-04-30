/*
    Function: 
*/
(tblName as text, param as text) as any =>
let
    Source = Excel.CurrentWorkbook(),
    tblInput = Source{[Name=tblName]}[Content],
    #"Changed Type" = Table.TransformColumnTypes(tblInput,{{"Parameter", type text}, {"Value", type any}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type", each ([Parameter] = param)),
    Output = Record.Field(#"Filtered Rows"{0},"Value")
in
    Output