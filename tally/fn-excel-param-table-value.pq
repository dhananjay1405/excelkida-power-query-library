/*
    Function for automating parameter driven Power Query based on Parameter table prepared in Excel. The table should have two columns [Parameter,Value]
    
    Input:
    tblName (text) : Name of excel table
    param (text): Name of parameter of which to extract value, present in excel table

    Output: Extracts the value of parameter from the target excel table, to be used by another Power Query
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