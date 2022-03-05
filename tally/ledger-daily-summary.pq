/*
    Power Query: Ledger Daily Summary
*/

let
    FromDate = #date(2019,4,1),  /* From  (YYYY,MM,DD) */
    ToDate = #date(2020,3,31),   /* To  (YYYY,MM,DD) */
    LedgerName = "Cash",  /* specify the ledger name */

    _LedgerName = Text.Replace(Text.Replace(Text.Replace(Text.Replace(Text.Replace(LedgerName,"&","&amp;"),"'","&apos;"),"""","&quot;"),">","&gt;"),"<","&lt;"),
    url = "http://localhost:9000",
    body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>Ledger Daily</ID></HEADER><BODY><DESC><STATICVARIABLES><SVEXPORTFORMAT>ASCII (Comma Delimited)</SVEXPORTFORMAT><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><LEDGERNAME>$ledgerName$</LEDGERNAME></STATICVARIABLES></DESC></BODY></ENVELOPE>",
    _body = Text.Replace(Text.Replace(Text.Replace(body, "$ledgerName$", LedgerName), "$fromDate$", Date.ToText(FromDate,"yyyyMMdd")), "$toDate$", Date.ToText(ToDate,"yyyyMMdd")),
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(_body, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "tmp", "Debit", "Credit", "Closing" }),
    Tbl01 = Table.TransformColumnTypes(Source,{ {"tmp", type text}, {"Debit", type number}, {"Credit", type number}, {"Closing", type number} }),
    Tbl02 = Table.TransformColumns(Tbl01, { {"Debit", each if _ = null then 0 else _ }, {"Credit", each if _ = null then 0 else _ }, {"Closing", each if _ = null then 0 else _ } }),
    Tbl03 = Table.AddColumn(Tbl02, "Opening", each [Closing] - [Debit] - [Credit], type number),
    Tbl04 = Table.AddIndexColumn(Tbl03, "idx"),
    Tbl05 = Table.AddColumn(Tbl04, "Day", each Date.AddDays(FromDate, [idx]) ),
    Tbl06 = Table.RemoveColumns(Tbl05, { "tmp", "idx" }),
    Tbl07 = Table.ReorderColumns(Tbl06, { "Day", "Opening", "Debit", "Credit", "Closing" })
in
    Tbl07