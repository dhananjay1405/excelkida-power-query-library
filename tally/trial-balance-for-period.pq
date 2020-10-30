/*
    Power Query: Trial Balance (for the period)
    
    Field Information (as below)
      Opening / Closing Balance >>> (Negative = Dr) | (Positive = Credit)
      Net Debit / Net Credit >>> Always positive
    Kindly substitute respective FROM/TO period
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReport</ID></HEADER><BODY><DESC><STATICVARIABLES><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReport""><FORMS>MyReport</FORMS></REPORT><FORM NAME=""MyReport""><TOPPARTS>MyReport</TOPPARTS><XMLTAG>""report""</XMLTAG></FORM><PART NAME=""MyReport""><TOPLINES>MyReport</TOPLINES><REPEAT>MyReport : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyReport""><XMLTAG>""item""</XMLTAG><FIELDS>FldName</FIELDS><FIELDS>FldParent</FIELDS><FIELDS>FldOpeningBalance</FIELDS><FIELDS>FldNetDebit</FIELDS><FIELDS>FldNetCredit</FIELDS><FIELDS>FldClosingBalance</FIELDS></LINE><FIELD NAME=""FldName""><SET>$Name</SET><XMLTAG>""name""</XMLTAG></FIELD><FIELD NAME=""FldParent""><SET>$Parent</SET><XMLTAG>""parent""</XMLTAG></FIELD><FIELD NAME=""FldOpeningBalance""><SET>if $$IsDr:$OpeningBalance then -$OpeningBalance else $OpeningBalance</SET><XMLTAG>""openingbalance""</XMLTAG></FIELD><FIELD NAME=""FldNetDebit""><SET>$$Number:$DebitTotals</SET><XMLTAG>""netdebit""</XMLTAG></FIELD><FIELD NAME=""FldNetCredit""><SET>$$Number:$CreditTotals</SET><XMLTAG>""netcredit""</XMLTAG></FIELD><FIELD NAME=""FldClosingBalance""><SET>if $$IsDr:$ClosingBalance then -$ClosingBalance else $ClosingBalance</SET><XMLTAG>""closingbalance""</XMLTAG></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Ledger</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    fromDate = Date.ToText(#date(2019,4,1), "yyyyMMdd"),
    toDate = Date.ToText(#date(2020,3,31), "yyyyMMdd"),
    body = Text.Replace(Text.Replace(_body, "$fromDate$", fromDate), "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body)])), ",#(cr,lf)", "#(cr,lf)"), { "Name", "Parent", "OpeningBalance", "Net Debit", "Net Credit", "ClosingBalance" }),
    Tbl01 = Table.TransformColumns(Source, { {"OpeningBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"ClosingBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number} }),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"OpeningBalance", type number}, {"ClosingBalance", type number}, {"Net Debit", type number}, {"Net Credit", type number}})
in
    Tbl02