/**
 * Created by Ronan Williams on 19/05/2019.
 */

public class QuickbooksDashboardCallout {

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

        // get current nominal map
        Map<String,List<String>> parentInfo = getNominalMap();

        String fiscalYear;
//        Integer yearsToAdd;
        Date startDate;
        Date closeMonth;
        Boolean closeMonthChanged = false;


        if (year.equalsIgnoreCase('PREVIOUS FY')) {
            fiscalYear = 'LAST_FISCAL_YEAR';
//            yearsToAdd = 0;
            startDate  = (Date.today().month() < 4) ?
                    Date.newInstance(Date.today().year() -2, 04, 01) :
                    Date.newInstance(Date.today().year() -1, 04, 01);
            closeMonth = Date.valueOf(closeMonthString);
            if (closeMonth != QBClosedMonth__c.getInstance('QBClosedMonth').Month__c){
                closeMonthChanged = true;
            }
        } else if (year.equalsIgnoreCase('CURRENT FY')){
            fiscalYear = 'THIS_FISCAL_YEAR';
//            yearsToAdd = 0;
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
        if (fiscalYear == 'THIS_FISCAL_YEAR' || fiscalYear == 'LAST_FISCAL_YEAR'){
            Date calloutDate = startDate;

            while (calloutDate <= closeMonth) {

                String start = calloutDate.year() + '-' + calloutDate.month() + '-' + calloutDate.day();
                Date endDate = calloutDate.addMonths(1).addDays(-1);
                String endD  = endDate.year() + '-' + endDate.month() + '-' + endDate.day();
                String query = Test.isRunningTest() ? 'pnl' : '/reports/ProfitAndLoss?start_date=' + start + '&end_date=' + endD;

                Http http = new Http();
                HttpRequest request = buildCallout(query);
                HttpResponse response = http.send(request);

                if (response.getStatusCode() == 200) {

                    JSONParserQBOProfitAndLoss parsedResults = JSONParserQBOProfitAndLoss.parse(response.getBody());

                    System.debug(parsedResults);

                    for (JSONParserQBOProfitAndLoss.cls_Row row : parsedResults.Rows.Row){
                        if (row.Rows != null) {
                            for (JSONParserQBOProfitAndLoss.cls_Row row2 : row.Rows.Row) {
                                if (row2.Summary != null) {

                                    System.debug(row2.Summary.ColData[0]);

                                    String parent           = row2.Summary.ColData[0].value.split(' ',3)[2];
                                    String identifier       = calloutDate.month() + parent;

                                    QBProfitAndLoss__c qbp  = new QBProfitAndLoss__c();
                                    qbp.Nominal__c          = parent;
                                    qbp.Parent__c           = parent;
                                    qbp.Category__c         = getCategory(parent);
                                    qbp.IsOpex__c           = parentInfo.containsKey(parent) ?
                                                                parentInfo.get(parent)[1] == 'Expense' : false;
                                    qbp.Actual__c           = Decimal.valueOf(row2.Summary.ColData[1].value);
                                    qbp.Budget__c           = 0;
                                    qbp.Month__c            = calloutDate;
                                    qbp.QBUpdated__c        = true;
                                    entriesMap.put(identifier, qbp);
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

        // obtain budget figures from Quickbooks based on the Id parameter passed to the method
        String budgetQuery = 'query?query=select%20%2a%20from%20budget%20where%20id%20%3d%20%27' + budgetId + '%27&minorversion=4';
        Http http = new Http();
        HttpRequest budgetRequest   = buildCallout(budgetQuery);
        HttpResponse budgetResponse = http.send(budgetRequest);

        if (budgetResponse.getStatusCode() == 200) {
            JSONParserQBOBudget parsedResults = JSONParserQBOBudget.parse(budgetResponse.getBody());
            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Budget.size() == 1) {

                Integer yearOffset  = startDate.year() - Date.valueOf(parsedResults.QueryResponse.Budget[0].StartDate).year();

                for (JSONParserQBOBudget.cls_BudgetDetail detail : parsedResults.QueryResponse.Budget[0].BudgetDetail) {

                    Date budgetDate   = Date.valueOf(detail.BudgetDate).addYears(yearOffset);

                    if (parentInfo.containsKey(detail.AccountRef.name)){
                        String identifier = budgetDate.month() + parentInfo.get(detail.AccountRef.name)[0];

                        if (entriesMap.containsKey(identifier)){
                            entriesMap.get(identifier).Budget__c += detail.Amount;
                            if (entriesMap.get(identifier).ForecastSource__c != parsedResults.QueryResponse.Budget[0].Name){
                                entriesMap.get(identifier).ForecastSource__c = parsedResults.QueryResponse.Budget[0].Name;
                            }
                        } else {
                            entriesMap.put(
                                    identifier,
                                    new  QBProfitAndLoss__c(
                                            Nominal__c  = parentInfo.get(detail.AccountRef.name)[0],
                                            Parent__c   = parentInfo.get(detail.AccountRef.name)[0],
                                            Category__c = getCategory(parentInfo.get(detail.AccountRef.name)[0]),
                                            IsOpex__c   = parentInfo.get(detail.AccountRef.name)[1] == 'Expense',
                                            Month__c    = budgetDate,
                                            Budget__c   = detail.Amount,
                                            Actual__c   = 0,
                                            BudgetSource__c = parsedResults.QueryResponse.Budget[0].Id
                                    )
                            );
                        }
                    }


                }
            }
        } else {
            return false;
        }

        // obtain forecast figures from Quickbooks based on the Id parameter passed to the method
        String forecastQuery = 'query?query=select%20%2a%20from%20budget%20where%20id%20%3d%20%27' + forecastId +
                '%27&minorversion=4';
        HttpRequest forecastRequest   = buildCallout(forecastQuery);
        HttpResponse forecastResponse = http.send(forecastRequest);

        if (forecastResponse.getStatusCode() == 200) {
            JSONParserQBOBudget parsedResults = JSONParserQBOBudget.parse(forecastResponse.getBody());
            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Budget.size() == 1) {

                Integer yearOffset  = startDate.year() - Date.valueOf(parsedResults.QueryResponse.Budget[0].StartDate).year();

                for (JSONParserQBOBudget.cls_BudgetDetail detail : parsedResults.QueryResponse.Budget[0].BudgetDetail) {

                    Date budgetDate     = Date.valueOf(detail.BudgetDate).addYears(yearOffset);

                    if (fiscalYear == 'NEXT_FISCAL_YEAR' || budgetDate > closeMonth) {
                        if (parentInfo.containsKey(detail.AccountRef.name)) {

                            String identifier = budgetDate.month() + parentInfo.get(detail.AccountRef.name)[0];

                            if (entriesMap.containsKey(identifier)) {

                                entriesMap.get(identifier).Actual__c += detail.Amount;

                                if (entriesMap.get(identifier).ForecastSource__c != parsedResults.QueryResponse.Budget[0].Name) {
                                    entriesMap.get(identifier).ForecastSource__c = parsedResults.QueryResponse.Budget[0].Name;
                                }
                            } else {
                                entriesMap.put(
                                        identifier,
                                        new QBProfitAndLoss__c(
                                                Nominal__c = parentInfo.get(detail.AccountRef.name)[0],
                                                Parent__c = parentInfo.get(detail.AccountRef.name)[0],
                                                Category__c = getCategory(parentInfo.get(detail.AccountRef.name)[0]),
                                                IsOpex__c = parentInfo.get(detail.AccountRef.name)[1] == 'Expense',
                                                Month__c = budgetDate,
                                                Budget__c = 0,
                                                Actual__c = detail.Amount,
                                                ForecastSource__c = parsedResults.QueryResponse.Budget[0].Id
                                        )
                                );
                            }
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

    public static Map<String,List<String>> getNominalMap(){

        Map<String,String> parentKeyMap     = new Map<String,String>();
        Map<String,String> parentTypeMap    = new Map<String,String>();
        Map<String,List<String>> childToParent = new Map<String,List<String>>();
        List<Object> accounts               = new List<Object>();

        Http http = new Http();

        String activeQuery                  = 'query?query=select%20%2a%20from%20account%20maxResults%201000&minorversion=4';
        HttpRequest activeRequest           = buildCallout(activeQuery);
        HttpResponse activeResponse         = http.send(activeRequest);
        Map<String, Object> activeQueryResponse   = (Map<String, Object>) JSON.deserializeUntyped(activeResponse.getBody());
        Map<String, Object> activeResponseKeys    = (Map<String, Object>) activeQueryResponse.get('QueryResponse');
        accounts.addAll((List<Object>) activeResponseKeys.get('Account'));

        String inactiveQuery                = 'query?query=select%20%2a%20from%20account%20where%20active%20%3d%20false%20maxResults%201000&minorversion=4';
        HttpRequest inactiveRequest         = buildCallout(inactiveQuery);
        HttpResponse inactiveResponse       = http.send(inactiveRequest);
        Map<String, Object> inactiveQueryResponse   = (Map<String, Object>) JSON.deserializeUntyped(inactiveResponse.getBody());
        Map<String, Object> inactiveResponseKeys    = (Map<String, Object>) inactiveQueryResponse.get('QueryResponse');
        accounts.addAll((List<Object>) inactiveResponseKeys.get('Account'));

        for (Object account : accounts){
            Map<String,Object> details = (Map<String,Object>) account;
            if (!(Boolean)details.get('SubAccount')){
                parentKeyMap.put((String)details.get('Id'),(String)details.get('Name'));
                String classification = details.containsKey('Classification') ?
                        (String)details.get('Classification') :
                        (String)details.get('Name');

                parentTypeMap.put((String)details.get('Id'),classification);

                List<String> parentDetails = new List<String>{(String)details.get('Name'), classification};
                childToParent.put((String)details.get('Name'),parentDetails);
            }
        }

        for (Object account : accounts){
            Map<String,Object> details = (Map<String,Object>) account;

            System.debug(details.get('SubAccount'));

            if ((Boolean)details.get('SubAccount')){

                Map<String,Object> parentObj    = (Map<String,Object>)details.get('ParentRef');
                String parentId                 = (String)parentObj.get('value');
                List<String> parentDetails      = new List<String>();
                String name                     = (String)details.get('Name');

                if (name == 'Gross Salaries' ||
                        name == 'Employers National Insurance' ||
                        name == 'Pension Costs' ||
                        name == 'Freelancers'){
                    parentDetails.add(name);
                } else {
                    parentDetails.add(parentKeyMap.get(parentId));
                }

                parentDetails.add(parentTypeMap.get(parentId));
                System.debug('a parent of ' + parentTypeMap.get(parentId));

                childToParent.put((String)details.get('Name'),parentDetails);
            }
        }

        return childToParent;

    }

    private static String getCategory(String name){

        if (name == 'Gross Salaries' ||
                name == 'Employers National Insurance' ||
                name == 'Pension Costs'  ){
            return 'Payroll';
        } else if (name == 'Freelancers'||
                name == 'Revenue'){
            return name;
        } else {
            return 'Payment run';
        }

    }
}