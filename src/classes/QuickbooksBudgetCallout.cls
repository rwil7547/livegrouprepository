/**
 * Created by Ronan Williams on 18/06/2018.
 */

public class QuickbooksBudgetCallout {

    public static HttpRequest buildCallout(String query) {

        // build callout parameters
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/' + query);
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);

        return request;

    }


    public static Boolean updateOpexForecast(String budgetId, String forecastId, String year, Date closeMonth) {

        String fiscalYear;
        Integer yearsToAdd;
        Date startDate;

        if (year.equalsIgnoreCase('CURRENT FY')){
            fiscalYear = 'THIS_FISCAL_YEAR';
            yearsToAdd = 0;
            startDate  = (Date.today().month() < 4) ?
                    Date.newInstance(Date.today().year() -1, 04, 01) : Date.newInstance(Date.today().year(), 04, 01);
        } else if (year.equalsIgnoreCase('NEXT FY')){
            fiscalYear = 'NEXT_FISCAL_YEAR';
            yearsToAdd = 1;
        }

        Map<String,QBProfitAndLoss__c> entriesMap   = new Map<String,QBProfitAndLoss__c>();
//        List<QBProfitAndLoss__c> entriesToDelete    = new List<QBProfitAndLoss__c>();
        List<QBProfitAndLoss__c> entriesToDelete    = [SELECT Id FROM QBProfitAndLoss__c
                                                       WHERE (Month__c <= :closeMonth
                                                       AND QBUpdated__c = FALSE)
                                                       OR (Month__c > :closeMonth
                                                       AND QBUpdated__c = TRUE)];

        // todo: delete any entries marked as 'QBUpdated__c' which are LATER than the specified closeMonth
        // todo: delete any entries NOT marked as 'QBUpdated__c' which are EARLIER or EQUAL TO the closeMonth


        for (QBProfitAndLoss__c pnlEntry : Database.query('SELECT Id, Budget__c, Actual__c, BudgetSource__c, ' +
                                            'ForecastSource__c, Month__c, Nominal__c ' +
                                            'FROM QBProfitAndLoss__c ' +
                                            'WHERE Month__c = ' + fiscalYear  + ' ' +
//                                            'WHERE Month__c = ' + fiscalYear  + ' ' +
//                                            'AND Month__c > :closeMonth' + ' ' + ' ' +
                                            'AND QBUpdated__c = FALSE')){
            pnlEntry.Budget__c = 0;
            pnlEntry.Actual__c = 0;
            entriesMap.put(pnlEntry.Month__c.month() + String.valueOf(pnlEntry.Nominal__c), pnlEntry);
        }


        Set<String> nonOpex = new Set<String>{'Events Revenue', 'Other Income', 'Discounts given', 'Discounts/Refunds Given', 'Events COS', 'Amex Charges'};

        // obtain callout information and call Quickbooks change data capture web service
        String budgetQuery = 'query?query=select%20%2a%20from%20budget%20where%20id%20%3d%20%27' + budgetId + '%27&minorversion=4';
        Http http = new Http();
        HttpRequest budgetRequest   = buildCallout(budgetQuery);
        HttpResponse budgetResponse = http.send(budgetRequest);

        System.debug(budgetResponse.getBody());

        if (budgetResponse.getStatusCode() == 200) {
            JSONParserQBOBudget parsedResults = JSONParserQBOBudget.parse(budgetResponse.getBody());
            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Budget.size() == 1) {
                for (JSONParserQBOBudget.cls_BudgetDetail detail : parsedResults.QueryResponse.Budget[0].BudgetDetail) {
//                    if (Date.valueOf(detail.BudgetDate).addYears(yearsToAdd) > closeMonth){
                        String parent       = (nonOpex.contains(detail.AccountRef.name)) ? 'Revenue' : '';
                        String identifier   = Date.valueOf(detail.BudgetDate).month() + detail.AccountRef.name;

                        if (entriesMap.containsKey(identifier)){
                            entriesMap.get(identifier).Budget__c         = detail.Amount;
                            entriesMap.get(identifier).BudgetSource__c   = parsedResults.QueryResponse.Budget[0].Name;
                        } else {
                            entriesMap.put(
                                identifier,
                                new  QBProfitAndLoss__c(
                                    Nominal__c = detail.AccountRef.name,
                                    Parent__c = parent,
                                    Month__c = Date.valueOf(detail.BudgetDate),
                                    Budget__c = detail.Amount,
                                    Actual__c = 0,
                                    BudgetSource__c = parsedResults.QueryResponse.Budget[0].Name
                                )
                            );
//                        }
                    }
                }
            }
        } else {
            return false;
        }

        String forecastQuery = 'query?query=select%20%2a%20from%20budget%20where%20id%20%3d%20%27' + forecastId + '%27&minorversion=4';
        HttpRequest forecastRequest   = buildCallout(forecastQuery);
        HttpResponse forecastResponse = http.send(forecastRequest);

        System.debug(forecastResponse.getBody());

        if (forecastResponse.getStatusCode() == 200) {
            JSONParserQBOBudget parsedResults = JSONParserQBOBudget.parse(forecastResponse.getBody());
            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Budget.size() == 1) {
                for (JSONParserQBOBudget.cls_BudgetDetail detail : parsedResults.QueryResponse.Budget[0].BudgetDetail) {
                    if (Date.valueOf(detail.BudgetDate).addYears(yearsToAdd) > closeMonth) {
                        String parent = (nonOpex.contains(detail.AccountRef.name)) ? 'Revenue' : '';
                        String identifier = Date.valueOf(detail.BudgetDate).month() + detail.AccountRef.name;

                        if (entriesMap.containsKey(identifier)) {
                            entriesMap.get(identifier).Actual__c = detail.Amount;
                            entriesMap.get(identifier).ForecastSource__c = parsedResults.QueryResponse.Budget[0].Name;
                        } else {
                            entriesMap.put(
                                    identifier,
                                    new QBProfitAndLoss__c(
                                            Nominal__c = detail.AccountRef.name,
                                            Parent__c = parent,
                                            Month__c = Date.valueOf(detail.BudgetDate),
                                            Budget__c = 0,
                                            Actual__c = detail.Amount,
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

        for (QBProfitAndLoss__c pnlEntry : entriesMap.values()){
            if (pnlEntry.Budget__c == 0 && pnlEntry.Actual__c == 0){
                entriesToDelete.add(pnlEntry);
            }
        }

        upsert entriesMap.values();
        delete entriesToDelete;

        return true;

    }

}