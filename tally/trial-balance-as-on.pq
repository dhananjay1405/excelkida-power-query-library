/*
    Power Query: Trial Balance (as on Date)

    Input Parameter:
      toDate [date]: TO date
    
    Output Fields: (as below)
      Name [text]: Ledger name
      Parent [text]: Group name
      Balance [number]: (Negative = Dr) | (Positive = Credit)
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportTrialBalanceAsOn</ID></HEADER><BODY><DESC><STATICVARIABLES><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportTrialBalanceAsOn""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldName</FIELDS><FIELDS>FldParent</FIELDS><FIELDS>FldClosingBalance</FIELDS></LINE><FIELD NAME=""FldName""><SET>$Name</SET></FIELD><FIELD NAME=""FldParent""><SET>$Parent</SET></FIELD><FIELD NAME=""FldClosingBalance""><SET>if $$IsDr:$ClosingBalance then -$ClosingBalance else $ClosingBalance</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Ledger</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    toDate = Date.ToText(#date(2020,3,31), "yyyyMMdd"),
    body = Text.Replace(_body, "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body)])), ",#(cr,lf)", "#(cr,lf)"), { "Name", "Parent", "Balance" }),
    Tbl01 = Table.TransformColumns(Source, { {"Balance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}}),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"Balance", type number}})
in
    Tbl02