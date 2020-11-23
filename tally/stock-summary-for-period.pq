/*
    Power Query: Stock Summary (for the period)

    Input Parameter:
      fromDate [date]: FROM date
      toDate [date]: TO date
    
    Output Fields: (as below)
      Name [text]: Ledger name
      Parent [text]: Group name
      OpeningQuantity [number]: Opening Quantity of Stock Item
      OpeningValue [number]: Opening Value of Stock Item
      InwardQuantity [number]: Inward Quantity of Stock Item
      InwardValue [number]: Inward Value of Stock Item
      OutwardQuantity [number]: Inward Quantity of Stock Item
      OutwardValue [number]: Inward Value of Stock Item
      Net Credit [number]: Sum of credits to ledger row
      ClosingQuantity [number]: Closing Quantity of Stock Item
      ClosingValue [number]: Closing Value of Stock Item
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportStockSummaryForPeriod</ID></HEADER><BODY><DESC><STATICVARIABLES><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportStockSummaryForPeriod""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldName</FIELDS><FIELDS>FldParent</FIELDS><FIELDS>FldOpeningQuantity</FIELDS><FIELDS>FldOpeningValue</FIELDS><FIELDS>FldInwardQuantity</FIELDS><FIELDS>FldInwardValue</FIELDS><FIELDS>FldOutwardQuantity</FIELDS><FIELDS>FldOutwardValue</FIELDS><FIELDS>FldClosingQuantity</FIELDS><FIELDS>FldClosingValue</FIELDS></LINE><FIELD NAME=""FldName""><SET>$Name</SET></FIELD><FIELD NAME=""FldParent""><SET>$Parent</SET></FIELD><FIELD NAME=""FldOpeningQuantity""><SET>if $$IsEmpty:$OpeningBalance then 0 else $$AsAmount:$OpeningBalance</SET></FIELD><FIELD NAME=""FldOpeningValue""><SET>if $$IsEmpty:$OpeningValue then 0 else $OpeningValue</SET></FIELD><FIELD NAME=""FldInwardQuantity""><SET>if $$IsEmpty:$InwardQuantity then 0 else $$AsAmount:$InwardQuantity</SET></FIELD><FIELD NAME=""FldInwardValue""><SET>if $$IsEmpty:$InwardValue then 0 else $InwardValue</SET></FIELD><FIELD NAME=""FldOutwardQuantity""><SET>if $$IsEmpty:$OutwardQuantity then 0 else $$AsAmount:$OutwardQuantity</SET></FIELD><FIELD NAME=""FldOutwardValue""><SET>if $$IsEmpty:$OutwardValue then 0 else $OutwardValue</SET></FIELD><FIELD NAME=""FldClosingQuantity""><SET>if $$IsEmpty:$ClosingBalance then 0 else $$AsAmount:$ClosingBalance</SET></FIELD><FIELD NAME=""FldClosingValue""><SET>if $$IsEmpty:$ClosingValue then 0 else $ClosingValue</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>StockItem</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    fromDate = Date.ToText(#date(2019,4,1), "yyyyMMdd"),  /* FROM date */
    toDate = Date.ToText(#date(2020,3,31), "yyyyMMdd"),  /* TO date */
    body = Text.Replace(Text.Replace(_body, "$fromDate$", fromDate), "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "Name", "Parent", "OpeningQuantity", "OpeningValue", "InwardQuantity", "InwardValue", "OutwardQuantity", "OutwardValue", "ClosingQuantity", "ClosingValue" }),
    Tbl01 = Table.TransformColumns(Source, { {"OpeningQuantity", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"OpeningValue", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"InwardQuantity", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"InwardValue", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"OutwardQuantity", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"OutwardValue", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"ClosingQuantity", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"ClosingValue", each Number.FromText(Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number} }),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"Name", type text}, {"Parent", type text}, {"OpeningQuantity", type number}, {"OpeningValue", type number}, {"InwardQuantity", type number}, {"InwardValue", type number}, {"OutwardQuantity", type number}, {"OutwardValue", type number}, {"ClosingQuantity", type number}, {"ClosingValue", type number} }),
    Tbl03 = Table.AddColumn(Tbl02, "OpeningRate", each if [OpeningQuantity] = 0 then 0 else [OpeningValue] / [OpeningQuantity], type number),
    Tbl04 = Table.AddColumn(Tbl03, "InwardRate", each if [InwardQuantity] = 0 then 0 else [InwardValue] / [InwardQuantity], type number),
    Tbl05 = Table.AddColumn(Tbl04, "OutwardRate", each if [OutwardQuantity] = 0 then 0 else [OutwardValue] / [OutwardQuantity], type number),
    Tbl06 = Table.AddColumn(Tbl05, "ClosingRate", each if [ClosingQuantity] = 0 then 0 else [ClosingValue] / [ClosingQuantity], type number),
    Tbl07 = Table.ReorderColumns(Tbl06, { "Name", "Parent", "OpeningQuantity", "OpeningRate", "OpeningValue", "InwardQuantity", "InwardRate", "InwardValue", "OutwardQuantity", "OutwardRate", "OutwardValue", "ClosingQuantity", "ClosingRate", "ClosingValue" })
in
    Tbl07