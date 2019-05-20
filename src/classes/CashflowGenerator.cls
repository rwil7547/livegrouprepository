/**
 * Created by Ronan Williams on 25/03/2019.
 */

public with sharing class CashflowGenerator {


    public static void buildFlow(Boolean resetValues){

        // get the cash flow entries in a map ordered by date asc
        Map<Date, CashFlow__c> flowMap            = CashFlowUtils.getFlowMap();

        // create a map of all budget entries, used to calculate budget offsetting
        // and then budget entries in the flow
        Map<String,QBProfitAndLoss__c> budgetMap = new Map<String,QBProfitAndLoss__c>();

        for (QBProfitAndLoss__c pnl : [SELECT Id, Month__c, Parent__c, Actual__c, Category__c, Nominal__c
        FROM QBProfitAndLoss__c
        WHERE Month__c >= :Date.today().toStartOfMonth()]){
            String budgetKey = String.valueOf(pnl.Month__c.month()) + String.valueOf(pnl.Month__c.year()) + pnl.Parent__c;
            budgetMap.put(budgetKey,pnl);
        }

        // retain all old entries as a map using the specified entry id, used to determine
        // if values on the new entities (comments, date and amount changes) should be inherited from the old entities
        Map<String,CashFlowEntry__c> oldEntryMap    = new Map<String,CashFlowEntry__c>();
        List<CashFlowEntry__c> newEntries           = new List<CashFlowEntry__c>();

        for (CashFlowEntry__c entry : [SELECT Id, Amount__c, AmountAdjusted__c, Adjusted__c, Paid__c, Comment__c,
                QuickbooksId__c, OutFlow__c, InFlow__c, AdjustedDate__c,
                OutFlow__r.Date__c, InFlow__r.Date__c, Description__c, Date__c
        FROM CashFlowEntry__c]){

            // add the old entries to a map which will allow new entries to check for any custom values
            // which need to be preserved (amount, date, comments)
            String identifier = (entry.QuickbooksId__c != null) ? entry.QuickbooksId__c : entry.Id;
            oldEntryMap.put(identifier, entry);
        }

        // get direct debit and freelancer supplier profiles
        Map<String,QBSupplierProfile__c> directDebits   = new Map<String,QBSupplierProfile__c>();
        Set<String> freelancerIds                       = new Set<String>();
        for (QBSupplierProfile__c profile : [SELECT Id, Amount__c, EndDate__c, Day__c, Category__c,
                Frequency__c, SupplierId__c, SupplierName__c, Terms__c,
                Type__c, LastInstance__c
        FROM QBSupplierProfile__c]){
            if (profile.Type__c == 'DD'){
                directDebits.put(profile.SupplierId__c, profile);
            } else if (profile.Type__c == 'Freelancers'){
                freelancerIds.add(profile.SupplierId__c);
            }
        }

        // INIT: GET CURRENT BALANCE
        Decimal startingBalance = 0;

        String query1 = 'query?query=select%20%2a%20from%20account%20where%20name%20' +
                '%3d%20%27Bank%20Current%20Account%27&minorversion=4';

        // do callout
        Http http1              = new Http();
        HttpRequest request1    = CashFlowUtils.doCallout(query1);
        HttpResponse response1  = http1.send(request1);

        if (response1.getStatusCode() == 200) {
            JSONParserQBOCurrentAccount parsedResults = JSONParserQBOCurrentAccount.parse(response1.getBody());
            startingBalance = parsedResults.QueryResponse.Account[0].CurrentBalance;
        }


        // STEP 1: GET QUICKBOOKS INVOICES
        String invoiceQuery = 'query?query=select%20%2a%20from%20invoice%20where%20Balance%20' +
                '%3e%20%270%27&minorversion=4';

        // do callout
        Http http2 = new Http();
        HttpRequest request2 = CashFlowUtils.doCallout(invoiceQuery);
        HttpResponse response2 = http2.send(request2);

        if (response2.getStatusCode() == 200) {
            JSONParserQBOInvoiceFlow parsedResults = JSONParserQBOInvoiceFlow.parse(response2.getBody());

            Set<String> invoiceIds      = new Set<String>();
            Set<String> scheduleNumbers = new Set<String>();

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Invoice != null) {
                for (JSONParserQBOInvoiceFlow.cls_Invoice inv : parsedResults.QueryResponse.Invoice) {
                    invoiceIds.add(inv.Id);

                    for (JSONParserQBOInvoiceFlow.cls_CustomField customField : inv.CustomField) {
                        if (customField.Name == 'Schedule') {
                            scheduleNumbers.add(customField.StringValue);
                        }
                    }
                }
            }

            Map<String, Decimal> creditMap   = new Map<String, Decimal>();
            Map<String, String> customerMap  = CashFlowUtils.getCustomerMap(scheduleNumbers);

            List<Invoice_Schedule__c> credits = [SELECT Credit_Note__c, QBOInvoiceId__c
                                                FROM Invoice_Schedule__c
                                                WHERE QBOInvoiceId__c IN :invoiceIds
                                                AND Credit_Note__c > 0];

            for (Invoice_Schedule__c is : credits) {
                creditMap.put(is.QBOInvoiceId__c, is.Credit_Note__c * 1.2);
            }

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Invoice != null) {
                for (JSONParserQBOInvoiceFlow.cls_Invoice inv : parsedResults.QueryResponse.Invoice) {

                    Decimal balance     = (creditMap.containsKey(inv.Id)) ? inv.Balance - creditMap.get(inv.Id) : inv.Balance;
                    Date adjustedDate   = !resetValues && oldEntryMap.containsKey(inv.Id) && oldEntryMap.get(inv.Id).AdjustedDate__c != null ?
                            oldEntryMap.get(inv.Id).AdjustedDate__c : null;
                    Date dueDate        = adjustedDate != null ? adjustedDate : Date.valueOf(inv.DueDate) < Date.today().addDays(1) ?
                            Date.today().addDays(1) :  Date.valueOf(inv.DueDate);
                    String comment      = oldEntryMap.containsKey(inv.Id) ? oldEntryMap.get(inv.Id).Comment__c : null;
                    String scheduleNumber = '';

                    for (JSONParserQBOInvoiceFlow.cls_CustomField customField : inv.CustomField) {
                        if (customField.Name == 'Schedule') {
                            scheduleNumber = customField.StringValue;
                        }
                    }

                    if (flowMap.containsKey(dueDate)) {
                        newEntries.add(new CashFlowEntry__c(
                                CashFlow__c     = flowMap.get(dueDate).Id,
                                Source__c       = 'Quickbooks',
                                Category__c     = (customerMap.containsKey(scheduleNumber)) ? customerMap.get(scheduleNumber) : 'Other',
                                Description__c  = inv.CustomerRef.name + ' Inv. ' + inv.DocNumber,
                                Amount__c       = balance,
                                QuickbooksId__c = inv.Id,
                                Stage__c        = 'Confirmed',
                                BudgetKey__c    = 'Revenue',
                                Comment__c      = comment,
                                AdjustedDate__c = adjustedDate));
                    }

                    String budgetKey = String.valueOf(dueDate.month()) + String.valueOf(dueDate.year()) + 'Revenue';
                    if (budgetMap.containsKey(budgetKey)){
                        budgetMap.get(budgetKey).Actual__c -= balance;
                    }
                }
            }
        }

        // STEP 2: GET SALESFORCE INVOICES
        List<Invoice_Schedule__c> schedules = [SELECT Id, Amount__c, Payment_Date__c, Send_Date__c,
                                                    Opportunity__r.Account.QuickbooksId__c, Invoice_Id__c,
                                                    Opportunity__r.Name, Opportunity__r.Event_end__c,
                                                    Name, Job_Number__c, Opportunity__r.Account.Name,
                                                    Opportunity__r.Comments__c
                                            FROM Invoice_Schedule__c
                                            WHERE Invoice_Sent__c = FALSE
                                            AND Invoice_Paid__c = FALSE
                                            AND Opportunity__r.Event_end__c >= LAST_N_MONTHS:12];

        for (Invoice_Schedule__c schedule : schedules) {

            Date adjustedDate   = !resetValues && oldEntryMap.containsKey(schedule.Id) && oldEntryMap.get(schedule.Id).AdjustedDate__c != null ?
                    oldEntryMap.get(schedule.Id).AdjustedDate__c : null;
            Date dueDate        = adjustedDate != null ? adjustedDate : schedule.Send_Date__c.addDays(30) < Date.today().addDays(30) ?
                    Date.today().addDays((30 + (Integer.valueOf(schedule.Amount__c) / 1000))) :  schedule.Send_Date__c.addDays(30);
            String comment      = oldEntryMap.containsKey(schedule.Id) && oldEntryMap.get(schedule.Id).Comment__c != null ?
                    oldEntryMap.get(schedule.Id).Comment__c : '';

            if (schedule.Opportunity__r.Comments__c != null && !comment.contains(schedule.Opportunity__r.Comments__c)){
                comment = schedule.Opportunity__r.Comments__c + ' ' + comment;
            }

            if (flowMap.containsKey(dueDate)) {
                newEntries.add(new CashFlowEntry__c(
                        CashFlow__c     = flowMap.get(dueDate).Id,
                        Source__c       = 'Salesforce',
                        Category__c     = schedule.Opportunity__r.Account.Name,
                        Description__c  = schedule.Opportunity__r.Name + ' ' + schedule.Name,
                        QuickbooksId__c = schedule.Id,
                        Stage__c        = 'Confirmed',
                        BudgetKey__c    = 'Revenue',
                        Comment__c      = comment,
                        AdjustedDate__c = adjustedDate,
                        Amount__c       = (schedule.Amount__c * 1.2).setScale(2)));
            }

            String budgetKey = String.valueOf(dueDate.month()) + String.valueOf(dueDate.year()) + 'Revenue';
            if (budgetMap.containsKey(budgetKey)){
                budgetMap.get(budgetKey).Actual__c -= (schedule.Amount__c * 1.2).setScale(2);
            }
        }

        // STEP 3: GET QUICKBOOKS BILLS
        String billQuery = 'query?query=select%20%2a%20from%20bill%20where%20Balance%20' +
                '%21%3d%20%270%27&minorversion=4';

        // do callout
        Http billHttp               = new Http();
        HttpRequest billRequest     = CashFlowUtils.doCallout(billQuery);
        HttpResponse billResponse   = billHttp.send(billRequest);

        if (billResponse.getStatusCode() == 200) {
            JSONParserQBOBillFlow parsedResults = JSONParserQBOBillFlow.parse(billResponse.getBody());

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Bill != null) {

                for (JSONParserQBOBillFlow.cls_Bill bill : parsedResults.QueryResponse.Bill) {

                    if (!directDebits.containsKey(bill.VendorRef.value)) {

                        Date adjustedDate   = !resetValues && oldEntryMap.containsKey(bill.Id) && oldEntryMap.get(bill.Id).AdjustedDate__c != null ?
                                oldEntryMap.get(bill.Id).AdjustedDate__c : null;
                        Date dueDate        = adjustedDate != null ? adjustedDate : Date.valueOf(bill.DueDate) < Date.today().addDays(1) ?
                                Date.today().addDays(1) :  Date.valueOf(bill.DueDate);
                        String comment      = oldEntryMap.containsKey(bill.Id) ? oldEntryMap.get(bill.Id).Comment__c : null;
                        String category     = freelancerIds.contains(bill.VendorRef.value) ?
                                'Freelancers' : bill.VendorRef.name == 'Barclaycard' ?
                                        'Credit Card' : 'Payment run';

                        Set<String> budgetKeys = new Set<String>();
                        String budgetKeyString = '';

                        for (JSONParserQBOBillFlow.cls_Line line : bill.Line){
                            String account      = (category == 'Freelancers') ? 'Freelancers' :
                                    line.AccountBasedExpenseLineDetail.AccountRef.name.split(' ',2)[1].split(':',2)[0];
                            String budgetKey    = String.valueOf(dueDate.month()) + String.valueOf(dueDate.year()) + account;
                            budgetKeys.add(line.AccountBasedExpenseLineDetail.AccountRef.name.split(' ',2)[1].split(':',2)[0]);
                            budgetKeyString     = line.AccountBasedExpenseLineDetail.AccountRef.name.split(' ',2)[1].split(':',2)[0];
                            if (budgetMap.containsKey(budgetKey)){
                                budgetMap.get(budgetKey).Actual__c -= line.Amount;
                            }
                        }

                        if (flowMap.containsKey(dueDate)) {
                            newEntries.add(new CashFlowEntry__c(
                                    CashFlow__c         = flowMap.get(dueDate).Id,
                                    Out__c              = true,
                                    Source__c           = 'Quickbooks',
                                    Stage__c            = 'Confirmed',
                                    BudgetKey__c        = budgetKeys.size() == 1 ? budgetKeyString : null,
                                    Category__c         = category,
                                    Description__c      = bill.VendorRef.name,
                                    Amount__c           = bill.Balance,
                                    QuickbooksId__c     = bill.Id,
                                    VendorRef__c        = bill.VendorRef.value,
                                    Comment__c          = comment,
                                    AdjustedDate__c     = adjustedDate));
                        }
                    }
                }
            }
        }

        // STEP 4: GET SALESFORCE COS
        List<Opportunity> opps = [SELECT Filtered_Cost_of_Sale__c, Name,
                                        Quickbooks_COS__c, Event_end__c, Filtered_Job_Number__c
                                FROM Opportunity
                                WHERE StageName = 'Closed Won'
                                AND Quote_Status__c != 'Reconciliation - completed'
                                AND Event_end__c >= LAST_N_DAYS:100];

        Map<String, CashFlowEntry__c> cosEntries = new Map<String, CashFlowEntry__c>();

        for (Opportunity opp : opps) {

            // if there is still forecast COS, split into two batches
            if (opp.Filtered_Cost_of_Sale__c > opp.Quickbooks_COS__c)  {

                String age                  = opp.Event_end__c < Date.today() ? ' (' + opp.Event_end__c.daysBetween(Date.today()) + ' days old)' : '';
                String status               = opp.Event_end__c < Date.today() ? ' COS accrual' : ' COS event allocation';
                Date paymentDate            = (opp.Event_end__c < Date.today().addDays(35)) ?
                        Date.today().addDays(35).toStartOfWeek().addDays(3) :
                        opp.Event_end__c.toStartOfWeek().addDays(3);
                Decimal amount              = (((opp.Filtered_Cost_of_Sale__c - opp.Quickbooks_COS__c) * 1.2)).setScale(2);

                if (flowMap.containsKey(paymentDate)) {
                    // detect duplicate cos entries for the same day
                    if (cosEntries.containsKey(String.valueOf(paymentDate) + status)) {
                        cosEntries.get(String.valueOf(paymentDate) + status).Amount__c += amount;
                        cosEntries.get(String.valueOf(paymentDate) + status).Details__c += '£' +
                                amount + ': ' + opp.Name + age + '\n' ;
                    } else {
                        cosEntries.put(String.valueOf(paymentDate) + status, new CashFlowEntry__c(
                                CashFlow__c     = flowMap.get(paymentDate).Id,
                                Out__c          = true,
                                Source__c       = 'Salesforce',
                                Category__c     = 'Payment run',
                                Description__c  = status,
                                Details__c      = 'System generated payment run entry: \n' +
                                        '£' + amount + ': ' +  opp.Name + age + '\n',
                                Stage__c        = 'Confirmed',
                                BudgetKey__c    = 'Cost of Sales',
                                Amount__c       = amount));
                    }

                    String budgetKey = String.valueOf(paymentDate.month()) + String.valueOf(paymentDate.year()) + 'Cost of Sales';
                    if (budgetMap.containsKey(budgetKey)){
                        budgetMap.get(budgetKey).Actual__c -= amount;
                    }
                }
            }
        }

        newEntries.addAll(cosEntries.values());

        // STEP 5: GET SALESFORCE PIPELINE DATA
        List<Opportunity> unconfirmedOpps = [SELECT Amount_Calder__c, Name, Probability, Event_end__c,
                                                    Filtered_Cost_of_Sale__c, Filtered_Job_Number__c, ExpectedRevenue,
                                                    Account.Name, LastModifiedDate, LastModifiedBy.Name
                                            FROM Opportunity
                                            WHERE StageName != 'Closed Won'
                                            AND StageName != 'Closed Lost'
                                            AND StageName != 'Repeat Prospect'
                                            AND Amount > 0 AND Event_end__c > TODAY
                                            AND Event_end__c != NULL AND Event_start__c != NULL];

        Map<Date, CashFlowEntry__c> pipelineCosEntries = new Map<Date, CashFlowEntry__c>();

        for (Opportunity opp : unconfirmedOpps) {

            Decimal inAmount    = (((opp.Amount_Calder__c * (opp.Probability / 100)) * 1.2)).setScale(2);
            Decimal outAmount   = (((opp.Filtered_Cost_of_Sale__c * (opp.Probability / 100)) * 1.2)).setScale(2);
            Date inDate         = (opp.Event_end__c < Date.today().addDays(45)) ?
                    Date.today().addDays(45) : opp.Event_end__c;

            if (flowMap.containsKey(inDate)) {
                newEntries.add(new CashFlowEntry__c(
                        CashFlow__c     = flowMap.get(inDate).Id,
                        Source__c       = 'SalesforceP',
                        Category__c     = opp.Account.Name,
                        Description__c  = 'Prob. ' + opp.Probability + '% : ' + opp.Name,
                        Details__c      = 'System generated payment date using weighted amount \n' +
                                'Last activity by ' + opp.LastModifiedBy.Name + ' ' +
                                Date.valueOf(opp.LastModifiedDate).daysBetween(Date.today()) + ' days ago',
                        Stage__c        = 'Pipeline',
                        BudgetKey__c    = 'Revenue',
                        QuickbooksId__c = opp.Id + 'Invoice',
                        Amount__c       = inAmount));

                String budgetKey = String.valueOf(inDate.month()) + String.valueOf(inDate.year()) + 'Revenue';
                if (budgetMap.containsKey(budgetKey)){
                    budgetMap.get(budgetKey).Actual__c -= inAmount;
                }
            }

            if (flowMap.containsKey(inDate.toStartOfWeek().addDays(3)) && outAmount > 0) {

                Date ouDate = inDate.toStartOfWeek().addDays(3);

                if (pipelineCosEntries.containsKey(ouDate)) {
                    pipelineCosEntries.get(ouDate).Amount__c += outAmount;
                    pipelineCosEntries.get(ouDate).Details__c += '£' + outAmount +
                            ': Prob. ' + opp.Probability + '%: ' + opp.Name + '\n' ;
                } else {
                    pipelineCosEntries.put(ouDate, new CashFlowEntry__c(
                            CashFlow__c     = flowMap.get(ouDate).Id,
                            Out__c          = true,
                            Source__c       = 'SalesforceP',
                            Category__c     = 'Payment run',
                            Description__c  = 'Pipeline COS provision',
                            Details__c      = 'System generated payment run entry using weighted cost of sales: \n' +
                                    '£' + outAmount + ': Prob. ' + opp.Probability + '%: ' + opp.Name + '\n',
                            Stage__c        = 'Pipeline',
                            BudgetKey__c    = 'Cost of Sales',
                            Amount__c       = outAmount));
                }

                String budgetKey = String.valueOf(ouDate.month()) + String.valueOf(ouDate.year()) + 'Cost of Sales';
                if (budgetMap.containsKey(budgetKey)){
                    budgetMap.get(budgetKey).Actual__c -= inAmount;
                }
            }
        }

        newEntries.addAll(pipelineCosEntries.values());


        // STEP 7: PLOT DIRECT DEBITS
        for (QBSupplierProfile__c directDebit : directDebits.values()){

            // work out the end date for the direct debit
            Date endDate = (directDebit.EndDate__c != null) ? directDebit.EndDate__c : Date.today().addDays(170);

            system.debug('dd profile is ' + directDebit);

            if (directDebit.Terms__c.equalsIgnoreCase('weekly')){

                Date processingDate = (directDebit.LastInstance__c == null) ?
                        Date.today().toStartOfWeek().addDays(Integer.valueOf(directDebit.Day__c) - 1) :
                        directDebit.LastInstance__c.addDays(7).toStartOfWeek().addDays(Integer.valueOf(directDebit.Day__c) - 1);

                while (processingDate < endDate){
                    if (flowMap.containsKey(processingDate) || (processingDate < Date.today() && directDebit.LastInstance__c != null)) {

                        String entryKey = directDebit.SupplierId__c + String.valueOf(processingDate);
                        String comment  = oldEntryMap.containsKey(entryKey) && oldEntryMap.get(entryKey).Comment__c != null ?
                                oldEntryMap.get(entryKey).Comment__c : '';
                        Boolean paid    = oldEntryMap.containsKey(entryKey) ? oldEntryMap.get(entryKey).Paid__c : false;

                        newEntries.add(new CashFlowEntry__c(
                                Out__c          = true,
                                CashFlow__c     = flowMap.containsKey(processingDate) ?
                                        flowMap.get(processingDate).Id : flowMap.get(Date.today()).Id,
                                Source__c       = 'DirectDebit',
                                Category__c     = 'Direct Debit',
                                Description__c  = directDebit.SupplierName__c,
                                Amount__c       = directDebit.Amount__c,
                                QuickbooksId__c = entryKey,
                                Stage__c        = 'Confirmed',
                                BudgetKey__c    = directDebit.Category__c,
                                VendorRef__c    = directDebit.SupplierId__c,
                                Comment__c      = comment,
                                Paid__c         = paid
                        ));

                        String budgetKey = String.valueOf(processingDate.month()) + String.valueOf(processingDate.year()) + directDebit.Category__c;
                        if (budgetMap.containsKey(budgetKey)){
                            budgetMap.get(budgetKey).Actual__c -= directDebit.Amount__c;
                        }
                    }
                    processingDate = processingDate.addDays(7);
                }
            } else if (directDebit.Terms__c.equalsIgnoreCase('monthly')){

                Date processingDate = (directDebit.LastInstance__c == null) ?
                        Date.today().toStartOfMonth().addDays(Integer.valueOf(directDebit.Day__c)) :
                        directDebit.LastInstance__c.addMonths(1).toStartOfMonth().addDays(Integer.valueOf(directDebit.Day__c) - 1);

                while (processingDate < endDate){
                    if (flowMap.containsKey(processingDate) || (processingDate < Date.today() && directDebit.LastInstance__c != null)) {

                        String entryKey = directDebit.SupplierId__c + String.valueOf(processingDate);
                        String comment  = oldEntryMap.containsKey(entryKey) && oldEntryMap.get(entryKey).Comment__c != null ?
                                oldEntryMap.get(entryKey).Comment__c : '';
                        Boolean paid    = oldEntryMap.containsKey(entryKey) ? oldEntryMap.get(entryKey).Paid__c : false;

                        newEntries.add(new CashFlowEntry__c(
                                Out__c          = true,
                                CashFlow__c     = flowMap.containsKey(processingDate) ?
                                        flowMap.get(processingDate).Id : flowMap.get(Date.today()).Id,
                                Source__c       = 'DirectDebit',
                                Category__c     = 'Direct Debit',
                                Description__c  = directDebit.SupplierName__c,
                                Amount__c       = directDebit.Amount__c,
                                QuickbooksId__c = entryKey,
                                Stage__c        = 'Confirmed',
                                BudgetKey__c    = directDebit.Category__c,
                                VendorRef__c    = directDebit.SupplierId__c,
                                Comment__c      = comment,
                                Paid__c         = paid
                        ));

                        String budgetKey = String.valueOf(processingDate.month()) + String.valueOf(processingDate.year()) + directDebit.Category__c;
                        if (budgetMap.containsKey(budgetKey)){
                            budgetMap.get(budgetKey).Actual__c -= directDebit.Amount__c;
                        }
                    }
                    processingDate = processingDate.addMonths(1);
                }
            } else if (directDebit.Terms__c.equalsIgnoreCase('quarterly')){

                Date processingDate = (directDebit.LastInstance__c == null) ?
                        Date.newInstance(Date.today().year(),Integer.valueOf(directDebit.Day__c),15) :
                        directDebit.LastInstance__c.addMonths(3).toStartOfMonth().addDays(15);

                while (processingDate < endDate){
                    if (flowMap.containsKey(processingDate) || (processingDate < Date.today() && directDebit.LastInstance__c != null)) {

                        String entryKey = directDebit.SupplierId__c + String.valueOf(processingDate);
                        String comment  = oldEntryMap.containsKey(entryKey) && oldEntryMap.get(entryKey).Comment__c != null ?
                                oldEntryMap.get(entryKey).Comment__c : '';
                        Boolean paid    = oldEntryMap.containsKey(entryKey) ? oldEntryMap.get(entryKey).Paid__c : false;

                        newEntries.add(new CashFlowEntry__c(
                                Out__c          = true,
                                CashFlow__c     = flowMap.containsKey(processingDate) ?
                                        flowMap.get(processingDate).Id : flowMap.get(Date.today()).Id,
                                Source__c       = 'DirectDebit',
                                Category__c     = 'Direct Debit',
                                Description__c  = directDebit.SupplierName__c,
                                Amount__c       = directDebit.Amount__c,
                                QuickbooksId__c = entryKey,
                                Stage__c        = 'Confirmed',
                                BudgetKey__c    = directDebit.Category__c,
                                VendorRef__c    = directDebit.SupplierId__c,
                                Comment__c      = comment,
                                Paid__c         = paid
                        ));

                        String budgetKey = String.valueOf(processingDate.month()) + String.valueOf(processingDate.year()) + directDebit.Category__c;
                        if (budgetMap.containsKey(budgetKey)){
                            budgetMap.get(budgetKey).Actual__c -= directDebit.Amount__c;
                        }
                    }
                    processingDate = processingDate.addMonths(3);
                }
            }
        }

        // VAT
        Map<String,CashFlowEntry__c> vatEntryMap = new Map<String,CashFlowEntry__c>();

        for (AggregateResult ar : [SELECT SUM(Actual__c)actual, FISCAL_QUARTER(Month__c)quarter,
                                            FISCAL_YEAR(Month__c)year, Category__c
                                    FROM QBProfitAndLoss__c
                                    WHERE (Category__c = 'Revenue'
                                          OR Category__c = 'Cost of sales'
                                          OR Category__c = 'Expense')
                                    AND Month__c <= NEXT_FISCAL_YEAR
                                    AND Month__c >= LAST_N_MONTHS:3
                                    GROUP BY Category__c,FISCAL_YEAR(Month__c), FISCAL_QUARTER(Month__c)]) {

            String vatKey   = String.valueOf((Integer) ar.get('quarter')) + String.valueOf((Integer) ar.get('year'));
            Integer year    = (Integer) ar.get('year');
            Integer quarter = (Integer) ar.get('quarter');
            Date vatYear    = Date.newInstance(year, 01, 25);
            Date vatDate    = vatYear.addMonths((quarter * 3) + 4);
            Decimal sum     = ar.get('actual') != null ? (Decimal) ar.get('actual') : 0;
            Decimal vatAmt  = (String) ar.get('Category__c') == 'Revenue' ? sum * 0.2 : (sum * -1) * 0.15;
            String comment  = '';

            if (oldEntryMap.containsKey(vatKey)){
                if (oldEntryMap.get(vatKey).AmountAdjusted__c){
                    vatAmt = oldEntryMap.get(vatKey).Amount__c;
                }
                if (oldEntryMap.get(vatKey).AdjustedDate__c != null){
                    vatDate = oldEntryMap.get(vatKey).AdjustedDate__c;
                }
                comment = oldEntryMap.get(vatKey).Comment__c;
            }

            if (flowMap.containsKey(vatDate)) {
                if (!vatEntryMap.containsKey(vatKey)) {
                    CashFlowEntry__c vatEntry   = new CashFlowEntry__c();
                    vatEntry.CashFlow__c        = flowMap.get(vatDate).Id;
                    vatEntry.Description__c     = 'VAT';
                    vatEntry.Stage__c           = 'Confirmed';
                    vatEntry.Category__c        = 'VAT';
                    vatEntry.Out__c             = true;
                    vatEntry.Amount__c          = 0;
                    vatEntry.QuickbooksId__c    = vatKey;
                    vatEntry.Source__c          = 'Budget';
                    vatEntry.Comment__c         = comment;
                    vatEntryMap.put(vatKey, vatEntry);
                }

                vatEntryMap.get(vatKey).Amount__c += vatAmt;
            }
        }

        newEntries.addAll(vatEntryMap.values());

        // STEP 6: PLOT BUDGET ENTRIES
        for (QBProfitAndLoss__c budgetEntry : budgetMap.values()){

            if (budgetEntry.Actual__c > 0 ){
                Date entryDate  = budgetEntry.Month__c.addMonths(1).addDays(-1);
                String entryKey = budgetEntry.Parent__c + String.valueOf(entryDate);

                Decimal amount  = budgetEntry.Actual__c;

                // determine if the amount on the budget has been manually specified
                if (oldEntryMap.containsKey(entryKey) && oldEntryMap.get(entryKey).AmountAdjusted__c){
                    amount = oldEntryMap.get(entryKey).Amount__c;

                    // offset the budget amount for the current month by determining how far through the month we are
                } else if (budgetEntry.Category__c != 'Payroll' && budgetEntry.Month__c.month() == Date.today().month()){
                    system.debug('offsetting amoutn for ' + budgetEntry.Category__c);
                    Integer daysInMonth = Date.daysInMonth(Date.today().year(),Date.today().month());
                    Integer today       = Date.today().day();
                    Decimal portion     = (Decimal.valueOf(today) / Decimal.valueOf(daysInMonth));
                    amount              = amount * portion;
                }

                String comment  = oldEntryMap.containsKey(entryKey) ? oldEntryMap.get(entryKey).Comment__c : '';

                if (flowMap.containsKey(entryDate)){
                    CashFlowEntry__c flowEntry   = new CashFlowEntry__c();
                    flowEntry.CashFlow__c        = flowMap.get(entryDate).Id;
                    flowEntry.Description__c     = 'Budgeted ' + budgetEntry.Nominal__c;
                    flowEntry.Stage__c           = budgetEntry.Category__c != 'Revenue' &&
                            budgetEntry.Category__c != 'Cost of sales' ?
                            'Confirmed' : 'Budget';
                    flowEntry.BudgetKey__c       = budgetEntry.Parent__c;
                    flowEntry.Category__c        = budgetEntry.Category__c;
                    flowEntry.Out__c             = budgetEntry.Category__c != 'Revenue';
                    flowEntry.Amount__c          = amount;
                    flowEntry.Comment__c         = comment;
                    flowEntry.QuickbooksId__c    = budgetEntry.Parent__c + String.valueOf(entryDate);
                    flowEntry.Source__c          = 'Budget';
                    newEntries.add(flowEntry);
                }
            }
        }

        delete oldEntryMap.values();
        upsert newEntries;

        ////////////// STEP 11 - RECALCULATE BALANCES AND ADD OVERHEAD AMOUNTS TO THE 1ST OF EACH MONTH
        Decimal confirmed   = 0;
        Decimal pipeline    = 0;
        Decimal budget      = 0;

        List<CashFlow__c> flows = [SELECT Id, InConfirmed__c, InPipeline__c, InBudget__c,
                OutConfirmed__c, OutPipeline__c, OutBudget__c,
                Balance__c, BalancePlus__c, BalancePredict__c,
                Number__c
        FROM CashFlow__c
        ORDER BY Number__c ASC];

        for (CashFlow__c flow : flows) {
            if (flow.Number__c == -1){
                confirmed               += startingBalance;
                flow.Balance__c         = startingBalance;
                flow.BalancePlus__c     = startingBalance;
                flow.BalancePredict__c  = startingBalance;
            } else {
                confirmed               += (flow.InConfirmed__c - flow.OutConfirmed__c);
                pipeline                += (flow.InPipeline__c - flow.OutPipeline__c);
                budget                  += (flow.InBudget__c - flow.OutBudget__c);
                flow.Balance__c         = confirmed;
                flow.BalancePlus__c     = confirmed + pipeline;
                flow.BalancePredict__c  = confirmed + pipeline + budget;
            }
        }

        update flows;
    }

}