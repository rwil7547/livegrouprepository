/**
 * Created by Ronan Williams on 18/06/2018.
 */

public class QuickbooksBudgetCallout {

    private static HttpRequest buildCallout(String query) {

        // build callout parameters
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/' + query);
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        return request;

    }

    public static Boolean updateOpexForecast(String budgetId, String forecastId, String year, String closeMonthString) {

        String fiscalYear;
        Integer yearsToAdd;
        Date startDate;
        Date closeMonth;
        Boolean closeMonthChanged = false;

        if (year.equalsIgnoreCase('CURRENT FY')){
            fiscalYear = 'THIS_FISCAL_YEAR';
            yearsToAdd = 0;
            startDate  = (Date.today().month() < 4) ?
                          Date.newInstance(Date.today().year() -1, 04, 01) :
                          Date.newInstance(Date.today().year(), 04, 01);
            closeMonth = Date.valueOf(closeMonthString);
            if (closeMonth != QBClosedMonth__c.getInstance('QBClosedMonth').Month__c){
                closeMonthChanged = true;
            }
        } else if (year.equalsIgnoreCase('NEXT FY')){
            fiscalYear = 'NEXT_FISCAL_YEAR';
            startDate  = (Date.today().month() < 4) ?
                    Date.newInstance(Date.today().year(), 04, 01) :
                    Date.newInstance(Date.today().year() + 1, 04, 01);
            closeMonth = (Date.today().month() < 4) ?
                    Date.newInstance(Date.today().year(), 04, 01) :
                    Date.newInstance(Date.today().year() + 1, 04, 01);
        }

        Map<String,QBProfitAndLoss__c> entriesMap   = new Map<String,QBProfitAndLoss__c>();
        List<QBProfitAndLoss__c> entriesToDelete    = new List<QBProfitAndLoss__c>();

        for (QBProfitAndLoss__c pnlEntry : Database.query('SELECT Id, Budget__c, Actual__c, BudgetSource__c, ' +
                                            'ForecastSource__c, Month__c, Nominal__c ' +
                                            'FROM QBProfitAndLoss__c ' +
                                            'WHERE Month__c = ' + fiscalYear)){
            entriesToDelete.add(pnlEntry);
        }

        // query the PNL if the update is for the current financial year
        if (fiscalYear == 'THIS_FISCAL_YEAR'){
            Date calloutDate = startDate;

            system.debug('start date is ' + startDate + ' and closeMonth is ' + closeMonth);
            while (calloutDate <= closeMonth) {

                String start = calloutDate.year() + '-' + calloutDate.month() + '-' + calloutDate.day();
                Date endDate = calloutDate.addMonths(1).addDays(-1);
                String endD  = endDate.year() + '-' + endDate.month() + '-' + endDate.day();
                String query = '/reports/ProfitAndLoss?start_date=' + start + '&end_date=' + endD;

                Http http = new Http();
                HttpRequest request = buildCallout(query);
                HttpResponse response = http.send(request);

                if (response.getStatusCode() == 200) {

                    JSONParserQBOProfitAndLoss parsedResults = JSONParserQBOProfitAndLoss.parse(response.getBody());

                    for (JSONParserQBOProfitAndLoss.cls_Row row : parsedResults.Rows.Row){
                        if (row.Rows != null) {
                            for (JSONParserQBOProfitAndLoss.cls_Row row2 : row.Rows.Row) {
                                if (row2.Summary != null) {
                                    String parent = row2.Summary.ColData[0].value.substring(6);
                                    if (row2.Rows != null) {
                                        for (JSONParserQBOProfitAndLoss.cls_Row row3 : row2.Rows.Row) {
                                            String identifier   = calloutDate.month() + row3.ColData[0].value;

                                            if (entriesMap.containsKey(identifier)) {
                                                entriesMap.get(identifier).Actual__c = Decimal.valueOf(row3.ColData[1].value);
                                                entriesMap.get(identifier).Parent__c = parent;
                                                entriesMap.get(identifier).QBUpdated__c = true;
                                            } else {
                                                QBProfitAndLoss__c qbp = new QBProfitAndLoss__c();
                                                qbp.Nominal__c = row3.ColData[0].value;
                                                qbp.Parent__c = parent;
                                                qbp.Actual__c = Decimal.valueOf(row3.ColData[1].value);
                                                qbp.Budget__c = 0;
                                                qbp.Month__c = calloutDate;
                                                qbp.QBUpdated__c = true;
                                                entriesMap.put(identifier, qbp);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    return false;
                }

                calloutDate = calloutDate.addMonths(1);
            }
        }

        Set<String> nonOpex =
                new Set<String>{'Events Revenue', 'Other Income', 'Discounts given','Rebates',
                                'Discounts/Refunds Given', 'Events COS', 'Amex Charges'};

        // obtain callout information and call Quickbooks change data capture web service
        String budgetQuery = 'query?query=select%20%2a%20from%20budget%20where%20id%20%3d%20%27' + budgetId + '%27&minorversion=4';
        Http http = new Http();
        HttpRequest budgetRequest   = buildCallout(budgetQuery);
        HttpResponse budgetResponse = http.send(budgetRequest);

        if (budgetResponse.getStatusCode() == 200) {
            JSONParserQBOBudget parsedResults = JSONParserQBOBudget.parse(budgetResponse.getBody());
            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Budget.size() == 1) {

                system.debug(startDate);

                Integer yearOffset  = startDate.year() - Date.valueOf(parsedResults.QueryResponse.Budget[0].StartDate).year();

                for (JSONParserQBOBudget.cls_BudgetDetail detail : parsedResults.QueryResponse.Budget[0].BudgetDetail) {

                    Date budgetDate     = Date.valueOf(detail.BudgetDate).addYears(yearOffset);
                    String parent       = (nonOpex.contains(detail.AccountRef.name)) ? 'Revenue' : '';
                    String identifier   = budgetDate.month() + detail.AccountRef.name;

                    if (entriesMap.containsKey(identifier)){
                        entriesMap.get(identifier).Budget__c         = detail.Amount;
                        entriesMap.get(identifier).BudgetSource__c   = parsedResults.QueryResponse.Budget[0].Name;
                    } else {
                        entriesMap.put(
                            identifier,
                            new  QBProfitAndLoss__c(
                                Nominal__c  = detail.AccountRef.name,
                                Parent__c   = parent,
                                Month__c    = budgetDate,
                                Budget__c   = detail.Amount,
                                Actual__c   = 0,
                                BudgetSource__c = parsedResults.QueryResponse.Budget[0].Name
                            )
                        );
                    }
                }
            }
        } else {
            return false;
        }

        String forecastQuery = 'query?query=select%20%2a%20from%20budget%20where%20id%20%3d%20%27' + forecastId +
                '%27&minorversion=4';
        HttpRequest forecastRequest   = buildCallout(forecastQuery);
        HttpResponse forecastResponse = http.send(forecastRequest);

        System.debug(forecastResponse.getBody());

        if (forecastResponse.getStatusCode() == 200) {
            JSONParserQBOBudget parsedResults = JSONParserQBOBudget.parse(forecastResponse.getBody());
            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Budget.size() == 1) {

                Integer yearOffset  = startDate.year() - Date.valueOf(parsedResults.QueryResponse.Budget[0].StartDate).year();

                for (JSONParserQBOBudget.cls_BudgetDetail detail : parsedResults.QueryResponse.Budget[0].BudgetDetail) {

                    Date budgetDate     = Date.valueOf(detail.BudgetDate).addYears(yearOffset);

                    if (budgetDate > closeMonth) {
                        String parent = (nonOpex.contains(detail.AccountRef.name)) ? 'Revenue' : '';
                        String identifier = budgetDate.month() + detail.AccountRef.name;

                        if (entriesMap.containsKey(identifier)) {
                            entriesMap.get(identifier).Actual__c = detail.Amount;
                            entriesMap.get(identifier).ForecastSource__c = parsedResults.QueryResponse.Budget[0].Name;
                        } else {
                            entriesMap.put(
                                identifier,
                                new QBProfitAndLoss__c(
                                    Nominal__c  = detail.AccountRef.name,
                                    Parent__c   = parent,
                                    Month__c    = budgetDate,
                                    Budget__c   = 0,
                                    Actual__c   = detail.Amount,
                                    ForecastSource__c = parsedResults.QueryResponse.Budget[0].Name
                                )
                            );
                        }
                    }
                }
            }
        } else {
            return false;
        }

        insert entriesMap.values();
        delete entriesToDelete;

        if (closeMonthChanged){
            QBClosedMonth__c month = QBClosedMonth__c.getInstance('QBClosedMonth');
            month.Month__c = closeMonth;
            update month;
        }

        return true;
    }

}