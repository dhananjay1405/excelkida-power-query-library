/*
    Power Query: Trial Balance (for the period)

    Input Parameter:
      fromDate [date]: FROM date
      toDate [date]: TO date
    
    Output Fields: (as below)
      Name [text]: Ledger name
      Parent [text]: Group name
      PrimaryGroup [text]: Ultimate Primary Group as defined in Tally
      OpeningBalance [number]: Opening Balance of Ledger
      Net Debit [number]: Sum of debits to ledger row
      Net Credit [number]: Sum of credits to ledger row
      ClosingBalance [number]: Closing Balance of Ledger
      Description [text]: Optional description of ledger

      Opening / Closing Balance: (Negative = Dr) | (Positive = Credit)
      Net Debit / Credit: Always positive
    
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportTrialBalanceForPeriod</ID></HEADER><BODY><DESC><STATICVARIABLES><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportTrialBalanceForPeriod""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldName,FldParent,FldPrimaryGroup,FldOpeningBalance,FldNetDebit,FldNetCredit,FldClosingBalance,FldDescription</FIELDS></LINE><FIELD NAME=""FldName""><SET>$$StringFindAndReplace:$Name:'""':'""""'</SET></FIELD><FIELD NAME=""FldParent""><SET>$$StringFindAndReplace:$Parent:'""':'""""'</SET></FIELD><FIELD NAME=""FldPrimaryGroup""><SET>if $$IsEmpty:$_PrimaryGroup then $$StrByCharCode:245 else $$StringFindAndReplace:$_PrimaryGroup:'""':'""""'</SET></FIELD><FIELD NAME=""FldOpeningBalance""><SET>$$StringFindAndReplace:(if $$IsDebit:$OpeningBalance then -$$NumValue:$OpeningBalance else $$NumValue:$OpeningBalance):""(-)"":""-""</SET></FIELD><FIELD NAME=""FldNetDebit""><SET>$$Number:$DebitTotals</SET></FIELD><FIELD NAME=""FldNetCredit""><SET>$$Number:$CreditTotals</SET></FIELD><FIELD NAME=""FldClosingBalance""><SET>$$StringFindAndReplace:(if $$IsDebit:$ClosingBalance then -$$NumValue:$ClosingBalance else $$NumValue:$ClosingBalance):""(-)"":""-""</SET></FIELD><FIELD NAME=""FldDescription""><SET>if $$IsEmpty:$Description then $$StrByCharCode:245 else $$StringFindAndReplace:$Description:'""':'""""'</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Ledger</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    fromDate = Date.ToText(#date(2019,4,1), "yyyyMMdd"),  /* FROM date */
    toDate = Date.ToText(#date(2020,3,31), "yyyyMMdd"),  /* TO date */
    body = Text.Replace(Text.Replace(_body, "$fromDate$", fromDate), "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "Name", "Parent", "PrimaryGroup", "OpeningBalance", "Net Debit", "Net Credit", "ClosingBalance", "Description" }),
    Tbl01 = Table.TransformColumns(Source, { { "PrimaryGroup", each Text.Replace(_,"õ","") }, {"OpeningBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"ClosingBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, { "Description", each Text.Replace(_,"õ","") } }),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"OpeningBalance", type number}, {"ClosingBalance", type number}, {"Net Debit", type number}, {"Net Credit", type number}})
in
    Tbl02