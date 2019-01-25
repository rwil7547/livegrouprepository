/**
 * Created by Ronan Williams on 20/11/2018.
 */

public class CreditCardExportController {

    @RemoteAction
    public static List<CreditCardReport__c> parseCSVString(String csvString){

        Set<String> reportIds               = new Set<String>();

        // get current map of employee emails from HR system
        Map<String,String> employeeIdMap    = getEmployeeIdMap();
        Map<String,List<CreditCardLine__c>> linesByPerson = new Map<String,List<CreditCardLine__c>>();

        String[] reportRows = csvString.split('\n');

        for (Integer i = 1; i < reportRows.size(); i++){

            system.debug(reportRows[i]);

            String[] colValues = reportRows[i].split(',');

            if (colValues[0] != 'ACC.LAST NAME' && colValues[0] != ''){

                String idKey = colValues[0].substring(0,1) + colValues[1];

                String employeeId = employeeIdMap.containsKey(idKey) ?
                        employeeIdMap.get(idKey) : employeeIdMap.get(colValues[1]);

                if (!linesByPerson.containsKey(employeeId)){
                    linesByPerson.put(employeeId, new List<CreditCardLine__c>());
                }

                String currencyString = (colValues[6] != 'GBP') ?
                        '- ' + Decimal.valueOf(colValues[4]) + ' ' + colValues[6] + ' - ' : ' ';

                String merchant = colValues[2].escapeEcmaScript().replaceAll('[\\\\/&@?]','');

                String cityString = (colValues[5].length() > 0 && !colValues[5].substring(0,1).isNumeric()) ?
                        colValues[5].escapeEcmaScript().replaceAll('[\\\\/&@?]','') : '';

                String[] dateVals = colValues[7].split('/');
                Date dateVal = Date.newInstance(Integer.valueOf(dateVals[2]),Integer.valueOf(dateVals[1]),Integer.valueOf(dateVals[0]));

                linesByPerson.get(employeeId).add(
                        new CreditCardLine__c(
                            Amount__c   = Decimal.valueOf(colValues[3]),
                            Merchant__c = merchant + ' ' + currencyString + ' ' + cityString,
                            TransactionDate__c = dateVal
                ));
            }
        }

        for (String employeeString : linesByPerson.keySet()){

            CreditCardReport__c report = new CreditCardReport__c(
                    Employee__c = employeeString,
                    Date__c     = Date.today().toStartOfMonth().addDays(25)
            );

            insert report;
            reportIds.add(report.Id);

            for (CreditCardLine__c line : linesByPerson.get(employeeString)){
                line.CreditCardReport__c = report.Id;
            }

            insert linesByPerson.get(employeeString);
        }

        return [SELECT Id, TotalAmount__c, Employee__r.FirstName__c, Employee__r.LastName__c,
                        ExpensifyId__c, Employee__r.Email__c, Date__c,
                        (SELECT Id, Merchant__c, Amount__c, TransactionDate__c, Comment__c
                        FROM CreditCardLines__r
                        ORDER BY TransactionDate__c ASC)
                FROM CreditCardReport__c WHERE Id IN :reportIds];

    }

    @RemoteAction
    public static String postReport(String Id){

        CreditCardReport__c report = [SELECT Id, TotalAmount__c, Employee__r.FirstName__c, Employee__r.LastName__c,
                                            ExpensifyId__c, Employee__r.Email__c, Employee__r.ExpensifyUserID__c,
                                            Employee__r.ExpensifyUserSecret__c, Date__c,
                                    (SELECT Id, Merchant__c, Amount__c, TransactionDate__c, Comment__c
                                    FROM CreditCardLines__r
                                    ORDER BY TransactionDate__c ASC)
                                    FROM CreditCardReport__c WHERE Id = :Id];

        HttpResponse response = calloutExpensify(report);
        String responseString = '';

        if (response.getStatus() != 'OK'){
            responseString = 'ERROR CONNNECTING TO EXPENSIFY';
        } else {
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());

            if (responseMap.containsKey('reportID')){
                responseString = (String)responseMap.get('reportID');
                System.debug(responseString);
                report.ExpensifyId__c = responseString;
                update report;
            } else {
                System.debug((String)responseMap.get('responseMessage'));
                responseString = 'NO ID RETURNED';
            }

        }

        return responseString;

    }


    private static Map<String,String> getEmployeeIdMap(){

        Map<String,String> employeeEmailMap = new Map<String,String>();

        for (Employee1__c employee : [SELECT FirstName__c, LastName__c, Id
                                      FROM Employee1__c]){
            employeeEmailMap.put(employee.FirstName__c.substring(0,1).toUpperCase() +
                                 employee.LastName__c.toUpperCase(), employee.Id);
            employeeEmailMap.put(employee.LastName__c.toUpperCase(), employee.Id);
        }

        return employeeEmailMap;
    }

    private static HttpResponse calloutExpensify(CreditCardReport__c report){

        String lineItems = '';

        for (Integer x = 0; x < report.CreditCardLines__r.size(); x++){

            Integer year        = report.CreditCardLines__r[x].TransactionDate__c.year();
            Integer monthInt    = report.CreditCardLines__r[x].TransactionDate__c.month();
            String month        = (monthInt < 10) ? '0' + String.valueOf(monthInt) : String.valueOf(monthInt);
            Integer dayInt      = report.CreditCardLines__r[x].TransactionDate__c.day();
            String day          = (dayInt < 10) ? '0' + String.valueOf(dayInt) : String.valueOf(dayInt);
            Integer amount      = Integer.valueOf(report.CreditCardLines__r[x].Amount__c.setScale(2) * 100);

            lineItems += '{' +
                    '   "date": "' + year + '-' + month + '-' + day + '",' +
                    '   "currency": "GBP",' +
                    '   "merchant": "' + report.CreditCardLines__r[x].Merchant__c.replace('%','') + '",' +
                    '   "amount": ' + amount + ',' +
                    '   "reimbursable": false' +
                    '   }';
            if ((x + 1) < report.CreditCardLines__r.size()) {
                lineItems += ',';
            }
        }

        String requestBody = 'requestJobDescription={' +
                '"type": "create",'+
                '"credentials": {'+
                    '"partnerUserID": "' + report.Employee__r.ExpensifyUserID__c + '",'+
                    '"partnerUserSecret":  "' + report.Employee__r.ExpensifyUserSecret__c + '"'+
                '},'+
                '"inputSettings": {'+
                '"type": "report",'+
                '"policyID": "3EDF75FF21209A89",'+
                '"report": {'+
                '"title": "CC Statement ' +
                    report.Employee__r.FirstName__c.substring(0,1) + '. ' + report.Employee__r.LastName__c + ' ' +
                    Datetime.newInstance(report.Date__c.year(),report.Date__c.month(),report.Date__c.day()).format('dd/MM/yyyy') + ' ",'+
                '"fields":{'+
                    '"Barclaycard_Statement_Amount" : ' + report.TotalAmount__c +
                    '}'+
                '},'+
                '"employeeEmail": "' + report.Employee__r.Email__c + '",'+
                '"expenses": ['+
                            lineItems +
                        ']'+
                    '}'+
                '}';

        Http Http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://integrations.expensify.com/Integration-Server/ExpensifyIntegrations');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setBody(requestBody);
        HttpResponse res = Http.send(req);

        System.debug(res.getStatus() + ' ' + res.getBody());

        return res;

    }
}