/*
    Power Query: Merges B2B invoice transactions from multiple JSON files of GSTR-1 downloaded from portal into Excel
    
    Note: Please ensure TargetFolder contains only JSON files of GSTR-1. Power Query may produce error if any other type of file is detected in that folder
*/

let
    TargetFolder = "D:\Client\GSTR-1\", /* <<< specify folder containing JSON files */


    /* prepare a list of all files present in target folder */
    myMonths = Table.ToList(Table.SelectColumns(Folder.Files(TargetFolder),{"Name"})),

    /* Function: reads JSON file and flattens its tree structure to tabular with few processing */
    myTable = (mth as text) as table =>
    let
        Source = Json.Document(File.Contents(TargetFolder & mth)),
        b2b = Source[b2b],
        #"Converted to Table" = Table.FromList(b2b, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"ctin", "cfs", "inv"}, {"ctin", "cfs", "inv"}),
        #"Expanded inv" = Table.ExpandListColumn(#"Expanded Column1", "inv"),
        #"Expanded inv1" = Table.ExpandRecordColumn(#"Expanded inv", "inv", {"val", "itms", "inv_typ", "flag", "updby", "pos", "idt", "rchrg", "cflag", "inum", "chksum"}, {"val", "itms", "inv_typ", "flag", "updby", "pos", "idt", "rchrg", "cflag", "inum", "chksum"}),
        #"Expanded itms" = Table.ExpandListColumn(#"Expanded inv1", "itms"),
        #"Expanded itms1" = Table.ExpandRecordColumn(#"Expanded itms", "itms", {"num", "itm_det"}, {"num", "itm_det"}),
        #"Expanded itm_det" = Table.ExpandRecordColumn(#"Expanded itms1", "itm_det", {"rt", "txval", "iamt", "samt", "camt"}, {"rt", "txval", "iamt", "samt", "camt"}),
        #"Removed Columns" = Table.RemoveColumns(#"Expanded itm_det",{"cfs", "num", "flag", "updby", "cflag", "chksum"}),
        #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"ctin", "GSTN"}, {"val", "Invoice_Value"}, {"rt", "Rate"}, {"txval", "Taxable_Value"}, {"iamt", "IGST"}, {"samt", "SGST"}, {"camt", "CGST"}, {"inv_typ", "Invoice_Type"}, {"pos", "Place_of_Supply"}, {"idt", "Invoice_Date"}, {"rchrg", "Is_Reverse_Charge"}, {"inum", "Invoice_Number"}}),
        #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns",null,0,Replacer.ReplaceValue,{"Invoice_Value", "Taxable_Value", "IGST", "SGST", "CGST"}),
        #"Changed Type" = Table.TransformColumnTypes(#"Replaced Value",{{"GSTN", type text}, {"Invoice_Type", type text}, {"Place_of_Supply", type text}, {"Is_Reverse_Charge", type text}, {"Invoice_Number", type text}, {"Invoice_Date", type date}, {"Invoice_Value", type number}, {"Rate", type number}, {"Taxable_Value", type number}, {"IGST", type number}, {"SGST", type number}, {"CGST", type number}}),
        #"Reordered Columns" = Table.ReorderColumns(#"Changed Type",{"GSTN", "Invoice_Date", "Invoice_Number", "Invoice_Value", "Taxable_Value", "IGST", "SGST", "CGST", "Rate", "Invoice_Type", "Place_of_Supply", "Is_Reverse_Charge"})
    in
        #"Reordered Columns",

    /* Loop to process all JSON files in target folder to table data and then merging (combining) of rows of all tables into single */
    Table_Output = Table.Combine(List.Generate(() => 0, each _ < List.Count(myMonths), each _ + 1, each myTable(myMonths{_})))
in
    Table_Output