/**
 * Created by Ronan Williams on 02/10/2018.
 */

public class QuickbooksProfitAndLossCallout {

    public static HttpRequest buildCallout(String query) {

        // build callout parameters
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/' + query);
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);

        return request;
    }

    @future(callout=true)
    public static void getProfitAndLoss() {

        // setup callout month params
        List<Date> calloutDates = new List<Date>();

        Date initial = Date.today().addMonths(-6).toStartOfMonth();

        // get list of QBProfitAndLoss__c entries
        Map<String,QBProfitAndLoss__c> qbpnlMap = new Map<String,QBProfitAndLoss__c>();

        for (QBProfitAndLoss__c qb : [SELECT Id, Month__c, Nominal__c, QBUpdated__c,
                                            Parent__c, Actual__c, Budget__c
                                    FROM QBProfitAndLoss__c
                                    WHERE Month__c >= :initial
                                    AND Month__c <= :Date.today().toStartOfMonth()]){

            qbpnlMap.put(String.valueOf(qb.Month__c) + qb.Nominal__c, qb);

            System.debug(String.valueOf(qb.Month__c) + qb.Nominal__c + ' ' + qb.Parent__c);
        }

        // set furthest fallback to April 2018
        if (initial < Date.newInstance(2018, 04, 01)) {
            initial = Date.newInstance(2018, 04, 01);
        }

        while (initial < Date.today().toStartOfMonth()) {
            calloutDates.add(initial);
            initial = initial.addMonths(1);
        }

        // delcare list of entries to update
        List<QBProfitAndLoss__c> entriesToUpsert = new List<QBProfitAndLoss__c>();
        List<QBProfitAndLoss__c> entriesToDelete = new List<QBProfitAndLoss__c>();
        Set<String> exsitingEntries              = new Set<String>();

        // generate query for each month
        for (Date calloutDate : calloutDates) {

            String start = calloutDate.year() + '-' + calloutDate.month() + '-' + calloutDate.day();
            Date endDate = calloutDate.addMonths(1).addDays(-1);
            String endD = endDate.year() + '-' + endDate.month() + '-' + endDate.day();

            String query = '/reports/ProfitAndLoss?start_date=' + start + '&end_date=' + endD;

            Http http = new http();
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

                                        exsitingEntries.add(String.valueOf(calloutDate) + row3.ColData[0].value);

                                        if (qbpnlMap.containsKey(String.valueOf(calloutDate) + row3.ColData[0].value)) {

                                            QBProfitAndLoss__c qbp = qbpnlMap.get(String.valueOf(calloutDate) + row3.ColData[0].value);

                                            if (!qbp.QBUpdated__c || (Decimal.valueOf(row3.ColData[1].value) != qbp.Actual__c) ||
                                                    qbp.Parent__c != parent) {
                                                if (Decimal.valueOf(row3.ColData[1].value) != qbp.Actual__c) {
                                                    qbp.Actual__c = Decimal.valueOf(row3.ColData[1].value);
                                                    qbp.QBUpdated__c = true;
                                                }
                                                if (qbp.Parent__c != parent) {
                                                    qbp.Parent__c = parent;
                                                }
                                                entriesToUpsert.add(qbp);
                                            }
                                        } else {
                                            QBProfitAndLoss__c qbp = new QBProfitAndLoss__c();
                                            qbp.Nominal__c = row3.ColData[0].value;
                                            qbp.Parent__c = parent;
                                            qbp.Actual__c = Decimal.valueOf(row3.ColData[1].value);
                                            qbp.Budget__c = 0;
                                            qbp.Month__c = calloutDate;
                                            qbp.QBUpdated__c = true;
                                            entriesToUpsert.add(qbp);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        for (QBProfitAndLoss__c qb : qbpnlMap.values()){
            if (!exsitingEntries.contains(String.valueOf(qb.Month__c) + qb.Nominal__c)){
                entriesToDelete.add(qb);
            }
        }


        System.debug('number to be deleted is ' + entriesToDelete.size());

        if(!entriesToUpsert.isEmpty()){
            upsert entriesToUpsert;
        }

        if(!entriesToDelete.isEmpty()){
            delete entriesToDelete;
        }

    }
}