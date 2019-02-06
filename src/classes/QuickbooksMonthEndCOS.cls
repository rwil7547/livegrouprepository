/**
 * Created by Ronan Williams on 14/11/2018.
 */

public class QuickbooksMonthEndCOS {

    public static void calculateCOSJournal(Date closeMonth, Set<String> accrualIds, Set<String> deferralIds) {

        // establish what the end figures need to be
        Decimal salesforceCOS = getTotalSalesforceFigures(closeMonth);

        // delcare values to store total figures
        Decimal monthTotalCOS   = 0;
        Decimal pnlCOSDebit     = 0;
        Decimal pnlCOSCredit    = 0;

        // boolean check that all callouts have been successful
        Boolean billsCallout                = false;
        Boolean vendorCreditCallout         = false;
        Boolean billsAccrualsCallout        = false;
        Boolean vendorCreditAccrualsCallout = false;
        Boolean journalWIPCallout           = false;
        Boolean journalAccrualCallout       = false;

        // generate date string params to be used in Quickbooks callout
        String monthStart   = String.valueOf(closeMonth.addDays(-1)).substring(0, 10);
        String monthEnd     = String.valueOf(closeMonth.addMonths(1).toStartOfMonth()).substring(0, 10);
        String lastDayOfPriorMonth = String.valueOf(closeMonth.addMonths(1).toStartOfMonth().addDays(-1)).substring(0, 10);

        // establish lists of journals to be created
        List<JSONParserQBOBillFlow.cls_Line> billLinesToDefer                   = new List<JSONParserQBOBillFlow.cls_Line>();
        List<JSONParserQBOVendorCreditFlow.cls_Line> vendorCreditLinesToDefer   = new List<JSONParserQBOVendorCreditFlow.cls_Line>();
        List<JSONParserQBOBillFlow.cls_Line> billAccrualsToCredit               = new List<JSONParserQBOBillFlow.cls_Line>();
        List<JSONParserQBOVendorCreditFlow.cls_Line> vendorCreditLinesToAccrue   = new List<JSONParserQBOVendorCreditFlow.cls_Line>();
        List<JSONParserQBOJournalFlow.cls_Line> journalsToDefer                 = new List<JSONParserQBOJournalFlow.cls_Line>();
        List<Opportunity> opportunitiesToAccrue                                 = new List<Opportunity>();
        List<Adjustment__c> adjustmentsToAccrue                                 = new List<Adjustment__c>();
        Map<Id,Decimal> adjustmentValueMap                                      = new Map<Id,Decimal>();

        // get set of invoices and job numbers in the future, used to determine if entries
        // need to be deferred
        Map<String, List<Object>> futureIds = getIds(true, closeMonth);
        Map<String, List<Object>> pastIds = getIds(false, closeMonth);

        Map<String,Decimal> amountsOnPNL = new Map<String,Decimal>();

        for (String jobNo : pastIds.keySet()){
            amountsOnPNL.put(jobNo, 0);
//            system.debug('past id is ' + jobNo);
        }

        // 1. BILLS: callout to Quickbooks to retrieve any bill entries siting in the prior month
        String query1 = 'query?query=select%20%2a%20from%20bill%20where%20TxnDate%20%3e%20%27' +
                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27%20maxResults%201000&minorversion=4';

        Http http1 = new Http();
        HttpRequest request1 = buildCallout(query1);
        HttpResponse response1 = http1.send(request1);

        if (response1.getStatusCode() == 200) {
            billsCallout = true;
            Map<String, Object> processedBillLines =
                    processBills(futureIds.keySet(), JSONParserQBOBillFlow.parse(response1.getBody()),amountsOnPNL);

            Object responseObj = JSON.deserializeUntyped(response1.getBody());
            Map<String,Object> responseMap = (Map<String,Object>)responseObj;
            Map<String,Object> queryMap = (Map<String,Object>)responseMap.get('QueryResponse');
            List<Object> bills = (List<Object>)queryMap.get('Bill');

            system.debug('response object is ' + JSON.deserializeUntyped(response1.getBody()));
            system.debug('size is ' + bills.size());

            monthTotalCOS   += (Decimal) processedBillLines.get('Total');
            pnlCOSCredit    += (Decimal) processedBillLines.get('Credit');
            amountsOnPNL    =  (Map<String,Decimal>) processedBillLines.get('amountsOnPNL');

            billLinesToDefer.addAll((List<JSONParserQBOBillFlow.cls_Line>) processedBillLines.get('BillLines'));
        }

        // 2. VENDOR CREDIT: callout to Quickbooks to retrieve any vendor credit note entries siting in the prior month
        String query2 = 'query?query=select%20%2a%20from%20VendorCredit%20where%20TxnDate%20%3e%20%27' +
                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27&minorversion=4';

        Http http2 = new Http();
        HttpRequest request2 = buildCallout(query2);
        HttpResponse response2 = http2.send(request2);

        if (response2.getStatusCode() == 200) {
            vendorCreditCallout = true;
            Map<String, Object> processedVendorCreditLines =
                    processVendorCredits(futureIds.keySet(), JSONParserQBOVendorCreditFlow.parse(response2.getBody()),amountsOnPNL);

            monthTotalCOS   += (Decimal) processedVendorCreditLines.get('Total');
            pnlCOSDebit     += (Decimal) processedVendorCreditLines.get('Debit');
            amountsOnPNL    =  (Map<String,Decimal>) processedVendorCreditLines.get('amountsOnPNL');

            vendorCreditLinesToDefer.addAll((List<JSONParserQBOVendorCreditFlow.cls_Line>) processedVendorCreditLines.get('CreditLines'));
        }

        // 3. JOURNALS: callout Quickbooks to retrieve reversed journals from the month prior
        // the two types of journals are accruals reversal and work in progress reversal
        // todo: ensure this picks up the journal from the prior month except for in the first execution instance
//        Set<String> journalIds  = new Set<String>{'23364', '23363'};
        Set<String> accrualsIds = new Set<String>();

        Map<String, String> journalTypeMap = new Map<String, String>();
//        {
//                '23364' => 'WIP',
//                '23363' => 'Accrual'
//        };

        for (String deferral : deferralIds){
            journalTypeMap.put(deferral, 'WIP');
        }

        for (String accrual : accrualIds){
            journalTypeMap.put(accrual, 'Accrual');
        }

        for (String journalId : journalTypeMap.keySet()) {

            String query3 = 'query?query=select%20%2a%20from%20journalentry%20where%20Id%20%3d%20%27' + journalId + '%27&minorversion=4';

            // do callout
            Http http3 = new Http();
            HttpRequest request3 = buildCallout(query3);
            HttpResponse response3 = http3.send(request3);

            if (response3.getStatusCode() == 200) {

                // mark the correct journal type callout as correct
                if (journalTypeMap.get(journalId) == 'WIP') {
                    journalWIPCallout = true;
                } else if (journalTypeMap.get(journalId) == 'Accrual') {
                    journalAccrualCallout = true;
                }

                Map<String, Object> processedJournals =
                        processJournals(futureIds.keySet(), JSONParserQBOJournalFlow.parse(response3.getBody()),journalTypeMap.get(journalId),amountsOnPNL);

                monthTotalCOS   += (Decimal) processedJournals.get('Total');
                pnlCOSDebit     += (Decimal) processedJournals.get('pnlDebit');
                pnlCOSCredit    += (Decimal) processedJournals.get('pnlCredit');
                amountsOnPNL    =  (Map<String,Decimal>) processedJournals.get('amountsOnPNL');

                journalsToDefer.addAll((List<JSONParserQBOJournalFlow.cls_Line>) processedJournals.get('Journals'));
                accrualsIds.addAll((Set<String>) processedJournals.get('AccrualIds'));
            }
        }

        for (String s : amountsOnPNL.keySet()){
            System.debug('pnl key is ' + s + ' and value is ' + amountsOnPNL.get(s));
        }


        // 4. BILLS ACCRUAL: callout to Quickbooks to retrieve any bill entries siting in the current month
        // which are for the prior month and do not already have a journal associated with them
        String query4 = 'query?query=select%20%2a%20from%20bill%20where%20TxnDate%20%3e%20%27' +
                lastDayOfPriorMonth + '%27&minorversion=4';

        Http http4              = new Http();
        HttpRequest request4    = buildCallout(query4);
        HttpResponse response4  = http4.send(request4);

        if (response4.getStatusCode() == 200) {
            billsAccrualsCallout = true;
            Map<String, Object> processedAccruals =
                    processAccruals(accrualsIds, pastIds.keySet(), JSONParserQBOBillFlow.parse(response4.getBody()),amountsOnPNL);

            pnlCOSDebit        += (Decimal)processedAccruals.get('Debit');
            amountsOnPNL       =  (Map<String,Decimal>) processedAccruals.get('amountsOnPNL');

            billAccrualsToCredit.addAll((List<JSONParserQBOBillFlow.cls_Line>) processedAccruals.get('BillLines'));
        }

        // 5. VENDOR CREDITS TO ACCRUE: callout to Quickbooks to retrieve any vendor credit note entries siting in the current month
        // which are for the prior month and do not already have a journal associated with them
        String query5 = 'query?query=select%20%2a%20from%20VendorCredit%20where%20TxnDate%20%3e%20%27' +
                lastDayOfPriorMonth + '%27&minorversion=4';
        Http http5 = new Http();
        HttpRequest request5 = buildCallout(query5);
        HttpResponse response5 = http5.send(request5);

        if (response5.getStatusCode() == 200) {
            vendorCreditAccrualsCallout = true;
            Map<String, Object> processedVendorCreditLines =
                    processCreditAccruals(futureIds.keySet(),  pastIds.keySet(), JSONParserQBOVendorCreditFlow.parse(response5.getBody()),amountsOnPNL);

            pnlCOSCredit    += (Decimal)processedVendorCreditLines.get('Credit');
            amountsOnPNL    =  (Map<String,Decimal>) processedVendorCreditLines.get('amountsOnPNL');

            vendorCreditLinesToAccrue.addAll((List<JSONParserQBOVendorCreditFlow.cls_Line>) processedVendorCreditLines.get('VendorCreditLines'));
        }

        // 6. OPPORTUNITIES: determine if some opportunities from the prior month or earlier are still not fully invoiced

        // begin by adjusting all Opportunities
//        SalesDashboardUtils.adjustOpportunities();

        for (Opportunity opp : [SELECT Id, Filtered_Job_Number__c, Name, QuickbooksClassId__c,
                                        COSRemaining__c, Event_end__c,
                                        (SELECT Id, CostOfSale__c FROM Adjustments__r
                                        WHERE Month__c > :closeMonth.addMonths(1).toStartOfMonth().addDays(-1)
                                        AND (CostOfSale__c < -0.1 OR CostOfSale__c > 0.1))
                                FROM Opportunity
                                WHERE Event_end__c <= :closeMonth.addMonths(1).toStartOfMonth().addDays(-1)
                                AND Event_end__c >= :Date.newInstance(2018,04,01)
                                AND StageName = 'Closed Won'
                                AND COSRemaining__c > 0]){

            Decimal cosToAccrue = opp.COSRemaining__c;

            for (Adjustment__c adj : opp.Adjustments__r){
                if (adj.CostOfSale__c < 0){
                    cosToAccrue += (adj.CostOfSale__c * -1);
                } else {
                    cosToAccrue -= adj.CostOfSale__c;
                }
            }

            opp.Forecast_COS__c = cosToAccrue;

            opportunitiesToAccrue.add(opp);
//            pnlCOSDebit += opp.COSRemaining__c;
            pnlCOSDebit += cosToAccrue;
        }

//
//        Map<String, Decimal> expenseOffsetMap = new Map<String,Decimal>();
//
//        for (Expense__c ex : [SELECT Id, Opportunity__r.Filtered_Job_Number__c, Amount__c
//                                FROM Expense__c
////                                WHERE CreatedDate >= :Date.today().toStartOfMonth().addDays(1)
//                                WHERE CreatedDate >= :closeMonth.addMonths(1).toStartOfMonth()
//                                AND Opportunity__r.Filtered_Job_Number__c
//                                IN :pastIds.keySet()]){
//
//            if (expenseOffsetMap.containsKey(ex.Opportunity__r.Filtered_Job_Number__c)){
//                expenseOffsetMap.put(ex.Opportunity__r.Filtered_Job_Number__c, expenseOffsetMap.get(ex.Opportunity__r.Filtered_Job_Number__c) + ex.Amount__c);
//            } else {
//                expenseOffsetMap.put(ex.Opportunity__r.Filtered_Job_Number__c, ex.Amount__c);
//            }
//        }
//
//
//        // 7. OPPORTUNITY ADJUSTMENTS
//        for (Adjustment__c adjustment : [SELECT Id, CostOfSale__c, Opportunity__r.Name, Opportunity__r.QuickbooksClassId__c,
//                                                Opportunity__r.Filtered_Job_Number__c, Opportunity__r.SBQQ__PrimaryQuote__r.Amount_Calder__c,
//                                                Opportunity__r.Filtered_Cost_of_Sale__c, Opportunity__r.Quote_Status__c, Opportunity__r.Quickbooks_COS__c,
//                                                Opportunity__r.CommittedCOS__c
//                                        FROM Adjustment__c
//                                        WHERE Month__c > :closeMonth.addMonths(1).toStartOfMonth().addDays(-1)
//                                        AND Opportunity__r.Event_end__c <= :closeMonth.addMonths(1).toStartOfMonth().addDays(-1)
//                                        AND (CostOfSale__c < -0.1 OR CostOfSale__c > 0.1)]){
//            adjustmentsToAccrue.add(adjustment);
//
//            if (expenseOffsetMap.containsKey(adjustment.Opportunity__r.Filtered_Job_Number__c)){
////                        pnlCOSCredit += (expenseOffsetMap.get(adjustment.Opportunity__r.Filtered_Job_Number__c));
//
//                pnlCOSDebit += (expenseOffsetMap.get(adjustment.Opportunity__r.Filtered_Job_Number__c));
//                adjustmentValueMap.put(adjustment.Id,(expenseOffsetMap.get(adjustment.Opportunity__r.Filtered_Job_Number__c)));
//            } else {
//                if (adjustment.CostOfSale__c < 0) {
////                    pnlCOSCredit += (adjustment.CostOfSale__c);
////                    pnlCOSCredit += (adjustment.CostOfSale__c * -1);
//                    pnlCOSDebit += (adjustment.CostOfSale__c * -1);
//                } else {
////                    pnlCOSDebit += (adjustment.CostOfSale__c);
//                    pnlCOSCredit += (adjustment.CostOfSale__c);
////                    pnlCOSDebit += (adjustment.CostOfSale__c);
//                }
//
//                adjustmentValueMap.put(adjustment.Id, adjustment.CostOfSale__c);
//            }
//        }


        // 8. DETERMINE BALANCES ARE ACCURATE
        // create salesforce entries for each journal to post if all callouts were successful
        // and the total figures are in agreement with the Salesforce figures
        if (billsCallout && vendorCreditCallout && vendorCreditCallout && vendorCreditCallout && journalWIPCallout && journalAccrualCallout) {
            // if there is less than £1 discrepancy
//            Decimal pnlValue = (monthTotalCOS + pnlCOSDebit - pnlCOSCredit);

//                if (pnlValue <= (salesforceCOS + 0.5) &&  pnlValue >= (salesforceCOS - 0.5)){


            // check for any prior journal calculations for the relevant period which have not yet been exported to Quickbooks
            List<QBJournal__c> priorJournals = [SELECT Id FROM QBJournal__c WHERE TxnDate__c = :closeMonth
                                                AND Target__c = '5000 Cost of sales' AND QuickbooksId__c = NULL];

            // delete any prior journal entries found
            if (!priorJournals.isEmpty()) {
                delete priorJournals;
            }


                System.debug('SUCCESS!');
                createQBJournalEntries(billLinesToDefer, vendorCreditLinesToDefer, billAccrualsToCredit, vendorCreditLinesToAccrue,
                        journalsToDefer, opportunitiesToAccrue, adjustmentsToAccrue, adjustmentValueMap, futureIds, pastIds);


//                    List<JSONParserQBOBillFlow.cls_Line> bills,
//                            List<JSONParserQBOVendorCreditFlow.cls_Line> vendorCredits,
//                    List<JSONParserQBOBillFlow.cls_Line> billAccruals,
//                    List<JSONParserQBOVendorCreditFlow.cls_Line> vendorCreditAccruals,
//                    List<JSONParserQBOJournalFlow.cls_Line> journals,
//                            List<Opportunity> opportunities,
//                            List<Adjustment__c> adjustments,
//                    Map<String,Decimal> adjustmentValueMap,
//                            Map<String,List<Object>> futureIds,
//                            Map<String,List<Object>> pastIds){



//                } else {
                System.debug('amounts didnt add up: total cos in SF: ' + salesforceCOS);
                System.debug('total pnl: ' + monthTotalCOS);
                System.debug('total debit: ' + pnlCOSDebit);
                System.debug('total credit: ' + pnlCOSCredit);
                System.debug('total finished figure: ' + (monthTotalCOS -  pnlCOSCredit +  pnlCOSDebit));
                System.debug('total discrepancy is : ' + (salesforceCOS - (monthTotalCOS -  pnlCOSCredit +  pnlCOSDebit)));
//                }
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');
                System.debug('');

        }
    }


