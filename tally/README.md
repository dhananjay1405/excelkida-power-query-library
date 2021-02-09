# Power Query : Tally data fetching via XML Server

Power Queries to fetch data from Tally via sending TDL (_Tally Developer Language_) commands in XML (_Extended Markup Language_) format to Tally in-built XML Server integration which returns back Tabular data for usage of Power Query, which can then be dumped in Excel or Power BI for further Data Analysis

Supporting XML files containing TDL report specification & commands, which are sent by Power Query (or Power BI) to Tally, are also made available just for reference for those who are interested in knowing in detail some insider information regards how this happens. XML of that file is already included in related Power Query

## Compatibility
* Tally.ERP 9 / Tally Prime
* MS Office 2016 / 2019 / Office 365
* Microsoft Power BI Desktop (available for free)

## Steps

### Excel (Office 365 version)
1. Open the desired Power Query (*.pq file) to be used from the above project

    ![Power Query Tally Query View](https://excelkida.com/image/github/github-power-query-tally-query-view.png)

2. Click on the **Raw** button, which will open textual portion of Power Query (which is easy to copy-paste)
3. Select all text (**Ctrl + A**) > Copy the query (**Ctrl + C**)

    ![Power Query Tally Raw View](https://excelkida.com/image/github/github-power-query-tally-raw-view.png)

4. Open Excel
5. Goto to Data > Get Data > From Other Sources > Blank Query

    ![Power Query Editor Menu](https://excelkida.com/image/github/excel-365-data-getdata-othersource-blankquery.png)

6. Power Query Editor window will be launched. Goto to **Home** > click **Advance Editor** button

    ![Power Query Advance Editor Button](https://excelkida.com/image/github/excel-365-power-query-editor-menu-advance-editor.png)

7. This will launch Advance Editor window
8. Remove exiting auto-generated query & paste it (**Ctrl + V**) with the query copied from browser window of project and then click **Done** button

    ![Power Query Advance Editor Query pasted](https://excelkida.com/image/github/excel-365-power-query-after-pasting.png)

9. Preview of fetched data will be displayed by Power Query editor. Select Close & Load from menu and then click Close & Load

    ![Power Query Advance Editor Preview](https://excelkida.com/image/github/excel-365-power-query-data-preview.png)

10. Preview data will be exported to Excel Worksheet

## Tally Settings required

### Tally.ERP 9 :
1. Gateway of Tally > Configure (F12) > Advance Configuration

    ![Tally.ERP 9 Configuration Menu](https://excelkida.com/image/github/tally-erp9-configuration-menu.png)

2. Change (or ensure) to set Tally.ERP 9 is acting as to **Both** and Port is **9000**

    ![Tally.ERP 9 Advance Configuration](https://excelkida.com/image/github/tally-erp9-advance-configuration-xml-server-setting.png)

3. Restart Tally when prompted

### Tally Prime :
1. Help (F1) > Settings > Connectivity

    ![Tally Prime Connectivity Menu](https://excelkida.com/image/github/tally-prime-connectivity-menu.png)

2. Select Client/Server configuration

    ![Tally Prime Connectivity Config](https://excelkida.com/image/github/tally-prime-connectivity-setting-config-list.png)

3. Change (or ensure) TallyPrime is acting as to **Both** and Port is **9000**

    ![Tally Prime Connectivity Setting](https://excelkida.com/image/github/tally-prime-connectivity-xml-server-setting.png)
