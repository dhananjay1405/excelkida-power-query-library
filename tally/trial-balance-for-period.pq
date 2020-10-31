/*
    Power Query: Trial Balance (for the period)

    Input Parameter:
      fromDate [date]: FROM date
      toDate [date]: TO date
    
    Output Fields: (as below)
      Name [text]: Ledger name
      Parent [text]: Group name
      OpeningBalance [number]: Opening Balance of Ledger
      Net Debit [number]: Sum of debits to ledger row
      Net Credit [number]: Sum of credits to ledger row
      ClosingBalance [number]: Closing Balance of Ledger

      Opening / Closing Balance: (Negative = Dr) | (Positive = Credit)
      Net Debit / Credit: Always positive
    
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportTrialBalanceForPeriod</ID></HEADER><BODY><DESC><STATICVARIABLES><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportTrialBalanceForPeriod""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldName</FIELDS><FIELDS>FldParent</FIELDS><FIELDS>FldOpeningBalance</FIELDS><FIELDS>FldNetDebit</FIELDS><FIELDS>FldNetCredit</FIELDS><FIELDS>FldClosingBalance</FIELDS></LINE><FIELD NAME=""FldName""><SET>$Name</SET></FIELD><FIELD NAME=""FldParent""><SET>$Parent</SET></FIELD><FIELD NAME=""FldOpeningBalance""><SET>if $$IsDr:$OpeningBalance then -$OpeningBalance else $OpeningBalance</SET></FIELD><FIELD NAME=""FldNetDebit""><SET>$$Number:$DebitTotals</SET></FIELD><FIELD NAME=""FldNetCredit""><SET>$$Number:$CreditTotals</SET></FIELD><FIELD NAME=""FldClosingBalance""><SET>if $$IsDr:$ClosingBalance then -$ClosingBalance else $ClosingBalance</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Ledger</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    fromDate = Date.ToText(#date(2019,4,1), "yyyyMMdd"),  /* FROM date */
    toDate = Date.ToText(#date(2020,3,31), "yyyyMMdd"),  /* TO date */
    body = Text.Replace(Text.Replace(_body, "$fromDate$", fromDate), "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body)])), ",#(cr,lf)", "#(cr,lf)"), { "Name", "Parent", "OpeningBalance", "Net Debit", "Net Credit", "ClosingBalance" }),
    Tbl01 = Table.TransformColumns(Source, { {"OpeningBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"ClosingBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number} }),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"OpeningBalance", type number}, {"ClosingBalance", type number}, {"Net Debit", type number}, {"Net Credit", type number}})
in
    Tbl02