    private static Decimal getTotalSalesforceFigures(Date closeMonth) {

        List<AggregateResult> oppFigures = [SELECT SUM(CommittedCOS__c) cos
                                            FROM Opportunity
                                            WHERE Event_end__c >= :closeMonth
                                            AND Event_end__c < :closeMonth.addMonths(1).toStartOfMonth()];

        List<AggregateResult> adjustmentFigures = [SELECT SUM(CostOfSale__c) cos
                                            FROM Adjustment__c
                                            WHERE Month__c >= :closeMonth
                                            AND Month__c < :closeMonth.addMonths(1).toStartOfMonth()];

        Decimal totalOppCOS = ((Decimal) oppFigures[0].get('cos') != null) ?
                (Decimal) oppFigures[0].get('cos') : 0;
        Decimal totalAdjCOS = ((Decimal) adjustmentFigures[0].get('cos') != null) ?
                (Decimal) adjustmentFigures[0].get('cos') : 0;

        return totalOppCOS + totalAdjCOS;
    }

    private static HttpRequest buildCallout(String query) {

        // build callout parameters
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/' + query);
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);

        return request;
    }

    private static Map<String, List<Object>> getIds(Boolean future, Date closeMonth) {

        Date startDate  = (future) ?  closeMonth.addMonths(1).toStartOfMonth() : closeMonth.addMonths(-6);
        Date endDate    = (future) ?  closeMonth.addYears(3) : closeMonth.addMonths(1).toStartOfMonth().addDays(-1);

        Map<String, List<Object>> idMap = new Map<String, List<Object>>();

        for (Opportunity opp : [SELECT Filtered_Job_Number__c, Name, QuickbooksClassId__c
                                FROM Opportunity
                                WHERE StageName = 'Closed Won'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]) {
            List<Object> oppDetails = new List<Object>{
                    opp.Filtered_Job_Number__c,
                    opp.Name,
                    opp.QuickbooksClassId__c
            };

            idMap.put(String.valueOf(opp.QuickbooksClassId__c), oppDetails);
            idMap.put(opp.Filtered_Job_Number__c, oppDetails);
        }

        return idMap;
    }

    private static Map<String, Object> processBills(Set<String> futureIds, JSONParserQBOBillFlow parsedResults,
            Map<String,Decimal> amountsOnPNL) {

        Integer billCount = 0;

        Decimal billsTotal = 0;
        Decimal pnlCredit = 0;
        List<JSONParserQBOBillFlow.cls_Line> billsLinesToDefer = new List<JSONParserQBOBillFlow.cls_Line>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Bill != null) {
            for (JSONParserQBOBillFlow.cls_Bill bill : parsedResults.QueryResponse.Bill) {

                //  iterate through bill lines
                for (JSONParserQBOBillFlow.cls_Line line : bill.Line) {



                    if (line.AccountBasedExpenseLineDetail.AccountRef.value == '646'){

                        // throw error if the bill line is missing a class ref
                        if (line.AccountBasedExpenseLineDetail.ClassRef == null){
                            throw new MissingQBClassException('Bill line found which is missing a class: ' + bill.Id + ' ' + line);
                        } else {
                            // add the line amount to the total
                            billsTotal += line.Amount;
                            System.debug(line.Description);
                            System.debug('class ref found in map is ' + (amountsOnPNL.containsKey(line.AccountBasedExpenseLineDetail.ClassRef.name)));
                            billCount++;
                        }
                    }

                    // check that the bill line has been posted to 5000 Cost of sales:Events COS
                    if (line.AccountBasedExpenseLineDetail.ClassRef != null && line.AccountBasedExpenseLineDetail.AccountRef.value == '646') {
                        // if the class Id or name can be used to identify that the bill line is for a future month it needs
                        // to be deferred

                        if (futureIds.contains(line.AccountBasedExpenseLineDetail.ClassRef.value) ||
                                futureIds.contains((line.AccountBasedExpenseLineDetail.ClassRef.name).substring(0, 5))) {
                            billsLinesToDefer.add(line);
                            pnlCredit += line.Amount;
                        } else {
//                            amountsOnPNL.put(line.AccountBasedExpenseLineDetail.ClassRef.value,
//                                amountsOnPNL.get(line.AccountBasedExpenseLineDetail.ClassRef.value) + line.Amount);
                        }
                    }
                }
            }
        }

        Map<String, Object> processedResults = new Map<String, Object>();
        processedResults.put('Total', billsTotal);
        processedResults.put('Credit', pnlCredit);
        processedResults.put('BillLines', billsLinesToDefer);
        processedResults.put('amountsOnPNL', amountsOnPNL);

        System.debug('total bills is ' + billCount + ' and bills total is £' + billsTotal);

        return processedResults;
    }

    private static Map<String, Object> processVendorCredits(Set<String> futureIds, JSONParserQBOVendorCreditFlow parsedResults,
            Map<String,Decimal> amountsOnPNL) {

        Integer creditCount = 0;
        Decimal billsTotal  = 0;
        Decimal pnlDebit    = 0;
        List<JSONParserQBOVendorCreditFlow.cls_Line> creditLinesToDefer = new List<JSONParserQBOVendorCreditFlow.cls_Line>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.VendorCredit != null) {
            for (JSONParserQBOVendorCreditFlow.cls_VendorCredit vendorCredit : parsedResults.QueryResponse.VendorCredit) {

                //  iterate through vendor credit lines
                for (JSONParserQBOVendorCreditFlow.cls_Line line : vendorCredit.Line) {

                    // check that the vendor credit line has been posted to 5000 Cost of sales:Events COS
                    if (line.AccountBasedExpenseLineDetail.AccountRef.value == '646') {

                        // check that the line has a class associated with it
                        if (line.AccountBasedExpenseLineDetail.ClassRef == null){
                            throw new MissingQBClassException('Vendor credit line found which is missing a class: ' + vendorCredit.Id + ' ' +  + line);
                        } else {
                            // add the line amount to the total

                            System.debug('found the following vendor credit ' + line);

                            billsTotal -= line.Amount;
                            creditCount++;
                        }

                        // if the class Id or name can be used to identify that the  vendor credit line is for a future month it needs
                        // to be deferred
                        if (futureIds.contains(line.AccountBasedExpenseLineDetail.ClassRef.value) ||
                                futureIds.contains((line.AccountBasedExpenseLineDetail.ClassRef.name).substring(0, 5))) {
                            creditLinesToDefer.add(line);
                            pnlDebit += line.Amount;
                        } else {
//                            amountsOnPNL.put(line.AccountBasedExpenseLineDetail.ClassRef.value,
//                                    amountsOnPNL.get(line.AccountBasedExpenseLineDetail.ClassRef.value) - line.Amount);
                        }
                    }
                }
            }
        }

        Map<String, Object> processedResults = new Map<String, Object>();
        processedResults.put('Total', billsTotal);
        processedResults.put('Debit', pnlDebit);
        processedResults.put('CreditLines', creditLinesToDefer);
        processedResults.put('amountsOnPNL', amountsOnPNL);

        System.debug('total vendorCredits is ' + creditCount + ' and vendor credit total is £' + billsTotal);

        return processedResults;
    }

    private static Map<String, Object> processJournals(Set<String> futureIds, JSONParserQBOJournalFlow parsedResults, String type,
            Map<String,Decimal> amountsOnPNL) {

        Integer journalCount = 0;

        Decimal journalsTotal   = 0;
        Decimal pnlDebit        = 0;
        Decimal pnlCredit       = 0;
        Boolean derreferable    = (type == 'WIP');
        List<JSONParserQBOJournalFlow.cls_Line> journalsToDefer = new List<JSONParserQBOJournalFlow.cls_Line>();
        Set<String> accrualsIds = new Set<String>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.JournalEntry != null) {
            for (JSONParserQBOJournalFlow.cls_JournalEntry memo : parsedResults.QueryResponse.JournalEntry) {
                for (JSONParserQBOJournalFlow.cls_Line journalLine : memo.Line) {


                    accrualsIds.add(journalLine.JournalEntryLineDetail.ClassRef.value);
                    Boolean isDebit;

                    if (journalLine.JournalEntryLineDetail.AccountRef.name == '5000 Cost of sales:Events COS') {

                        System.debug('Journal line ' + journalLine.Amount + ' ' + journalLine.JournalEntryLineDetail.ClassRef.name);
                        journalCount++;

                        if (journalLine.JournalEntryLineDetail.PostingType == 'Credit') {
                            journalsTotal -= journalLine.Amount;
                            isDebit = true;
                        } else if (journalLine.JournalEntryLineDetail.PostingType == 'Debit') {
                            journalsTotal += journalLine.Amount;
                            isDebit = false;
                        }
                    }

                    if (isDebit != null) {
                        if (futureIds.contains(journalLine.JournalEntryLineDetail.ClassRef.value)) {
                            if (derreferable){
                                journalsToDefer.add(journalLine);
                                if (isDebit) {
                                    pnlDebit += journalLine.Amount;
                                } else {
                                    pnlCredit += journalLine.Amount;
                                }
                            }
                        } else if (futureIds.contains(journalLine.JournalEntryLineDetail.ClassRef.name.substring(0, 5))) {
                            if (derreferable){
                                journalsToDefer.add(journalLine);
                                if (isDebit) {
                                    pnlDebit += journalLine.Amount;
                                } else {
                                    pnlCredit += journalLine.Amount;
                                }
                            }
                        }
                    }

                    if (derreferable && journalLine.JournalEntryLineDetail.AccountRef.name == '5000 Cost of sales:Events COS'
                            && !futureIds.contains(journalLine.JournalEntryLineDetail.ClassRef.name.substring(0, 5))){
//                        amountsOnPNL.put(journalLine.JournalEntryLineDetail.ClassRef.value,
//                                amountsOnPNL.get(journalLine.JournalEntryLineDetail.ClassRef.value) + journalLine.Amount);
                    }
                }
            }
        }

        Map<String, Object> processedResults = new Map<String, Object>();
        processedResults.put('Total', journalsTotal);
        processedResults.put('pnlDebit', pnlDebit);
        processedResults.put('pnlCredit', pnlCredit);
        processedResults.put('Journals', journalsToDefer);
        processedResults.put('AccrualIds', accrualsIds);
        processedResults.put('amountsOnPNL', amountsOnPNL);

        System.debug('total ' + type + ' journals is ' + journalCount + ' and amount total is £' + journalsTotal);


        return processedResults;
    }
