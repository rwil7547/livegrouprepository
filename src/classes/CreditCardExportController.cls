/**
 * Created by Ronan Williams on 20/11/2018.
 */

public class CreditCardExportController {

    @RemoteAction
    public static List<CreditCardReport> parseCSVString(String csvString){

        // get current map of employee emails from HR system
        Map<String,List<CreditCardLine>> linesByPerson2 = new Map<String,List<CreditCardLine>>();
        List<CreditCardReport>  reports         = new List<CreditCardReport> ();
        Map<String,String> employeeIdMap        = getEmployeeIdMap();
        Map<String,Employee1__c> employeeMap    = getEmployeeMap();

        for (String employeeId : employeeIdMap.values()){
            linesByPerson2.put(employeeId, new List<CreditCardLine>());
        }

        String[] reportRows = csvString.split('\n');

        for (Integer i = 1; i < reportRows.size(); i++){

            String[] colValues = reportRows[i].split(',');

            if (colValues[0] != 'ACC.LAST NAME' && colValues[0] != ''){

                for (Integer s = 0; s < colValues.size(); s++){
                    if (colValues[s].length() > 0 && colValues[s].substring(0,1) == '"'){
                        colValues[s] += colValues[s + 1];
                        colValues.remove(s + 1);
                    }
                }

                String idKey        = colValues[0].substring(0,1) + colValues[1];
                String employeeId   = employeeIdMap.containsKey(idKey) ?
                                        employeeIdMap.get(idKey) : employeeIdMap.get(colValues[1]);

                if (!linesByPerson2.containsKey(employeeId)){
                    linesByPerson2.put(employeeId, new List<CreditCardLine>());
                }

                String currencyString   = (colValues[6] != 'GBP') ?
                                            '- ' + Decimal.valueOf(colValues[4]) + ' ' + colValues[6] + ' - ' : ' ';
                String merchant         = colValues[2].escapeEcmaScript().replaceAll('[\\\\/&@?]','');
                String cityString       = (colValues[5].length() > 0 && !colValues[5].substring(0,1).isNumeric()) ?
                                            colValues[5].escapeEcmaScript().replaceAll('[\\\\/&@?]','') : '';
                String[] dateVals       = colValues[7].split('/');
                String yearVal          = dateVals[2];
                Date dateVal            = Date.newInstance(Integer.valueOf(yearVal),Integer.valueOf(dateVals[1]),Integer.valueOf(dateVals[0]));

                CreditCardLine line     = new CreditCardLine();
                line.Amount             = Decimal.valueOf(colValues[3]);
                line.Merchant           = merchant + ' ' + currencyString + ' ' + cityString;
                line.TransactionDate    = String.valueOf(dateVal);
                linesByPerson2.get(employeeId).add(line);

            }
        }

        for (String employeeString : linesByPerson2.keySet()){

            CreditCardReport ccReport   = new CreditCardReport();
            ccReport.Employee           = employeeMap.get(employeeString);
            ccReport.ReportDate         = String.valueOf(Date.today().toStartOfMonth().addDays(25));
            ccReport.CreditCardLines    = new List<CreditCardLine>();
            ccReport.TotalAmount        = 0;

            for (CreditCardLine line : linesByPerson2.get(employeeString)){
                ccReport.CreditCardLines.add(line);
                ccReport.TotalAmount += line.Amount;
            }

            if (!ccReport.CreditCardLines.isEmpty()){
                reports.add(ccReport);
            }
        }

        return reports;
    }

    @RemoteAction
    public static String postReport(CreditCardReport report){

        HttpResponse response = calloutExpensify(report);
        String responseString = '';

        if (response.getStatus() != 'OK'){
            responseString = 'ERROR CONNECTING TO EXPENSIFY';
        } else {
//            System.debug(response.getBody());
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            if (responseMap.containsKey('reportID')){
                responseString = (String)responseMap.get('reportID');
            } else {
//                System.debug((String)responseMap.get('responseMessage'));
                responseString = 'NO ID RETURNED: ' + response.getStatus();
            }
        }

        return responseString;
    }


