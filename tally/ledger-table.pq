/*
    Power Query: Ledger table of Tally (with its balances as on date)

    Output Fields (as below)
      GUID [text]: Unique ID allocted by Tally
      Name [text]: Group Name
      Parent [text]: Group under which that group is nested
      Nature [text]: (Yes = PL) | (No = BS)
      Sign [text]: (Yes = Dr) | (No = Cr)
      SortPosition [number]: Position of group for sorting (as defined in Tally)
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportLedgerTable</ID></HEADER><BODY><DESC><STATICVARIABLES><SVEXPORTFORMAT>ASCII (Comma Delimited)</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportLedgerTable""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldGuid,FldName,FldParent,FldIsRevenue,FldIsDeemedPositive,FldSortPosition</FIELDS></LINE><FIELD NAME=""FldGuid""><SET>$Guid</SET></FIELD><FIELD NAME=""FldName""><SET>$$StringFindAndReplace:$Name:'""':'""""'</SET></FIELD><FIELD NAME=""FldParent""><SET>$$StringFindAndReplace:$Parent:'""':'""""'</SET></FIELD><FIELD NAME=""FldIsRevenue""><SET>$IsRevenue</SET></FIELD><FIELD NAME=""FldIsDeemedPositive""><SET>$IsDeemedPositive</SET></FIELD><FIELD NAME=""FldSortPosition""><SET>$SortPosition</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Ledger</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    toDate = Date.ToText(#date(2020,3,31), "yyyyMMdd"),
    body = Text.Replace(_body, "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "GUID", "Name", "Parent", "Nature", "Sign", "SortPosition" }),
    Tbl01 = Table.TransformColumnTypes(Source, { {"GUID", type text}, {"Name", type text}, {"Parent", type text}, {"Nature", type text}, {"Sign", type text}, {"SortPosition", Int64.Type} }),
    Tbl02 = Table.TransformColumns(Tbl01, { {"Nature", each if _ = "Yes" then "PL" else "BS"}, {"Sign", each if _ = "Yes" then "Dr" else "Cr" }})
in
    Tbl02