/*
    Power Query: Ledger table of Tally (with its balances as on date)

    Field Information (as below)
      Nature > (PL = Profit Loss) | (BS = Balance Sheet)
      Balance > (Negative = Dr) | (Positive = Credit)
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReport</ID></HEADER><BODY><DESC><STATICVARIABLES><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReport""><FORMS>MyReport</FORMS></REPORT><FORM NAME=""MyReport""><TOPPARTS>MyReport</TOPPARTS><XMLTAG>""report""</XMLTAG></FORM><PART NAME=""MyReport""><TOPLINES>MyReport</TOPLINES><REPEAT>MyReport : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyReport""><XMLTAG>""item""</XMLTAG><FIELDS>FldName</FIELDS><FIELDS>FldParent</FIELDS><FIELDS>FldIsRevenue</FIELDS><FIELDS>FldIsDeemedPositive</FIELDS><FIELDS>FldClosingBalance</FIELDS></LINE><FIELD NAME=""FldName""><SET>$Name</SET><XMLTAG>""name""</XMLTAG></FIELD><FIELD NAME=""FldParent""><SET>$Parent</SET><XMLTAG>""parent""</XMLTAG></FIELD><FIELD NAME=""FldIsRevenue""><SET>$IsRevenue</SET><XMLTAG>""isrevenue""</XMLTAG></FIELD><FIELD NAME=""FldIsDeemedPositive""><SET>$IsDeemedPositive</SET><XMLTAG>""isdeemedpositive""</XMLTAG></FIELD><FIELD NAME=""FldClosingBalance""><SET>if $$IsDr:$ClosingBalance then -$ClosingBalance else $ClosingBalance</SET><XMLTAG>""openingbalance""</XMLTAG></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Ledger</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    toDate = Date.ToText(#date(2020,3,31), "yyyyMMdd"),
    body = Text.Replace(_body, "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body)])), ",#(cr,lf)", "#(cr,lf)"), { "Name", "Parent", "Nature", "Sign", "Balance" }),
    Tbl01 = Table.TransformColumns(Source, { {"Nature", each if _ = "Yes" then "PL" else "BS"}, {"Sign", each if _ = "Yes" then "Dr" else "Cr" }, {"Balance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}}),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"Balance", type number}})
in
    Tbl02