    private static Map<String,String> getEmployeeIdMap(){

        Map<String,String> employeeEmailMap = new Map<String,String>();
        for (Employee1__c employee : [SELECT FirstName__c, LastName__c, Id
                                      FROM Employee1__c
                                      WHERE PeopleHRId__c != NULL ]){
            employeeEmailMap.put(employee.FirstName__c.substring(0,1).toUpperCase() +
                                 employee.LastName__c.toUpperCase(), employee.Id);
            employeeEmailMap.put(employee.LastName__c.toUpperCase(), employee.Id);
        }

        return employeeEmailMap;
    }

    private static Map<String,Employee1__c> getEmployeeMap(){

        Map<String,Employee1__c> employeeMap = new Map<String,Employee1__c>();
        for (Employee1__c employee : [SELECT FirstName__c, LastName__c, Id, Email__c,
                                            ExpensifyUserSecret__c, ExpensifyUserID__c
                                        FROM Employee1__c
                                        WHERE PeopleHRId__c != NULL]){
            employeeMap.put(employee.Id, employee);
        }

        return employeeMap;
    }

    private static HttpResponse calloutExpensify(CreditCardReport report){

        String lineItems = '';

        for (Integer x = 0; x < report.CreditCardLines.size(); x++){

            Integer year        = Date.valueOf(report.CreditCardLines[x].TransactionDate).year();
            Integer monthInt    = Date.valueOf(report.CreditCardLines[x].TransactionDate).month();
            String month        = (monthInt < 10) ? '0' + String.valueOf(monthInt) : String.valueOf(monthInt);
            Integer dayInt      = Date.valueOf(report.CreditCardLines[x].TransactionDate).day();
            String day          = (dayInt < 10) ? '0' + String.valueOf(dayInt) : String.valueOf(dayInt);
            Integer amount      = Integer.valueOf(report.CreditCardLines[x].Amount.setScale(2) * 100);

            lineItems += '{' +
                    '   "date": "' + year + '-' + month + '-' + day + '",' +
                    '   "currency": "GBP",' +
                    '   "merchant": "' + report.CreditCardLines[x].Merchant.replace('%','') + '",' +
                    '   "amount": ' + amount + ',' +
                    '   "reimbursable": false' +
                    '   }';
            if ((x + 1) < report.CreditCardLines.size()) {
                lineItems += ',';
            }
        }

        Date reportDate = Date.valueOf(report.ReportDate);

        String requestBody = 'requestJobDescription={' +
                '"type": "create",'+
                '"credentials": {'+
                '   "partnerUserID": "' + report.Employee.ExpensifyUserID__c + '",'+
                '   "partnerUserSecret":  "' + report.Employee.ExpensifyUserSecret__c + '"'+
                '},'+
                '"inputSettings": {'+
                '   "type": "report",'+
                '   "policyID": "3EDF75FF21209A89",'+
                '   "report": {'+
                '       "title": "CC Statement ' +
                        report.Employee.FirstName__c.substring(0,1) + '. ' + report.Employee.LastName__c + ' ' +
                        Datetime.newInstance(reportDate.year(),reportDate.month(),reportDate.day()).format('dd/MM/yyyy') + ' ",'+
                '       "fields":{'+
                '           "Barclaycard_Statement_Amount" : ' + report.TotalAmount +
                '       }'+
                '   },'+
                '   "employeeEmail": "' + report.Employee.Email__c + '",'+
                '   "expenses": ['+
                        lineItems +
                '   ]'+
                '   }'+
                '}';

        Http Http       = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://integrations.expensify.com/Integration-Server/ExpensifyIntegrations');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setBody(requestBody);
        HttpResponse res = Http.send(req);

        return res;
    }

    public class CreditCardLine{
        Decimal Amount;
        String Merchant;
        String TransactionDate;
    }

    public class CreditCardReport {
        Decimal TotalAmount;
        Employee1__c Employee;
        String ReportDate;
        List<CreditCardLine> CreditCardLines;
        Boolean Valid;
        String ErrorMessage;
    }

}