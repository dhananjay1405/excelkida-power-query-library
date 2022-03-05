/*
    Power Query: Stock Item table of Tally
    
    Output Fields (as below)
      GUID [text]: Unique ID allocted by Tally
      Name [text]: Stock Item name
      Parent [text]: Stock Group under which item is nested
      UOM [text]: Unit of Measurement
*/
let
    url = "http://localhost:9000",
    body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportStockItemTable</ID></HEADER><BODY><DESC><STATICVARIABLES><SVEXPORTFORMAT>ASCII (Comma Delimited)</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportStockItemTable""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldGuid</FIELDS><FIELDS>FldName</FIELDS><FIELDS>FldParent</FIELDS><FIELDS>FldBaseUnits</FIELDS></LINE><FIELD NAME=""FldGuid""><SET>$Guid</SET></FIELD><FIELD NAME=""FldName""><SET>$Name</SET></FIELD><FIELD NAME=""FldParent""><SET>$Parent</SET></FIELD><FIELD NAME=""FldBaseUnits""><SET>$BaseUnits</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>StockItem</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "GUID", "Name", "Parent", "UOM" }),
    Tbl = Table.TransformColumnTypes(Source, { {"GUID", type text}, {"Name", type text}, {"Parent", type text}, {"UOM", type text}})
in
    Tbl