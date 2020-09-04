/*
    Power Query: Ledger Vouchers (for the period)
    
    Field Information (as below)
      Amount >>> (Negative = Dr) | (Positive = Credit)
    Kindly substitute respective Ledger Name and FROM/TO period
    Note: This Power Query does not fetch opening balance of ledger, but purely transactions of specified period
*/
let
    url = "http://localhost:9000",
    _body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReport</ID></HEADER><BODY><DESC><STATICVARIABLES><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReport""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><TOPPARTS>MyPart</TOPPARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><XMLTAG>""item""</XMLTAG><FIELDS>FldDate</FIELDS><FIELDS>FldVoucherType</FIELDS><FIELDS>FldLedger</FIELDS><FIELDS>FldAmount</FIELDS><FIELDS>FldNarration</FIELDS></LINE><FIELD NAME=""FldDate""><SET>$Date</SET><XMLTAG>""date""</XMLTAG></FIELD><FIELD NAME=""FldVoucherType""><SET>$VoucherTypeName</SET><XMLTAG>""type""</XMLTAG></FIELD><FIELD NAME=""FldLedger""><SET>$FldLedger</SET><XMLTAG>""ledger""</XMLTAG></FIELD><FIELD NAME=""FldAmount""><SET>$FldAmount</SET><XMLTAG>""amount""</XMLTAG></FIELD><FIELD NAME=""FldNarration""><SET>$Narration</SET><XMLTAG>""narration""</XMLTAG></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Voucher</TYPE><FETCH>Narration,AllLedgerEntries</FETCH><FILTER>FilterVch</FILTER></COLLECTION><SYSTEM TYPE=""Formulae"" NAME=""FilterVch"">NOT $$IsEmpty:($$FilterValue:$LedgerName:AllLedgerEntries:First:FilterVchLedger)</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FilterVchLedger"">$$IsEqual:$LedgerName:""$ledgerName$""</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FilterVchLedgerNot"">NOT $$IsEqual:$LedgerName:""$ledgerName$""</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FldAmount"">if $$IsDr:$$FilterAmtTotal:AllLedgerEntries:FilterVchLedger:$Amount then -$$FilterAmtTotal:AllLedgerEntries:FilterVchLedger:$Amount else $$FilterAmtTotal:AllLedgerEntries:FilterVchLedger:$Amount</SYSTEM><SYSTEM TYPE=""Formulae"" NAME=""FldLedger"">if $$FilterCount:AllLedgerEntries:FilterVchLedgerNot > 1 then ""..."" else $$FilterValue:$LedgerName:AllLedgerEntries:First:FilterVchLedgerNot</SYSTEM></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    fromDate = Date.ToText(#date(2018,4,1), "yyyyMMdd"), /* From */
    toDate = Date.ToText(#date(2019,3,31), "yyyyMMdd"), /* To */
    ledgerName = "Cash", /* Ledger Name */
    body = Text.Replace(Text.Replace(Text.Replace(_body, "$ledgerName$", ledgerName), "$fromDate$", fromDate), "$toDate$", toDate),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body)])), ",#(cr,lf)", "#(cr,lf)"), { "Date", "Voucher Type", "Ledger", "Amount", "Narration" }),
    Tbl01 = Table.TransformColumns(Source, { {"Amount", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number} }),
    Tbl02 = Table.TransformColumnTypes(Tbl01,{{"Date", type date}, {"Voucher Type", type text}, {"Ledger", type text}, {"Amount", type number}, {"Narration", type text}})
in
    Tbl02