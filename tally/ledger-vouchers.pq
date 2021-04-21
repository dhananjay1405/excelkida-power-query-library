/*
    Power Query: Ledger Vouchers (for the period)

    Input Parameters required
      fromDate [date]:  FROM date
      toDate [date]: TO date
      ledgerName [text]: Name of the ledger
    
    Output Fields (as below)
      Date [date]: Date of transaction
      Voucher Type [text]: Type of vouchers
      Ledger [text]: Corresponding opposite Debit / Credit ledger (... is displayed if multiple Dr/Cr are found for the effect)
      Amount [number]: (Negative = Dr) | (Positive = Credit)
      Narration [text]: Voucher narration
      
    Kindly substitute respective Ledger Name and FROM/TO period
    Note: This Power Query does not fetch opening balance of ledger, but purely transactions of specified period
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportLedgerVouchers</ID></HEADER><BODY><DESC><STATICVARIABLES><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportLedgerVouchers""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldDate,FldVoucherType,FldVoucherNumber,FldLedger,FldAmount,FldNarration</FIELDS></LINE><FIELD NAME=""FldDate""><SET>$Date</SET></FIELD><FIELD NAME=""FldVoucherType""><SET>$VoucherTypeName</SET></FIELD><FIELD NAME=""FldVoucherNumber""><SET>$$StringFindAndReplace:$VoucherNumber:'""':'""""'</SET></FIELD><FIELD NAME=""FldLedger""><SET>$$StringFindAndReplace:$FldLedger:'""':'""""'</SET></FIELD><FIELD NAME=""FldAmount""><SET>$FldAmount</SET></FIELD><FIELD NAME=""FldNarration""><SET>$$StringFindAndReplace:$Narration:'""':'""""'</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Voucher</TYPE><FETCH>Narration,AllLedgerEntries</FETCH><FILTER>FilterCancelledVouchers,FilterOptionalVouchers,FilterVch</FILTER></COLLECTION><SYSTEM TYPE=""Formulae"" NAME=""FilterVch"">NOT $$IsEmpty:($$FilterValue:$LedgerName:AllLedgerEntries:First:FilterVchLedger)</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FilterVchLedger"">$$IsEqual:$LedgerName:""$ledgerName$""</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FilterVchLedgerNot"">NOT $$IsEqual:$LedgerName:""$ledgerName$""</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FldAmount"">if $$IsDr:$$FilterAmtTotal:AllLedgerEntries:FilterVchLedger:$Amount then (-$$FilterAmtTotal:AllLedgerEntries:FilterVchLedger:$Amount) else ($$FilterAmtTotal:AllLedgerEntries:FilterVchLedger:$Amount)</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FldLedger"">if $$FilterCount:AllLedgerEntries:FilterVchLedgerNot > 1 then ($$FullList:AllLedgerEntries:$LedgerName) else ($$FilterValue:$LedgerName:AllLedgerEntries:First:FilterVchLedgerNot)</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FilterCancelledVouchers"">NOT $IsCancelled</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FilterOptionalVouchers"">NOT $IsOptional</SYSTEM></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    fromDate = Date.ToText(#date(2018,4,1), "yyyyMMdd"), /* FROM date */
    toDate = Date.ToText(#date(2019,3,31), "yyyyMMdd"), /* TO date */
    ledgerName = "Cash", /* Ledger Name */
    body = Text.Replace(Text.Replace(Text.Replace(_body, "$ledgerName$", ledgerName), "$fromDate$", fromDate), "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "Date", "Voucher Type", "Voucher Number", "Ledger", "Amount", "Narration" }),
    Tbl01 = Table.TransformColumns(Source, { {"Amount", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number} }),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"Date", type date}, {"Voucher Type", type text}, {"Voucher Number", type text}, {"Ledger", type text}, {"Amount", type number}, {"Narration", type text}})
in
    Tbl02