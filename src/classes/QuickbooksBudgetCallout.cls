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


//    @Future(Callout=true)
    public static void updateOpex(String budgetId, String forecastId, Integer yearEnd) {

//        String name = EncodingUtil.urlEncode('2018-19 Budget 2', 'UTF-8');

        Boolean currentYear;

//        if (Date.today().month() < 4 && )

                //todo: find fallback month

        List<QBProfitAndLoss__c> oldEntries = [SELECT Id FROM QBProfitAndLoss__c
                                            WHERE Month__c >= :Date.today().toStartOfMonth()
                                            AND FISCAL_YEAR(Month__c) = :yearEnd];

        Map<String,QBProfitAndLoss__c> newEntriesMap = new Map<String,QBProfitAndLoss__c>();


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


//
//
//                    if (Date.valueOf(detail.BudgetDate) >= Date.today().toStartOfMonth()){
//
//                        String parent = (nonOpex.contains(detail.AccountRef.name)) ? 'Revenue' : '';
//
//                        QBProfitAndLoss__c pnl = new QBProfitAndLoss__c(
//                                Nominal__c = detail.AccountRef.name,
//                                Parent__c = parent,
//                                Month__c = Date.valueOf(detail.BudgetDate),
//                                Budget__c = detail.Amount,
//                                Actual__c = detail.Amount,
//                                Source__c = parsedResults.QueryResponse.Budget[0].Name
//                        );
//
//                        System.debug(detail.AccountRef.name);
//
//                        toInsert.add(pnl);
//
//                    }
//                }
                }
            }
//
//            delete  toDelete;
//            insert  toInsert;

        }

        String forecastQuery = 'query?query=select%20%2a%20from%20budget%20where%20id%20%3d%20%27' + forecastId + '%27&minorversion=4';
        HttpRequest forecastRequest   = buildCallout(forecastQuery);
        HttpResponse forecastResponse = http.send(forecastRequest);

        System.debug(forecastResponse.getBody());

        if (forecastResponse.getStatusCode() == 200) {

        }



    }

}