//
    private static Map<String,Object> processAccruals(Set<String> accrualsIds, Set<String> pastIds, JSONParserQBOBillFlow parsedResults,
            Map<String,Decimal> amountsOnPNL){

        Decimal pnlDebit       = 0;
        List<JSONParserQBOBillFlow.cls_Line> billLinesToAccrue = new List<JSONParserQBOBillFlow.cls_Line>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Bill != null) {
            for (JSONParserQBOBillFlow.cls_Bill bill : parsedResults.QueryResponse.Bill) {

                //  iterate through bill lines
                for (JSONParserQBOBillFlow.cls_Line line : bill.Line) {

                    // check that the bill line has been posted to 5000 Cost of sales:Events COS
                    if (line.AccountBasedExpenseLineDetail.AccountRef.value == '646') {
                        // check that the line  has a class
                        if (line.AccountBasedExpenseLineDetail.ClassRef == null){
                            throw new MissingQBClassException('Bill line found which is missing a class: ' + bill.Id + ' ' +  + line);
                        } else {

                            // if the class Id or name can be used to identify that the bill line is for a future month it needs
                            // to be deferred
                            if ((pastIds.contains(line.AccountBasedExpenseLineDetail.ClassRef.value) ||
                                    pastIds.contains((line.AccountBasedExpenseLineDetail.ClassRef.name).substring(0, 5)))
//                                &&
//                                !accrualsIds.contains(line.AccountBasedExpenseLineDetail.ClassRef.value) &&
//                                !accrualsIds.contains((line.AccountBasedExpenseLineDetail.ClassRef.name).substring(0,5))
                                    ) {
                                billLinesToAccrue.add(line);
                                pnlDebit += line.Amount;

                                System.debug('following bill found in next month for prior month ' + line);

//                            amountsOnPNL.put(line.AccountBasedExpenseLineDetail.ClassRef.name.substring(0, 5),
//                            amountsOnPNL.get((line.AccountBasedExpenseLineDetail.ClassRef.name.substring(0, 5)) + line.Amount));

                            }
                        }
                    }
                }
            }
        }

        Map<String,Object> processedResults = new Map<String,Object>();
        processedResults.put('Debit', pnlDebit);
        processedResults.put('BillLines', billLinesToAccrue);
        processedResults.put('amountsOnPNL', amountsOnPNL);

        return processedResults;
    }

    private static Map<String,Object> processCreditAccruals(Set<String> accrualsIds, Set<String> pastIds, JSONParserQBOVendorCreditFlow parsedResults,
            Map<String,Decimal> amountsOnPNL){

        Decimal pnlCredit       = 0;
        List<JSONParserQBOVendorCreditFlow.cls_Line> vendorCreditLinesToAccrue = new List<JSONParserQBOVendorCreditFlow.cls_Line>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.VendorCredit != null) {
            for (JSONParserQBOVendorCreditFlow.cls_VendorCredit vendorCredit : parsedResults.QueryResponse.VendorCredit) {

                //  iterate through bill lines
                for (JSONParserQBOVendorCreditFlow.cls_Line line : vendorCredit.Line) {

                    // check that the bill line has been posted to 5000 Cost of sales:Events COS
                    if (line.AccountBasedExpenseLineDetail.AccountRef.value == '646') {
                        // check that the line  has a class
                        if (line.AccountBasedExpenseLineDetail.ClassRef == null){
                            throw new MissingQBClassException('Bill line found which is missing a class: ' + vendorCredit.Id + ' ' +  + line);
                        } else {
                            system.debug('processing a mock credit on ' + line);

                            // if the class Id or name can be used to identify that the bill line is for a future month it needs
                            // to be deferred
                            if ((pastIds.contains(line.AccountBasedExpenseLineDetail.ClassRef.value) ||
                                    pastIds.contains((line.AccountBasedExpenseLineDetail.ClassRef.name).substring(0, 5)))
//                                &&
//                                !accrualsIds.contains(line.AccountBasedExpenseLineDetail.ClassRef.value) &&
//                                !accrualsIds.contains((line.AccountBasedExpenseLineDetail.ClassRef.name).substring(0,5))
                                    ) {
                                vendorCreditLinesToAccrue.add(line);
                                pnlCredit += line.Amount;

//                            amountsOnPNL.put(line.AccountBasedExpenseLineDetail.ClassRef.value,
//                                    amountsOnPNL.get(line.AccountBasedExpenseLineDetail.ClassRef.value) - line.Amount);


                            }
                        }
                    }
                }
            }
        }

        Map<String,Object> processedResults = new Map<String,Object>();
        processedResults.put('Credit', pnlCredit);
        processedResults.put('VendorCreditLines', vendorCreditLinesToAccrue);
        processedResults.put('amountsOnPNL', amountsOnPNL);

        return processedResults;
    }

    private static void createQBJournalEntries(List<JSONParserQBOBillFlow.cls_Line> bills,
            List<JSONParserQBOVendorCreditFlow.cls_Line> vendorCredits,
            List<JSONParserQBOBillFlow.cls_Line> billAccruals,
            List<JSONParserQBOVendorCreditFlow.cls_Line> vendorCreditAccruals,
            List<JSONParserQBOJournalFlow.cls_Line> journals,
            List<Opportunity> opportunities,
            List<Adjustment__c> adjustments,
            Map<Id,Decimal> adjustmentValueMap,
            Map<String,List<Object>> futureIds,
            Map<String,List<Object>> pastIds){



        Integer period = (Date.today().addMonths(-1).month() < 4) ? (9 + Date.today().addMonths(-1).month()) : (Date.today().addMonths(-1).month() - 3);
        String periodString = (period < 10) ? '0' + String.valueOf(period) : String.valueOf(period);

        String accuralsDocNumber = 'P' + periodString + ' ' + System.now().addMonths(-1).format('MMM') + ' ' +
                String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' COS Acc';

        String deferralsDocNumber = 'P' + periodString + ' ' + System.now().addMonths(-1).format('MMM') + ' ' +
                String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' COS WIP';

        // instantiate new accruals journal
        QBJournal__c accrualsJournal = new QBJournal__c();
        accrualsJournal.DocNumber__c = accuralsDocNumber;
        accrualsJournal.TxnDate__c   = Date.today().toStartOfMonth().addMonths(-1);
        accrualsJournal.Target__c    = '5000 Cost of sales';

        insert accrualsJournal;

        // instantiate new deferrals journal
        QBJournal__c deferralsJournal = new QBJournal__c();
        deferralsJournal.DocNumber__c = deferralsDocNumber;
        deferralsJournal.TxnDate__c   = Date.today().toStartOfMonth().addMonths(-1);
        deferralsJournal.Target__c    = '5000 Cost of sales';

        insert deferralsJournal;


        // instantiate new list of journal entries to insert
        Map<String,QBJournalEntry__c> entries = new Map<String,QBJournalEntry__c>();

        // capture ids for all jobs which already have journals
        Set<String> existingJournals = new Set<String>();

        // iterate through all bills
        for (JSONParserQBOBillFlow.cls_Line line : bills){

            Decimal amount      = line.Amount;
            String classId      = line.AccountBasedExpenseLineDetail.ClassRef.value;
            String className    = line.AccountBasedExpenseLineDetail.ClassRef.name;

            if (!entries.containsKey(classId + '646' + 'Credit')){
                entries.put(classId + '646' + 'Credit', populateEntry(deferralsJournal.Id, periodString, 'Credit', '646',
                        '5000 Cost of sales:Events COS', amount, classId, className));
            } else {
                entries.get(classId + '646' + 'Credit').Amount__c += amount;
            }

            if (!entries.containsKey(classId + '657' + 'Debit')) {
                entries.put(classId + '657' + 'Debit', populateEntry(deferralsJournal.Id, periodString, 'Debit', '657',
                        '1002 COS Work in Progress', amount, classId, className));
            } else {
                entries.get(classId + '657' + 'Debit').Amount__c += amount;
            }

            System.debug('creating bill deferral for ' + className + ' worth ' + line.Amount + ' of ' + ' credit');

        }

        // iterate through all vendorCredits
        for (JSONParserQBOVendorCreditFlow.cls_Line line : vendorCredits){

            Decimal amount      = line.Amount;
            String classId      = line.AccountBasedExpenseLineDetail.ClassRef.value;
            String className    = line.AccountBasedExpenseLineDetail.ClassRef.name;

            if (!entries.containsKey(classId + '646' + 'Debit')){
                entries.put(classId + '646' + 'Debit', populateEntry(deferralsJournal.Id, periodString, 'Debit', '646',
                    '5000 Cost of sales:Events COS', amount, classId, className));
            } else {
                entries.get(classId + '646' + 'Debit').Amount__c += amount;
            }

            if (!entries.containsKey(classId + '657' + 'Credit')){
                entries.put(classId + '657' + 'Credit',populateEntry(deferralsJournal.Id, periodString, 'Credit', '657',
                    '1002 COS Work in Progress', amount, classId, className));
            } else {
                entries.get(classId + '657' + 'Credit').Amount__c += amount;
            }
        }

        // iterate through all journals
        for (JSONParserQBOJournalFlow.cls_Line line : journals){

            String identifier   = line.JournalEntryLineDetail.ClassRef.value;
            String classId      = line.JournalEntryLineDetail.ClassRef.value;
            String className    = line.JournalEntryLineDetail.ClassRef.name;

            if (!existingJournals.contains(identifier)){

                if (!entries.containsKey(classId + '646' + 'Credit')){
                    entries.put(classId + '646' + 'Credit', populateEntry(deferralsJournal.Id, periodString, 'Credit', '646',
                            '5000 Cost of sales:Events COS', line.Amount, classId, className));
                } else {
                    entries.get(classId + '646' + 'Credit').Amount__c += line.Amount;
                }

//                entries.add(populateEntry(deferralsJournal.Id, periodString, 'Credit', '646',
//                        '5000 Cost of sales:Events COS', line.Amount, classId, className));
//

                if (!entries.containsKey(classId + '657' + 'Debit')){
                    entries.put(classId + '657' + 'Debit', populateEntry(deferralsJournal.Id, periodString, 'Debit', '657',
                            '1002 COS Work in Progress', line.Amount, classId, className));
                } else {
                    entries.get(classId + '657' + 'Debit').Amount__c += line.Amount;
                }

//                entries.add(populateEntry(deferralsJournal.Id, periodString, 'Debit', '657',
//                        '1002 COS Work in Progress', line.Amount, classId, className));
                existingJournals.add(identifier);
            }


            System.debug('creating journal deferral for ' + className + ' worth ' + line.Amount + ' of ' + ' credit');


        }

        // iterate through all bills
        for (JSONParserQBOBillFlow.cls_Line line : billAccruals){

            Decimal amount      = line.Amount;
            String classId      = line.AccountBasedExpenseLineDetail.ClassRef.value;
            String className    = line.AccountBasedExpenseLineDetail.ClassRef.name;

            if (!entries.containsKey(classId + '646' + 'Debit')){
                entries.put(classId + '646' + 'Debit', populateEntry(accrualsJournal.Id, periodString, 'Debit', '646',
                        '5000 Cost of sales:Events COS', line.Amount, classId, className));
            } else {
                entries.get(classId + '646' + 'Debit').Amount__c += line.Amount;
            }


//            entries.add(populateEntry(accrualsJournal.Id, periodString, 'Debit', '646',
//                    '5000 Cost of sales:Events COS', amount, classId, className));


            if (!entries.containsKey(classId + '689' + 'Credit')){
                entries.put(classId + '689' + 'Credit', populateEntry(accrualsJournal.Id, periodString, 'Credit', '689',
                        '2112 COS Accrual', line.Amount, classId, className));
            } else {
                entries.get(classId + '689' + 'Credit').Amount__c += line.Amount;
            }

//            entries.add(populateEntry(accrualsJournal.Id, periodString, 'Credit', '689',
//                    '2112 COS Accrual', amount, classId, className));
        }


        // iterate through all vendorCredits
        for (JSONParserQBOVendorCreditFlow.cls_Line line : vendorCreditAccruals){

            Decimal amount      = line.Amount;
            String classId      = line.AccountBasedExpenseLineDetail.ClassRef.value;
            String className    = line.AccountBasedExpenseLineDetail.ClassRef.name;


            if (!entries.containsKey(classId + '646' + 'Credit')){
                entries.put(classId + '646' + 'Credit', populateEntry(accrualsJournal.Id, periodString, 'Credit', '646',
                        '5000 Cost of sales:Events COS', line.Amount, classId, className));
            } else {
                entries.get(classId + '646' + 'Credit').Amount__c += line.Amount;
            }

//            entries.add(populateEntry(accrualsJournal.Id, periodString, 'Credit', '646',
//                    '5000 Cost of sales:Events COS', amount, classId, className));

            if (!entries.containsKey(classId + '689' + 'Debit')){
                entries.put(classId + '689' + 'Debit', populateEntry(accrualsJournal.Id, periodString, 'Debit', '689',
                        '2112 COS Accrual', line.Amount, classId, className));
            } else {
                entries.get(classId + '689' + 'Debit').Amount__c += line.Amount;
            }

//            entries.add(populateEntry(accrualsJournal.Id, periodString, 'Debit', '689',
//                    '2112 COS Accrual', amount, classId, className));
        }

        // iterate through opportunities which have not been invoiced and do not have journal lines against them already
        for (Opportunity opp : opportunities){

//            Decimal amount      = opp.COSRemaining__c;
            Decimal amount      = opp.Forecast_COS__c;
            String classId      = opp.QuickbooksClassId__c;
            String className    = opp.Filtered_Job_Number__c + ' ' + opp.Name;

            if (!entries.containsKey(classId + '646' + 'Debit')){
                entries.put(classId + '646' + 'Debit', populateEntry(accrualsJournal.Id, periodString,'Debit', '646',
                        '5000 Cost of sales:Events COS', amount, classId, className));
            } else {
                entries.get(classId + '646' + 'Debit').Amount__c += amount;
            }

//            entries.add(populateEntry(accrualsJournal.Id, periodString, 'Debit', '646',
//                    '5000 Cost of sales:Events COS', amount, classId, className));

            if (!entries.containsKey(classId + '689' + 'Credit')){
                entries.put(classId + '689' + 'Credit', populateEntry(accrualsJournal.Id, periodString,'Credit', '689',
                        '2112 COS Accrual', amount, classId, className));
            } else {
                entries.get(classId + '689' + 'Credit').Amount__c += amount;
            }

            System.debug('creating accrual for ' + className + ' worth ' + amount + ' of ' + 'debit');


//            entries.add(populateEntry(accrualsJournal.Id, periodString, 'Credit', '689',
//                    '2112 COS Accrual', amount, classId, className));
        }

//        for (Adjustment__c adjustment : adjustments){
//
//            Boolean minus       = adjustmentValueMap.get(adjustment.Id) < 0;
//            Decimal amount      = (minus) ? adjustmentValueMap.get(adjustment.Id) * -1 : adjustmentValueMap.get(adjustment.Id);
//            String classId      = adjustment.Opportunity__r.QuickbooksClassId__c;
//            String className    = adjustment.Opportunity__r.Filtered_Job_Number__c + ' ' + adjustment.Opportunity__r.Name;
//            String balSheetType = (minus) ? 'Credit' : 'Debit';
//            String pnlType      = (minus) ? 'Debit' : 'Credit';
//
//
//            if (!entries.containsKey(classId + '646' + pnlType)){
//                entries.put(classId + '646'+ pnlType, populateEntry(accrualsJournal.Id, periodString,pnlType,'646',
//                        '5000 Cost of sales:Events COS', amount, classId, className));
//            } else {
//                entries.get(classId + '646' + pnlType).Amount__c += amount;
//            }
////
////            entries.add(populateEntry(accrualsJournal.Id, periodString, pnlType,'646',
////                    '5000 Cost of sales:Events COS', amount, classId, className));
//
//
//            if (!entries.containsKey(classId + '689' + balSheetType)){
//                entries.put(classId + '689' + balSheetType, populateEntry(accrualsJournal.Id, periodString,balSheetType,'689',
//                        '2112 COS Accrual', amount, classId, className));
//            } else {
//                entries.get(classId + '689' + balSheetType).Amount__c += amount;
//            }
////
////            entries.add(populateEntry(accrualsJournal.Id, periodString, balSheetType, '689',
////                    '2112 COS Accrual', amount, classId, className));
//
//            System.debug('creating adjustment for ' + className + ' worth ' + amount + ' of ' + pnlType);
//        }

        insert entries.values();
    }

    private static QBJournalEntry__c populateEntry(String journalId, String periodString, String postingType,
            String accountId, String accountName, Decimal amount,
            String classId, String className){

        return new QBJournalEntry__c(
                QBJournal__c        = journalId,
                Description__c      = 'P' + periodString + ' Mgt Accs COS ' +
                        System.now().addMonths(-1).format('MMM') + ' ' +
                        String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' YTD',
                PostingType__c      = postingType,
                AccountRefId__c     = accountId,
                AccountRefName__c   = accountName,
                Amount__c           = amount,
                ClassRefId__c       = classId,
                ClassRefName__c     = className
        );
    }
}