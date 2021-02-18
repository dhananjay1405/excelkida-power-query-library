/*
    Power Query: Merges HSN Summary from multiple JSON files of GSTR-1 downloaded from portal into Excel
    
    Note: Please ensure TargetFolder contains only JSON files of GSTR-1. Power Query may produce error if any other type of file is detected in that folder

    Period column is added to the end which contain YYYY-MM representation of each JSON file for identification
*/

let
    TargetFolder = "D:\Client\GSTR-1\", /* <<< specify folder containing JSON files */

    /* prepare a list of all files present in target folder */
    myMonths = Table.ToList(Table.SelectColumns(Folder.Files(TargetFolder),{"Name"})),

    /* Function: reads JSON file and flattens its tree structure to tabular with few processing */
    myTable = (mth as text) as table =>
    let
        Source = Json.Document(File.Contents(TargetFolder & mth)),
        hsn = Source[hsn],
        fp = Source[fp],
        data = hsn[data],
        #"Converted to Table" = Table.FromList(data, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"samt", "val", "uqc", "txval", "qty", "num", "camt", "hsn_sc", "iamt", "desc"}, {"samt", "val", "uqc", "txval", "qty", "num", "camt", "hsn_sc", "iamt", "desc"}),
        #"Changed Type" = Table.TransformColumnTypes(#"Expanded Column1",{{"samt", type number}, {"val", type number}, {"txval", type number}, {"qty", type number}, {"num", type number}, {"camt", type number}, {"iamt", type number}, {"uqc", type text}, {"hsn_sc", type text}, {"desc", type text}}),
        #"Reordered Columns" = Table.ReorderColumns(#"Changed Type",{"hsn_sc", "uqc", "qty", "num", "txval", "iamt", "camt", "samt", "val", "desc"}),
        #"Removed Columns" = Table.RemoveColumns(#"Reordered Columns",{"num"}),
        #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"hsn_sc", "HSN_SAC"}, {"uqc", "Unit"}, {"qty", "Quantity"}, {"txval", "Taxable_Value"}, {"iamt", "IGST"}, {"camt", "CGST"}, {"samt", "SGST"}, {"val", "Total_Value"}, {"desc", "Description"}}),
        #"Added Column 01" = Table.AddColumn(#"Renamed Columns", "Period", each Text.Combine({Text.End(fp, 4), "-", Text.Start(fp, 2)}))
    in
        #"Added Column 01",
    
    /* Loop to process all JSON files in target folder to table data and then merging (combining) of rows of all tables into single */
    Table_Output = Table.Combine(List.Generate(() => 0, each _ < List.Count(myMonths), each _ + 1, each myTable(myMonths{_})))
in
    Table_Output