/**
* Created by Ronan Williams on 14/11/2018.
*/

public with sharing class QuickbooksMonthEndRevenue {

//    public static void reverseRevenueJournals(Date priorMonth){
//
//        // get params for queries
//        String month    = (priorMonth.month() < 10) ? '0' + String.valueOf(priorMonth.month()) : String.valueOf(priorMonth.month());
//
//        // check for accruals journal from prior month
//        String journals = 'query?query=select%20%2a%20from%20journalentry%20where%20docNumber%20like%20%27%25Sales' +
//                '%25%27%20and%20TxnDate%20%3d%20%27' + priorMonth.year() + '-' + month + '-01' + '%27&minorversion=4';
//
//        Http http              = new Http();
//        HttpRequest request    = buildCallout(journals);
//        HttpResponse response  = http.send(request);
//
//        JSONParserQBOJournalFlow accrualJournal = JSONParserQBOJournalFlow.parse(response.getBody());
//        if (accrualJournal.QueryResponse.JournalEntry != null){
//            for (JSONParserQBOJournalFlow.cls_JournalEntry journal : accrualJournal.QueryResponse.JournalEntry){
//
//                // check that the journal is not a reversal
//                if (!journal.DocNumber.contains('R') && !journal.DocNumber.contains('Reversal')){
//                    // generate posting string
//                    generateJournalString(journal);
//                }
//            }
//        }
//    }

    public static void calculateRevenueJournal(Date closeMonth, Set<String> reversalIds) {

        // establish what the end Salesforce revenue figure need to be
        Decimal salesforceRevenue   = getTotalSalesforceFigures(closeMonth);

        // delcare values to store total figures
        Decimal monthTotalRevenue   = 0;
        Decimal pnlRevenueDebit     = 0;
        Decimal pnlRevenueCredit    = 0;

        // boolean check that all callouts have been successful
        Boolean invoiceCallout          = false;
        Boolean accrualsCallout         = false;
        Boolean creditMemoCallout       = false;
        Boolean accrualsCreditCallout   = false;
        Boolean journalCallout          = false;

        // generate date string params to be used in Quickbooks callout
//        String monthStart   = String.valueOf(Date.today().addMonths(-1).toStartOfMonth().addDays(-1)).substring(0, 10);
//        String monthEnd     = String.valueOf(Date.today().toStartOfMonth()).substring(0, 10);
//        String lastDayOfPriorMonth = String.valueOf(Date.today().toStartOfMonth().addDays(-1)).substring(0, 10);

        String monthStart   = String.valueOf(closeMonth.addDays(-1)).substring(0, 10);
        String monthEnd     = String.valueOf(closeMonth.addMonths(1).toStartOfMonth()).substring(0, 10);
        String lastDayOfPriorMonth = String.valueOf(closeMonth.addMonths(1).toStartOfMonth().addDays(-1)).substring(0, 10);


        // establish lists of journals to be created
        List<JSONParserQBOInvoiceFlow.cls_Invoice> invoicesToDefer              = new List<JSONParserQBOInvoiceFlow.cls_Invoice>();
        List<JSONParserQBOInvoiceFlow.cls_Invoice> accrualsToDebit              = new List<JSONParserQBOInvoiceFlow.cls_Invoice>();
        List<JSONParserQBOCreditMemoFlow.cls_CreditMemo> creditMemosToDefer     = new List<JSONParserQBOCreditMemoFlow.cls_CreditMemo>();
        List<JSONParserQBOCreditMemoFlow.cls_CreditMemo> memoAccrualsToDebit    = new List<JSONParserQBOCreditMemoFlow.cls_CreditMemo>();
        List<JSONParserQBOJournalFlow.cls_Line> journalsToDefer                 = new List<JSONParserQBOJournalFlow.cls_Line>();
        List<Opportunity> opportunitiesToAccrue                                 = new List<Opportunity>();
        List<Adjustment__c> adjustmentsToAccrue                                 = new List<Adjustment__c>();
        List<AggregateResult> commissionsToAccrue                               = new List<AggregateResult>();

        // get set of invoices and job numbers in the future, used to determine if entries
        // need to be deferred
        Map<String, List<Object>> futureIds = getIds(true, closeMonth);
        Map<String, List<Object>> pastIds   = getIds(false, closeMonth);
        Map<String,String> pastInvoiceIdMap = getPastInvoiceIdMap(closeMonth);


        // 1. INVOICES: callout to Quickbooks to retrieve any invoice entries siting in the prior month
        String query1 = 'query?query=select%20%2a%20from%20invoice%20where%20TxnDate%20%3e%20%27' +
                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27&minorversion=4';

        Http http1              = new Http();
        HttpRequest request1    = buildCallout(query1);
        HttpResponse response1  = http1.send(request1);

        if (response1.getStatusCode() == 200) {
            invoiceCallout = true;
            Map<String, Object> processedInvoices =
                    processInvoices(futureIds.keySet(), JSONParserQBOInvoiceFlow.parse(response1.getBody()));

            monthTotalRevenue   += (Decimal)processedInvoices.get('Total');
            pnlRevenueDebit     += (Decimal)processedInvoices.get('Debit');


            invoicesToDefer.addAll((List<JSONParserQBOInvoiceFlow.cls_Invoice>) processedInvoices.get('Invoices'));

        }

        // 2. CREDIT NOTE: callout to Quickbooks to retrieve any credit note entries siting in the prior month
        String query2 = 'query?query=select%20%2a%20from%20creditMemo%20where%20TxnDate%20%3e%20%27' +
                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27&minorversion=4';

        Http http2              = new Http();
        HttpRequest request2    = buildCallout(query2);
        HttpResponse response2  = http2.send(request2);

        if (response2.getStatusCode() == 200) {
            creditMemoCallout = true;
            Map<String, Object> processedCreditMemos =
                    processCreditMemos(futureIds.keySet(), JSONParserQBOCreditMemoFlow.parse(response2.getBody()));

            monthTotalRevenue   += (Decimal)processedCreditMemos.get('Total');
            pnlRevenueCredit    += (Decimal)processedCreditMemos.get('Credit');

            creditMemosToDefer.addAll((List<JSONParserQBOCreditMemoFlow.cls_CreditMemo>) processedCreditMemos.get('CreditMemos'));

        }

        // 3. JOURNALS: callout Quickbooks to retrieve reversed journals from the month prior
        // todo: ensure this picks up the journal from the prior month except for in the first execution instance
        // todo: these ids should be passed over from the reversal method
        Set<String> journalIds  = reversalIds;
        Set<String> accrualsIds = new Set<String>();

        for (String journalId : journalIds) {

            String query3 = 'query?query=select%20%2a%20from%20journalentry%20where%20Id%20%3d%20%27' + journalId + '%27&minorversion=4';

            // do callout
            Http http3              = new http();
            HttpRequest request3    = buildCallout(query3);
            HttpResponse response3  = http3.send(request3);

            if (response3.getStatusCode() == 200) {

                system.debug(response3.getBody());
                journalCallout = true;
                Map<String, Object> processedJournals =
                        processJournals(futureIds.keySet(), JSONParserQBOJournalFlow.parse(response3.getBody()));

                monthTotalRevenue   += (Decimal)processedJournals.get('Total');
                pnlRevenueDebit     += (Decimal)processedJournals.get('pnlDebit');
                pnlRevenueCredit    += (Decimal)processedJournals.get('pnlCredit');

                journalsToDefer.addAll((List<JSONParserQBOJournalFlow.cls_Line>) processedJournals.get('Journals'));
                accrualsIds.addAll((Set<String>) processedJournals.get('AccrualIds'));
            }

            System.debug('when jrnl callout done the debit to pnl is ' + pnlRevenueDebit);


        }

        for (JSONParserQBOJournalFlow.cls_Line line : journalsToDefer){
            system.debug('the following journal line should now be deferred ' + line);
        }


        System.debug('total for month is ' + monthTotalRevenue);

        // 4. INVOICES ACCRUAL: callout to Quickbooks to retrieve any invoice
        // entries siting in the current month which are for the prior month
        // and do not already have a journal associated with them
        String query5 = 'query?query=select%20%2a%20from%20invoice%20where%20TxnDate%20%3e%20%27' +
                lastDayOfPriorMonth + '%27&minorversion=4';

        Http http5              = new Http();
        HttpRequest request5    = buildCallout(query5);
        HttpResponse response5  = http5.send(request5);

        if (response5.getStatusCode() == 200) {
            accrualsCallout = true;
            Map<String, Object> processedAccruals =
                    processAccruals(accrualsIds, JSONParserQBOInvoiceFlow.parse(response5.getBody()), pastInvoiceIdMap);

            pnlRevenueCredit        += (Decimal)processedAccruals.get('Credit');
            accrualsToDebit.addAll((List<JSONParserQBOInvoiceFlow.cls_Invoice>) processedAccruals.get('Invoices'));
        }

        // 5. CREDIT NOTE ACCRUAL: callout to Quickbooks to retrieve any credit note entries
        // siting in the current month which are for the prior month and do not already have
        // a journal associated with them
        String query6 = 'query?query=select%20%2a%20from%20creditMemo%20where%20TxnDate%20%3e%20%27' +
                lastDayOfPriorMonth + '%27&minorversion=4';

        Http http6              = new Http();
        HttpRequest request6    = buildCallout(query6);
        HttpResponse response6  = http6.send(request6);

        if (response6.getStatusCode() == 200) {
            accrualsCreditCallout = true;
            Map<String, Object> processedAccruals =
                    processCreditAccruals(accrualsIds, JSONParserQBOCreditMemoFlow.parse(response6.getBody()),
                            pastInvoiceIdMap
                    );

            pnlRevenueDebit        += (Decimal)processedAccruals.get('Debit');
            memoAccrualsToDebit.addAll((List<JSONParserQBOCreditMemoFlow.cls_CreditMemo>) processedAccruals.get('CreditMemos'));
        }


        // 6. OPPORTUNITIES: determine if some opportunities from the prior month or
        // earlier are still not fully invoiced
        for (Opportunity opp : [SELECT Id, Filtered_Job_Number__c, Name, QuickbooksClassId__c,
                                        Percent_Invoiced__c, Amount_Calder__c, CommittedRevenue__c,
                                        Amount_Invoiced2__c, Event_end__c, Amount_Remaining__c
                                FROM Opportunity
                                WHERE Event_end__c <= :closeMonth
                                AND Event_end__c = THIS_FISCAL_YEAR
                                AND StageName = 'Closed Won'
                                AND (Percent_Invoiced__c < 99.9 OR Percent_Invoiced__c > 100.1)]){

            opportunitiesToAccrue.add(opp);

            System.debug('processing an opportunity with remaning val ' + opp.Amount_Remaining__c);

            if (opp.Amount_Remaining__c < 0){
                pnlRevenueDebit += (opp.Amount_Remaining__c * -1);
            } else {
                pnlRevenueCredit += opp.Amount_Remaining__c;
            }
        }

        // 7. OPPORTUNITY ADJUSTMENTS
        for (Adjustment__c adjustment : [SELECT Id, Revenue__c, Opportunity__r.Name,
                                                Opportunity__r.QuickbooksClassId__c,
                                                Opportunity__r.Filtered_Job_Number__c
                                        FROM Adjustment__c
                                        WHERE Month__c > :closeMonth
                                        AND Opportunity__r.Event_end__c <= :closeMonth
                                        AND (Revenue__c < -0.1 OR Revenue__c > 0.1)]) {

            System.debug('processing an opportunity with remaning val ' + adjustment.Revenue__c);

            adjustmentsToAccrue.add(adjustment);

            if (adjustment.Revenue__c < 0) {
                pnlRevenueCredit += (adjustment.Revenue__c * -1);
            } else {
                pnlRevenueDebit += adjustment.Revenue__c;
            }
        }

        // 8. DETERMINE IF CALDER COMMISSIONS SHOULD BE APPLIED TO THE MONTH
        for (AggregateResult commissionAggregate : [SELECT SUM(Revenue__c) revenue
                                                    FROM Adjustment__c
                                                    WHERE Calder__c = TRUE
                                                    AND Month__c <= :closeMonth
                                                    AND Month__c = THIS_FISCAL_YEAR]) {

            if ((Decimal)commissionAggregate.get('revenue') != null ){
                Decimal amount = (Decimal)commissionAggregate.get('revenue');

                System.debug('processing a calder commission with val ' + amount);

                commissionsToAccrue.add(commissionAggregate);

                if (amount < 0) {
                    pnlRevenueDebit += (amount * -1);
                } else {
                    pnlRevenueCredit += amount;
                }
            }
        }

        // 9. DETERMINE BALANCES ARE ACCURATE
        // create salesforce entries for each journal to post if all callouts were successful
        // and the total figures are in agreement with the Salesforce figures


//            if (invoiceCallout && creditMemoCallout && journalCallout && accrualsCallout && accrualsCreditCallout) {
        // if there is less than £1 discrepancy
//        Decimal pnlValue = (monthTotalRevenue - pnlRevenueDebit + pnlRevenueCredit) + 17800;
        Decimal pnlValue = (monthTotalRevenue - pnlRevenueDebit + pnlRevenueCredit);

        System.debug('total month rev is ' + monthTotalRevenue + ' and pnl rev debit is ' + pnlRevenueDebit +
                ' and pnl rev credit is ' + pnlRevenueCredit);

        System.debug('salesforce rev is ' + salesforceRevenue);

//                if ((pnlValue + 17800) <= (salesforceRevenue + 0.5) &&  (pnlValue + 17800) >= (salesforceRevenue - 0.5)){

        // check for any prior journal calculations for the relevant period which have not yet been exported to Quickbooks
        List<QBJournal__c> priorJournals = [SELECT Id FROM QBJournal__c WHERE TxnDate__c = :closeMonth
                                            AND Target__c = '4000 Revenue' AND QuickbooksId__c = NULL];

        // delete any prior journal entries found
        if (!priorJournals.isEmpty()) {
            delete priorJournals;
        }

        // create new journal
        createQBJournalEntries(invoicesToDefer, creditMemosToDefer, journalsToDefer,
                accrualsToDebit, memoAccrualsToDebit, opportunitiesToAccrue,
                adjustmentsToAccrue, commissionsToAccrue, futureIds, pastIds);


//                } else {
        System.debug('amounts didnt add up: total rev: ' + salesforceRevenue + ' total pnl ' + pnlValue +
                ' (discrepancy ' + (salesforceRevenue - pnlValue) + ')');
        System.debug('total pnl: ' + monthTotalRevenue);
        System.debug('total debit: ' + pnlRevenueDebit);
        System.debug('total credit: ' + pnlRevenueCredit);
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
//                }
//            }
    }

    private static Decimal getTotalSalesforceFigures(Date closeMonth){

        List<AggregateResult> oppFigures = [SELECT SUM(CommittedRevenue__c) revenue
                                                FROM Opportunity
                                                WHERE Event_end__c >= :closeMonth
                                                AND Event_end__c < :closeMonth.addMonths(1).toStartOfMonth()];
//                                                AND Committed__c = TRUE];

        List<AggregateResult> adjustmentFigures = [SELECT SUM(Revenue__c) revenue
                                                FROM Adjustment__c
                                                WHERE Month__c >= :closeMonth
                                                AND Month__c < :closeMonth.addMonths(1).toStartOfMonth()];
//                                                AND Committed__c = TRUE];

        Decimal totalOppRevenue = ((Decimal)oppFigures[0].get('revenue') != null) ?
                (Decimal)oppFigures[0].get('revenue') : 0;
        Decimal totalAdjRevenue = ((Decimal)adjustmentFigures[0].get('revenue') != null) ?
                (Decimal)adjustmentFigures[0].get('revenue') : 0;

        return totalOppRevenue + totalAdjRevenue;
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

    private static Map<String,List<Object>> getIds(Boolean future, Date closeMonth){

        Date startDate  = (future) ?  closeMonth.addMonths(1).toStartOfMonth() : closeMonth.addMonths(-6);
        Date endDate    = (future) ?  closeMonth.addYears(3) : closeMonth.addMonths(1).toStartOfMonth().addDays(-1);

        Map<String,List<Object>> futureIds = new Map<String,List<Object>>();

        for (Invoice_Schedule__c schedule : [SELECT Invoice_Id__c, Opportunity__r.Filtered_Job_Number__c,
                Opportunity__r.Name, Opportunity__r.QuickbooksClassId__c
        FROM Invoice_Schedule__c
        WHERE Opportunity__r.Event_end__c >= :startDate
        AND Opportunity__r.Event_end__c <= :endDate]){
            List<Object> oppDetails = new List<Object>{
                    schedule.Opportunity__r.Filtered_Job_Number__c,
                    schedule.Opportunity__r.Name,
                    schedule.Opportunity__r.QuickbooksClassId__c
            };

            futureIds.put(schedule.Invoice_Id__c, oppDetails);
        }

        for (Opportunity opp : [SELECT Filtered_Job_Number__c, Name, QuickbooksClassId__c
                                    FROM Opportunity
                                    WHERE StageName = 'Closed Won'
                                    AND Event_end__c >= :startDate
                                    AND Event_end__c <= :endDate]){
            List<Object> oppDetails = new List<Object>{
                    opp.Filtered_Job_Number__c,
                    opp.Name,
                    opp.QuickbooksClassId__c
            };

            futureIds.put(String.valueOf(opp.QuickbooksClassId__c), oppDetails);
        }
        return futureIds;
    }

    private static Map<String,String> getPastInvoiceIdMap(Date closeMonth){

        Map<String,String> pastIdMap = new Map<String,String>();

        for (Invoice_Schedule__c is : [SELECT Invoice_Id__c, Opportunity__r.QuickbooksClassId__c
                                        FROM Invoice_Schedule__c
                                        WHERE Opportunity__r.Event_end__c <= :closeMonth
                                        AND Opportunity__r.Event_end__c >= :closeMonth.addMonths(-6)]){
            pastIdMap.put(is.Invoice_Id__c, is.Opportunity__r.QuickbooksClassId__c);
        }
        return pastIdMap;
    }

    private static Map<String,Object> processInvoices(Set<String> futureIds, JSONParserQBOInvoiceFlow parsedResults){

        Decimal invoicesTotal   = 0;
        Decimal pnlDebit        = 0;
        List<JSONParserQBOInvoiceFlow.cls_Invoice> invoicedToDefer = new List<JSONParserQBOInvoiceFlow.cls_Invoice>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Invoice != null) {
            for (JSONParserQBOInvoiceFlow.cls_Invoice inv : parsedResults.QueryResponse.Invoice) {
                invoicesTotal += (inv.TotalAmt - inv.TxnTaxDetail.TotalTax);


                Boolean remains = true;

                // establish if the opportunity which the schedule belongs to is later than the pior month
                for (JSONParserQBOInvoiceFlow.cls_CustomField field : inv.CustomField) {
                    if (field.Name == 'Schedule' && futureIds.contains(field.StringValue)) {

                        System.debug('deferring an invoice ' + inv.DocNumber + '  with val ' + (inv.TotalAmt - inv.TxnTaxDetail.TotalTax));


                        remains = false;
                        invoicedToDefer.add(inv);
                        pnlDebit += (inv.TotalAmt - inv.TxnTaxDetail.TotalTax);
                    }
                }
            }
        }

        Map<String,Object> processedResults = new Map<String,Object>();
        processedResults.put('Total', invoicesTotal);
        processedResults.put('Debit', pnlDebit);
        processedResults.put('Invoices', invoicedToDefer);

        return processedResults;
    }

    private static Map<String,Object> processCreditMemos(Set<String> futureIds, JSONParserQBOCreditMemoFlow parsedResults){

        Decimal credtMemoTotal  = 0;
        Decimal pnlCredit       = 0;
        List<JSONParserQBOCreditMemoFlow.cls_CreditMemo> memosToDefer = new List<JSONParserQBOCreditMemoFlow.cls_CreditMemo>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.CreditMemo != null) {
            for (JSONParserQBOCreditMemoFlow.cls_CreditMemo memo : parsedResults.QueryResponse.CreditMemo) {
                credtMemoTotal -= (memo.TotalAmt - memo.TxnTaxDetail.TotalTax);



                Boolean remains = true;

                // establish if the opportunity which the schedule belongs to is later than the pior month
                for (JSONParserQBOCreditMemoFlow.cls_CustomField field : memo.CustomField) {
                    if (field.Name == 'Schedule' && futureIds.contains(field.StringValue)) {

                        System.debug('deferring an credit note with val ' + (memo.TotalAmt - memo.TxnTaxDetail.TotalTax));


                        remains = false;
                        memosToDefer.add(memo);
                        pnlCredit += (memo.TotalAmt - memo.TxnTaxDetail.TotalTax);
                    }
                }
            }
        }

        Map<String,Object> processedResults = new Map<String,Object>();
        processedResults.put('Total', credtMemoTotal);
        processedResults.put('Credit', pnlCredit);
        processedResults.put('CreditMemos', memosToDefer);

        return processedResults;
    }

    private static Map<String,Object> processJournals(Set<String> futureIds, JSONParserQBOJournalFlow parsedResults){

        Decimal journalsTotal = 0;
        Decimal pnlDebit      = 0;
        Decimal pnlCredit     = 0;
        List<JSONParserQBOJournalFlow.cls_Line> journalsToDefer = new List<JSONParserQBOJournalFlow.cls_Line>();
        Map<String,String> missingOppClassIds = new Map<String,String>();
        Set<String> accrualsIds = new Set<String>();

        System.debug('processing a journal');

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.JournalEntry != null) {
            for (JSONParserQBOJournalFlow.cls_JournalEntry memo : parsedResults.QueryResponse.JournalEntry) {
                for (JSONParserQBOJournalFlow.cls_Line journalLine : memo.Line){

//                    accrualsIds.add(journalLine.JournalEntryLineDetail.ClassRef.value);
                    Boolean isDebit;

                    if (journalLine.JournalEntryLineDetail.AccountRef.name == '4000 Revenue:Events Revenue'){
                        if(journalLine.JournalEntryLineDetail.PostingType == 'Credit'){
                            accrualsIds.add(journalLine.JournalEntryLineDetail.ClassRef.value);
                            journalsTotal   += journalLine.Amount;
                            isDebit         = true;
                        } else if (journalLine.JournalEntryLineDetail.PostingType == 'Debit'){
                            journalsTotal   -= journalLine.Amount;
                            isDebit         = false;
                        }
                    } else if (journalLine.JournalEntryLineDetail.AccountRef.name == '4002 Revenue:Rebates'){
                        journalsTotal   -= journalLine.Amount;
                        System.debug('processing a journal line with val ' + journalLine.Amount + ' of type ' + journalLine.JournalEntryLineDetail.PostingType);

                    }

                    if (isDebit != null) {


                        // check for journals which are associated with an opportunity
                        if (journalLine.JournalEntryLineDetail.ClassRef != null){


                            System.debug('processing a journal line with val ' + journalLine.Amount + ' of type ' + journalLine.JournalEntryLineDetail.PostingType +
                                    ' and the class ref found in future ids is ' + futureIds.contains(journalLine.JournalEntryLineDetail.ClassRef.value));


                            if (futureIds.contains(journalLine.JournalEntryLineDetail.ClassRef.value)) {

                                System.debug('deferring a journal line with val ' + journalLine.Amount + ' of type ' + journalLine.JournalEntryLineDetail.PostingType);

                                System.debug(journalLine.JournalEntryLineDetail.ClassRef.value);

                                journalsToDefer.add(journalLine);
                                if (isDebit) {
                                    pnlDebit += journalLine.Amount;
                                } else {
                                    pnlCredit += journalLine.Amount;
                                }
                            } else if (futureIds.contains(journalLine.JournalEntryLineDetail.ClassRef.name.substring(0, 5))) {

                                System.debug('deferring a journal line with val ' + journalLine.Amount + ' of type ' + journalLine.JournalEntryLineDetail.PostingType);

                                System.debug(journalLine.JournalEntryLineDetail.ClassRef.name.substring(0, 5));
                                journalsToDefer.add(journalLine);
                                if (isDebit) {
                                    pnlDebit += journalLine.Amount;
                                } else {
                                    pnlCredit += journalLine.Amount;
                                }

                                // if the Opportunity is missing the class Id, add to the list to update
                                missingOppClassIds.put(journalLine.JournalEntryLineDetail.ClassRef.name.substring(0, 5),
                                        journalLine.JournalEntryLineDetail.ClassRef.value);
                            }
                        }
                    }
                }
            }
        }

        Map<String,Object> processedResults = new Map<String,Object>();
        processedResults.put('Total', journalsTotal);
        processedResults.put('pnlDebit', pnlDebit);
        processedResults.put('pnlCredit', pnlCredit);
        processedResults.put('Journals', journalsToDefer);
        processedResults.put('AccrualIds', accrualsIds);

        if (!missingOppClassIds.isEmpty()){
//            QuickbooksClassSync.refreshClassSync(missingOppClassIds);
        }

        return processedResults;
    }

    private static Map<String,Object> processAccruals(Set<String> accrualsIds, JSONParserQBOInvoiceFlow parsedResults,
            Map<String,String> pastIdMap){

        Decimal pnlCredit       = 0;
        List<JSONParserQBOInvoiceFlow.cls_Invoice> invoicesToAccrue = new List<JSONParserQBOInvoiceFlow.cls_Invoice>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Invoice != null) {
            for (JSONParserQBOInvoiceFlow.cls_Invoice inv : parsedResults.QueryResponse.Invoice) {




                Boolean posted = false;

                // determine if the invoice is for a job in the past and does not have an existing journal
                // establish if the opportunity which the schedule belongs to is later than the prior month
                for (JSONParserQBOInvoiceFlow.cls_CustomField field : inv.CustomField) {
                    if (field.Name == 'Schedule'){

                        system.debug('when value is ' + (inv.TotalAmt - inv.TxnTaxDetail.TotalTax) + ' found in past map is: ' +
                                pastIdMap.containsKey(field.StringValue) + ' and found in past journals is ' + accrualsIds.contains(pastIdMap.get(field.StringValue)));


                        if (pastIdMap.containsKey(field.StringValue) && !accrualsIds.contains(pastIdMap.get(field.StringValue))){
                            posted = true;
                            invoicesToAccrue.add(inv);
                            pnlCredit += (inv.TotalAmt - inv.TxnTaxDetail.TotalTax);

                            System.debug('processing an invoiced job ' + inv.DocNumber + ' and increasing pnl by ' + (inv.TotalAmt - inv.TxnTaxDetail.TotalTax));
                        }
                    }
                }
            }
        }

        Map<String,Object> processedResults = new Map<String,Object>();
        processedResults.put('Credit', pnlCredit);
        processedResults.put('Invoices', invoicesToAccrue);

        return processedResults;
    }

    private static Map<String,Object> processCreditAccruals(Set<String> accrualsIds,
            JSONParserQBOCreditMemoFlow parsedResults, Map<String,String> pastIdMap){

        Decimal pnlDebit       = 0;
        List<JSONParserQBOCreditMemoFlow.cls_CreditMemo> memosToAccrue = new List<JSONParserQBOCreditMemoFlow.cls_CreditMemo>();

        if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.CreditMemo != null) {
            for (JSONParserQBOCreditMemoFlow.cls_CreditMemo memo : parsedResults.QueryResponse.CreditMemo) {



                Boolean posted = false;

                // determine if the invoice is for a job in the past and does not have an existing journal
                // establish if the opportunity which the schedule belongs to is later than the pior month
                for (JSONParserQBOCreditMemoFlow.cls_CustomField field : memo.CustomField) {
                    if (field.Name == 'Schedule'){

                        System.debug('processing an credited job ' + memo.DocNumber + ' and decreasing pnl by ' + (memo.TotalAmt - memo.TxnTaxDetail.TotalTax));

                        if (pastIdMap.containsKey(field.StringValue) && !accrualsIds.contains(pastIdMap.get(field.StringValue))){
                            posted = true;
                            memosToAccrue.add(memo);
                            pnlDebit += (memo.TotalAmt - memo.TxnTaxDetail.TotalTax);
                        }
                    }
                }
            }
        }

        Map<String,Object> processedResults = new Map<String,Object>();
        processedResults.put('Debit', pnlDebit);
        processedResults.put('CreditMemos', memosToAccrue);

        return processedResults;
    }


    private static void createQBJournalEntries(List<JSONParserQBOInvoiceFlow.cls_Invoice> invoices,
            List<JSONParserQBOCreditMemoFlow.cls_CreditMemo> creditMemos,
            List<JSONParserQBOJournalFlow.cls_Line> journals,
            List<JSONParserQBOInvoiceFlow.cls_Invoice> accrualsToDebit,
            List<JSONParserQBOCreditMemoFlow.cls_CreditMemo> memoAccrualsToDebit,
            List<Opportunity> opportunities,
            List<Adjustment__c> adjustments,
            List<AggregateResult> commissions,
            Map<String,List<Object>> futureIds,
            Map<String,List<Object>> pastIds){

        Integer period = (Date.today().addMonths(-1).month() < 4) ? (9 + Date.today().addMonths(-1).month()) : (Date.today().addMonths(-1).month() - 3);
        String periodString = (period < 10) ? '0' + String.valueOf(period) : String.valueOf(period);

        String docNumber = 'P' + periodString + ' ' + System.now().addMonths(-1).format('MMM') + ' ' +
                String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' Sales Ac';

        // instantiate new journal
        QBJournal__c journal = new QBJournal__c();
        journal.DocNumber__c = docNumber;
        journal.TxnDate__c   = Date.today().toStartOfMonth().addMonths(-1);
        journal.Target__c    = '4000 Revenue';

        insert journal;

        // instantiate new list of journal entries to insert
        List<QBJournalEntry__c> entries = new List<QBJournalEntry__c>();

        // capture ids for all jobs which already have journals
        Set<String> existingJournals = new Set<String>();

        // iterate through all invoices
        for (JSONParserQBOInvoiceFlow.cls_Invoice inv : invoices){

            Decimal amount      = (inv.TotalAmt - inv.TxnTaxDetail.TotalTax);
            String classId      = (String)futureIds.get(inv.CustomField[0].StringValue)[2];
            String className    = (String)futureIds.get(inv.CustomField[0].StringValue)[0] + ' ' +
                    (String)futureIds.get(inv.CustomField[0].StringValue)[1];

            entries.add(populateEntry(journal.Id, periodString, 'Debit', '645',
                    '4000 Revenue:Events Revenue', amount, classId, className));

            entries.add(populateEntry(journal.Id, periodString, 'Credit', '685',
                    '2103 Deferred Income', amount, classId, className));
        }

        // iterate through all creditMemos
        for (JSONParserQBOCreditMemoFlow.cls_CreditMemo memo : creditMemos){

            Decimal amount      = (memo.TotalAmt - memo.TxnTaxDetail.TotalTax);
            String classId      = (String)futureIds.get(memo.CustomField[0].StringValue)[2];
            String className    = (String)futureIds.get(memo.CustomField[0].StringValue)[0] + ' ' +
                    (String)futureIds.get(memo.CustomField[0].StringValue)[1];

            entries.add(populateEntry(journal.Id, periodString, 'Credit', '645',
                    '4000 Revenue:Events Revenue', amount, classId, className));

            entries.add(populateEntry(journal.Id, periodString, 'Debit', '685',
                    '2103 Deferred Income', amount, classId, className));
        }

        // iterate through all journals
        for (JSONParserQBOJournalFlow.cls_Line line : journals){

            String identifier = line.JournalEntryLineDetail.ClassRef.value;
            String classId      = (String)futureIds.get(identifier)[2];
            String className    = (String)futureIds.get(identifier)[0] + ' ' +
                    (String)futureIds.get(identifier)[1];

            System.debug('identifier is ' + identifier);

//            if (!existingJournals.contains(identifier)){

                entries.add(populateEntry(journal.Id, periodString, 'Debit', '645',
                        '4000 Revenue:Events Revenue', line.Amount, classId, className));

                entries.add(populateEntry(journal.Id, periodString, 'Credit', '685',
                        '2103 Deferred Income', line.Amount, classId, className));
                existingJournals.add(identifier);
//            }
        }

        for (JSONParserQBOInvoiceFlow.cls_Invoice inv : accrualsToDebit){

            Decimal amount      = (inv.TotalAmt - inv.TxnTaxDetail.TotalTax);
            String classId      = (String)pastIds.get(inv.CustomField[0].StringValue)[2];
            String className    = (String)pastIds.get(inv.CustomField[0].StringValue)[0] + ' ' +
                    (String)pastIds.get(inv.CustomField[0].StringValue)[1];

            entries.add(populateEntry(journal.Id, periodString, 'Credit', '645',
                    '4000 Revenue:Events Revenue', amount, classId, className));

            entries.add(populateEntry(journal.Id, periodString, 'Debit', '687',
                    '2110 Accrued Income', amount, classId, className));
        }

        for (JSONParserQBOCreditMemoFlow.cls_CreditMemo memo : memoAccrualsToDebit){

            Decimal amount      = (memo.TotalAmt - memo.TxnTaxDetail.TotalTax);
            String classId      = (String)pastIds.get(memo.CustomField[0].StringValue)[2];
            String className    = (String)pastIds.get(memo.CustomField[0].StringValue)[0] + ' ' +
                    (String)pastIds.get(memo.CustomField[0].StringValue)[1];

            entries.add(populateEntry(journal.Id, periodString, 'Debit', '645',
                    '4000 Revenue:Events Revenue', amount, classId, className));

            entries.add(populateEntry(journal.Id, periodString, 'Credit', '687',
                    '2110 Accrued Income', amount, classId, className));
        }

        // iterate through opportunities which have not been invoiced and do not have journal lines against them already
        for (Opportunity opp : opportunities){

            Boolean minus       = (opp.Amount_Remaining__c) < 0;
            Decimal amount      = (minus) ? opp.Amount_Remaining__c * -1 : opp.Amount_Remaining__c;
            String classId      = opp.QuickbooksClassId__c;
            String className    = opp.Filtered_Job_Number__c + ' ' + opp.Name;
            String pnlType      = (minus) ? 'Debit' : 'Credit';
            String balSheetType = (minus) ? 'Credit' : 'Debit';

            entries.add(populateEntry(journal.Id, periodString, pnlType, '645',
                    '4000 Revenue:Events Revenue', amount, classId, className));

            entries.add(populateEntry(journal.Id, periodString, balSheetType, '687',
                    '2110 Accrued Income', amount, classId, className));
        }

        for (Adjustment__c adjustment : adjustments){

            Boolean minus       = (adjustment.Revenue__c) < 0;
            Decimal amount      = adjustment.Revenue__c * -1;
            String classId      = adjustment.Opportunity__r.QuickbooksClassId__c;
            String className    = adjustment.Opportunity__r.Filtered_Job_Number__c + ' ' + adjustment.Opportunity__r.Name;
            String balSheetType = (minus) ? 'Debit' : 'Credit';
            String pnlType      = (minus) ? 'Credit' : 'Debit';

            entries.add(populateEntry(journal.Id, periodString, pnlType,'645',
                    '4000 Revenue:Events Revenue', amount, classId, className));

            entries.add(populateEntry(journal.Id, periodString, balSheetType, '687',
                    '2110 Accrued Income', amount, classId, className));
        }

        for (AggregateResult commission : commissions){

            Boolean minus       = ((Decimal)commission.get('revenue')) < 0;
            Decimal amount      = (minus) ? (Decimal)commission.get('revenue') * -1 : (Decimal)commission.get('revenue');
            String balSheetType = (minus) ? 'Credit' : 'Debit';
            String pnlType      = (minus) ? 'Debit' : 'Credit';

            entries.add(populateEntry(journal.Id, periodString, pnlType,'823',
                    '4002 Revenue:Rebates', amount, null, null));

            entries.add(populateEntry(journal.Id, periodString, balSheetType, '686',
                    '2109 Other Accruals', amount, null, null));
        }

        insert entries;
    }

    private static QBJournalEntry__c populateEntry(String journalId, String periodString, String postingType,
            String accountId, String accountName, Decimal amount,
            String classId, String className){

        return new QBJournalEntry__c(
                QBJournal__c        = journalId,
                Description__c      = 'P' + periodString + ' Mgt Accs Defer sales ' +
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

//    private static String generateJournalString(JSONParserQBOJournalFlow.cls_JournalEntry journal){
//
//        String journalLines = '';
//
//        // create a string JSON entry for each journal to post
//        for (Integer x = 0; x < journal.Line.size(); x++){
//
//            String postingType  = journal.Line[x].JournalEntryLineDetail.PostingType;
//            String reversal     = (postingType == 'Credit') ? 'Debit' : 'Credit';
//
//            journalLines +=
//                    '   {' +
//                            '       "Id": "' + x + '",' +
//                            '       "Description": "' + journal.Line[x].Description + '",' +
//                            '       "Amount": ' + journal.Line[x].Amount + ',' +
//                            '       "DetailType": "JournalEntryLineDetail",' +
//                            '       "JournalEntryLineDetail": {' +
//                            '       "PostingType": "' + reversal + '",' +
//                            '       "AccountRef": {' +
//                            '           "value": "' + journal.Line[x].JournalEntryLineDetail.AccountRef.value + '"' +
//                            '       },' +
//                            '       "ClassRef": {' +
//                            '           "value": "' + journal.Line[x].JournalEntryLineDetail.ClassRef.value + '"' +
//                            '       }' +
//                            '   }' +
//                            '}';
//
//            if (x+1 < journal.Line.size()){
//                journalLines += ',';
//            }
//        }
//
//        Map<Integer,String> monthNameMap = new Map<Integer, String>{
//                1=>'Jan', 2=>'Feb', 3=>'Mar', 4=>'Apr', 5=>'May',
//                6=>'Jun', 7=>'Jul', 8=>'Aug', 9=>'Sep',10=>'Oct',
//                11=>'Nov', 12=>'Dec'};
//
//        String month = (Date.today().month() < 10) ?
//                '0' + String.valueOf(Date.today().month()) :
//                String.valueOf(Date.today().month());
//        String type = (journal.DocNumber.contains('Defer')) ? 'Defer' : 'Ac';
//
//        String journalString =
//                '   {' +
//                        '   "DocNumber": "' + 'P' + month + ' ' + monthNameMap.get(Date.today().month()) +
//                        '                   Sales ' + type + '",' +
//                        '   "TxnDate": "' + 'String.valueOf(journal.TxnDate__c).substring(0,10)' + '",' +
//                        '   "Line": [' +
//                        journalLines +
//                        '       ]' +
//                        '   }';
//
//        System.debug(journalString);
//
//        return journalString;
//    }


}

