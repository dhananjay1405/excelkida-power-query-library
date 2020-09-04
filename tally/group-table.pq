/*
    Power Query: Group table of Tally
    
    Field Information (as below)
      IsRevenue > (Yes = PL) | (No = BS)
      IsDeemedPositive > (Yes = Dr) | (No = Cr)
*/
let
    url = "http://localhost:9000",
    body = "<?xml version=""1.0"" encoding=""utf-8""?><ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Data</TYPE><ID>MyReport</ID></HEADER><BODY><DESC><STATICVARIABLES><SVEXPORTFORMAT>$$SysName:ASCII</SVEXPORTFORMAT></STATICVARIABLES><TDL><TDLMESSAGE><REPORT NAME=""MyReport""><FORMS>MyReport</FORMS></REPORT><FORM NAME=""MyReport""><TOPPARTS>MyReport</TOPPARTS><XMLTAG>""report""</XMLTAG></FORM><PART NAME=""MyReport""><TOPLINES>MyReport</TOPLINES><REPEAT>MyReport : MyCollection</REPEAT><SCROLLED>Vertical</SCROLLED></PART><LINE NAME=""MyReport""><XMLTAG>""item""</XMLTAG><FIELDS>FldGuid</FIELDS><FIELDS>FldName</FIELDS><FIELDS>FldParent</FIELDS><FIELDS>FldIsRevenue</FIELDS><FIELDS>FldIsDeemedPositive</FIELDS></LINE><FIELD NAME=""FldGuid""><SET>$Guid</SET><XMLTAG>""guid""</XMLTAG></FIELD><FIELD NAME=""FldName""><SET>$Name</SET><XMLTAG>""name""</XMLTAG></FIELD><FIELD NAME=""FldParent""><SET>$Parent</SET><XMLTAG>""parent""</XMLTAG></FIELD><FIELD NAME=""FldIsRevenue""><SET>$IsRevenue</SET><XMLTAG>""isrevenue""</XMLTAG></FIELD><FIELD NAME=""FldIsDeemedPositive""><SET>$IsDeemedPositive</SET><XMLTAG>""isdeemedpositive""</XMLTAG></FIELD><COLLECTION NAME=""MyCollection""><TYPE>Group</TYPE></COLLECTION></TDLMESSAGE></TDL></DESC></BODY></ENVELOPE>",
    Source = Csv.Document(Text.Replace(Text.FromBinary(Web.Contents(url, [Content=Text.ToBinary(body)])), ",#(cr,lf)", "#(cr,lf)"), { "GUID", "Name", "Parent", "IsRevenue", "IsDeemedPositive" })
in
    Source