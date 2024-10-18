let
    periodFromDate = #date(2021,4,1),  /* From Date */
    periodToDate = #date(2022,3,31),  /* To Date */


    /* Specific company trial balance extration  */
    fnTrialBalance = (targetCompany as text, fromDate as date, toDate as date) as table =>
    let
        url = "http://localhost:9000",
        _fromDate = Date.ToText(fromDate, "yyyyMMdd"),  /* FROM date */
        _toDate = Date.ToText(toDate, "yyyyMMdd"),  /* TO date */
        xml_payload_01 = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportTrialBalanceForPeriod</ID></HEADER><BODY><DESC><STATICVARIABLES><SVFROMDATE>$fromDate$</SVFROMDATE><SVTODATE>$toDate$</SVTODATE><SVEXPORTFORMAT>ASCII (Comma Delimited)</SVEXPORTFORMAT><SVCURRENTCOMPANY>$targetCompany</SVCURRENTCOMPANY></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportTrialBalanceForPeriod""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart</PARTS></FORM><PART NAME=""MyPart""><LINES>MyLine</LINES><REPEAT>MyLine : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine""><FIELDS>FldName,FldParent,FldPrimaryGroup,FldOpeningBalance,FldNetDebit,FldNetCredit,FldClosingBalance,FldDescription</FIELDS></LINE><FIELD NAME=""FldName""><SET>$$StringFindAndReplace:$Name:'""':'""""'</SET></FIELD><FIELD NAME=""FldParent""><SET>$$StringFindAndReplace:$Parent:'""':'""""'</SET></FIELD><FIELD NAME=""FldPrimaryGroup""><SET>if $$IsEmpty:$_PrimaryGroup then $$StrByCharCode:245 else $$StringFindAndReplace:$_PrimaryGroup:'""':'""""'</SET></FIELD><FIELD NAME=""FldOpeningBalance""><SET>$$StringFindAndReplace:(if $$IsDebit:$OpeningBalance then -$$NumValue:$OpeningBalance else $$NumValue:$OpeningBalance):""(-)"":""-""</SET></FIELD><FIELD NAME=""FldNetDebit""><SET>$$Number:$DebitTotals</SET></FIELD><FIELD NAME=""FldNetCredit""><SET>$$Number:$CreditTotals</SET></FIELD><FIELD NAME=""FldClosingBalance""><SET>$$StringFindAndReplace:(if $$IsDebit:$ClosingBalance then -$$NumValue:$ClosingBalance else $$NumValue:$ClosingBalance):""(-)"":""-""</SET></FIELD><FIELD NAME=""FldDescription""><SET>if $$IsEmpty:$Description then $$StrByCharCode:245 else $$StringFindAndReplace:$Description:'""':'""""'</SET></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Ledger</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
        xml_payload_02 = Text.Replace(xml_payload_01, "$targetCompany", targetCompany),
        xml_payload_03 = Text.Replace(Text.Replace(xml_payload_02, "$fromDate$", _fromDate), "$toDate$", _toDate),
        Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(xml_payload_03, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16), ",#(cr,lf)", "#(cr,lf)"), { "Name", "Parent", "PrimaryGroup", "OpeningBalance", "Net Debit", "Net Credit", "ClosingBalance", "Description", "Notes" }),
        Tbl01 = Table.TransformColumns(Source, { { "PrimaryGroup", each Text.Replace(_,"õ","") }, {"OpeningBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, {"ClosingBalance", each Number.FromText(if _ = "" then "0.00" else Text.Replace(Text.Replace(_,",",""),"(-)","-")) as number}, { "Description", each Text.Replace(_,"õ","") }, { "Notes", each Text.Replace(_,"õ","") } }),
        Tbl02 = Table.TransformColumnTypes(Tbl01,{{"Name", type text}, {"Parent", type text}, {"PrimaryGroup", type text}, {"OpeningBalance", type number}, {"ClosingBalance", type number}, {"Net Debit", type number}, {"Net Credit", type number}, {"Description", type text}, {"Notes", type text}}),
        Tbl03 = Table.AddColumn(Tbl02, "Company", each targetCompany, type text)
    in
        Tbl03,
    
    /* Extraction of list of active company */
    fnCompanyList = () as list =>
    let
        payload = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReportTable</ID></HEADER><BODY><DESC><STATICVARIABLES><SVEXPORTFORMAT>$$SysName:XML</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReportTable""><FORMS>MyForm</FORMS></REPORT><FORM NAME=""MyForm""><PARTS>MyPart01</PARTS><XMLTAG>DATA</XMLTAG></FORM><PART NAME=""MyPart01""><LINES>MyLine01</LINES><REPEAT>MyLine01 : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyLine01""><FIELDS>FldName</FIELDS></LINE><FIELD NAME=""FldName""><SET>$Name</SET><XMLTAG>NAME</XMLTAG></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Company</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
        resp = Text.FromBinary(Web.Contents("http://localhost:9000", [ Content = Text.ToBinary(payload, TextEncoding.Utf16), Headers=[#"Content-Type"="text/xml;charset=utf-16"]]), TextEncoding.Utf16),
        Source = Xml.Tables(resp),
        Table = Source{0}[Table],
        #"Changed Type" = Table.TransformColumnTypes(Table,{{"Element:Text", type text}}),
        #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Element:Text", "Company"}}),
        Company = #"Renamed Columns"[Company]
    in
        Company,
    
    /* extract list of active company and iterate through each of them and merge all the Trial Balance */
    lstActiveCompany = fnCompanyList(),
    Table_Output = Table.Combine(List.Generate(() => 0, each _ < List.Count(lstActiveCompany), each _ + 1, each fnTrialBalance(lstActiveCompany{_}, periodFromDate, periodToDate)))
in
    Table_Output