let
    Source = Web.Page(Web.Contents("https://www.moneycontrol.com/mc/widget/financials/getFinancialData?classic=true&requestType=CIY&scId=IT")),
    Data0 = Source{0}[Data],
    #"Changed Type" = Table.TransformColumnTypes(Data0,{{"Annual", type text}, {"MAR 2020", Int64.Type}, {"MAR 2019", Int64.Type}, {"MAR 2018", Int64.Type}, {"MAR 2017", Int64.Type}, {"MAR 2016", Int64.Type}})
in
    #"Changed Type"