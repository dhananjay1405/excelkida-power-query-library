/*
    Power Query: Ledger Monthly Summary
*/

let
    FinancialYear = "2019-20",  /* YYYY-YY */
    LedgerName = "Cash",  /* specify the ledger name */

    fromDate = #date(Number.FromText(Text.Start(FinancialYear,4)),4,1),
    toDate = #date(Number.FromText(Text.Start(FinancialYear,4))+1,3,31),
    _LedgerName = Text.Replace(Text.Replace(Text.Replace(Text.Replace(Text.Replace(LedgerName,"&","&amp;"),"'","&apos;"),"""","&quot;"),">","&gt;"),"<","&lt;"),
    url = "http://localhost:9000",
    body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>Ledger Monthly Summary</ID></HEADER><BODY><DESC><STATICVARIABLES><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><LEDGERNAME>$ledgerName$</LEDGERNAME></STATICVARIABLES></DESC></BODY></ENVELOPE>",
    _body = Text.Replace(Text.Replace(Text.Replace(body, "$ledgerName$", LedgerName), "$fromDate$", Date.ToText(fromDate,"yyyyMMdd")), "$toDate$", Date.ToText(toDate,"yyyyMMdd")),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(_body, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "Month", "Debit", "Credit", "Closing" }),
    Tbl01 = Table.TransformColumnTypes(Source,{ {"Month", type text}, {"Debit", type number}, {"Credit", type number}, {"Closing", type number} }),
    Tbl02 = Table.TransformColumns(Tbl01, { {"Debit", each if _ = null then 0 else _ }, {"Credit", each if _ = null then 0 else _ }, {"Closing", each if _ = null then 0 else _ } }),
    Tbl03 = Table.AddColumn(Tbl02, "Opening", each [Closing] - [Debit] - [Credit], type number),
    Tbl04 = Table.AddColumn(Tbl03, "Financial Year", each Text.Combine({"FY ", FinancialYear}), type text),
    Tbl05 = Table.AddColumn(Tbl04, "Ledger", each LedgerName, type text),
    Tbl06 = Table.ReorderColumns(Tbl05, { "Ledger", "Financial Year", "Month", "Opening", "Debit", "Credit", "Closing" })
in
    Tbl06