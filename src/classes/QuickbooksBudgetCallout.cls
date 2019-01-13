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


    @Future(Callout=true)
    public static void getBudget() {

        String name = EncodingUtil.urlEncode('2018-19 Budget 2', 'UTF-8');


        String query = 'query?query=select%20%2a%20from%20budget%20where%20name%20%3d%20%27' + 2018-19%20Budget%202 + '%27&minorversion=4';

        /// find custom setting, find the name in there , insert that into the string


        // obtain callout information and call Quickbooks change data capture web service
        Http http = new http();
        HttpRequest request = buildCallout(query);
        HttpResponse response = http.send(request);

        System.debug(response.getBody());

        List<QBProfitAndLoss__c> toDelete = [SELECT Id FROM QBProfitAndLoss__c
                                                WHERE Month__c >= :Date.today().toStartOfMonth()
                                                AND Month__c = THIS_FISCAL_YEAR];

        List<QBProfitAndLoss__c> toInsert = new List<QBProfitAndLoss__c>();

        if (response.getStatusCode() == 200) {

            Set<String> nonOpex = new Set<String>{'Events Revenue', 'Other Income', 'Discounts given', 'Discounts/Refunds Given', 'Events COS', 'Amex Charges'};

            JSONParserQBOBudget parsedResults = JSONParserQBOBudget.parse(response.getBody());

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Budget.size() == 1){

                for (JSONParserQBOBudget.cls_BudgetDetail detail : parsedResults.QueryResponse.Budget[0].BudgetDetail) {

                    if (Date.valueOf(detail.BudgetDate) >= Date.today().toStartOfMonth()){

                        String parent = (nonOpex.contains(detail.AccountRef.name)) ? 'Revenue' : '';

                        QBProfitAndLoss__c pnl = new QBProfitAndLoss__c(
                                Nominal__c = detail.AccountRef.name,
                                Parent__c = parent,
                                Month__c = Date.valueOf(detail.BudgetDate),
                                Budget__c = detail.Amount,
                                Actual__c = detail.Amount
                        );

                        System.debug(detail.AccountRef.name);

                        toInsert.add(pnl);

                    }
                }
            }

            delete  toDelete;
            insert  toInsert;

        }

    }

}