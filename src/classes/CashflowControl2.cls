/**
 * Created by Ronan Williams on 25/03/2019.
 */

public with sharing class CashflowControl2 {


    public static void buildFlow(Boolean resetValues){

        // get the cashflow entries
        Map<Date, CashFlow__c> flowMap            = CashFlowUtils.getFlowMap();

//        // get the date of the end of the next financial year
//        Date cashflowEnd = Date.today().month() < 4 ?
//                           Date.newInstance(Date.today().year() + 1, 31,3) :
//                           Date.newInstance(Date.today().year() + 2, 31,3);


        Map<String,Date> adjustmentsMap           = new Map<String,Date>();
        Map<String,Decimal> amountAdjustmentsMap  = new Map<String,Decimal>();

        Decimal startingBalance = 0;


        Map<String,QBProfitAndLoss__c> budgetMap = new Map<String,QBProfitAndLoss__c>();

        for (QBProfitAndLoss__c pnl : [SELECT Id, Month__c, Parent__c, Actual__c, Category__c, Nominal__c
                                        FROM QBProfitAndLoss__c
                                        WHERE Month__c >= :Date.today().toStartOfMonth()]){
            String budgetKey = String.valueOf(pnl.Month__c.month()) + String.valueOf(pnl.Month__c.year()) + pnl.Parent__c;
            budgetMap.put(budgetKey,pnl);
        }

        Set<String> adjustedIds           = new Set<String>();

        List<CashFlowEntry__c> oldEntries = new List<CashFlowEntry__c>();
        List<CashFlowEntry__c> newEntries = new List<CashFlowEntry__c>();

        for (CashFlowEntry__c entry : [SELECT Id, Amount__c, AmountAdjusted__c, Adjusted__c, Paid__c,
                                                QuickbooksId__c, OutFlow__c, InFlow__c, AdjustedDate__c,
                                                OutFlow__r.Date__c, InFlow__r.Date__c, Description__c
                                        FROM CashFlowEntry__c]){
            if (resetValues && entry.Adjusted__c){
                if (flowMap.containsKey(entry.AdjustedDate__c)){
                    entry.CashFlow__c = flowMap.get(entry.AdjustedDate__c).Id;
                    newEntries.add(entry);
                    adjustedIds.add(entry.QuickbooksId__c);
                }
            } else {
                oldEntries.add(entry);
            }
        }

        // get direct debit and freelancer supplier profiles
        Map<String,QBSupplierProfile__c> directDebits   = new Map<String,QBSupplierProfile__c>();
        Set<String> freelancerIds                       = new Set<String>();
        for (QBSupplierProfile__c profile : [SELECT Id, Amount__c, EndDate__c, Day__c,
                                                Frequency__c, SupplierId__c, Terms__c, Type__c
                                            FROM QBSupplierProfile__c]){
            if (profile.Type__c == 'DD'){
                directDebits.put(profile.SupplierId__c, profile);
            } else if (profile.Type__c == 'Freelancers'){
                freelancerIds.add(profile.SupplierId__c);
            }
        }

        // INIT: GET CURRENT BALANCE
        String query1 = 'query?query=select%20%2a%20from%20account%20where%20name%20' +
                '%3d%20%27Bank%20Current%20Account%27&minorversion=4';

        // do callout
        Http http1              = new Http();
        HttpRequest request1    = CashFlowUtils.doCallout(query1);
        HttpResponse response1  = http1.send(request1);

        if (response1.getStatusCode() == 200) {
            JSONParserQBOCurrentAccount parsedResults = JSONParserQBOCurrentAccount.parse(response1.getBody());
            startingBalance = parsedResults.QueryResponse.Account[0].CurrentBalance;


//                newEntries.add(new CashFlowEntry__c(
//                        CashFlow__c     = flowMap.get(Date.today()).Id,
//                        Source__c       = 'Quickbooks',
//                        Amount__c       = balance,
//                        QuickbooksId__c = 'balance',
//                        Stage__c        = 'Confirmed'));

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

                    Decimal balance  = (creditMap.containsKey(inv.Id)) ? inv.Balance - creditMap.get(inv.Id) : inv.Balance;
                    Date dueDate     = adjustmentsMap.containsKey(inv.Id) ? adjustmentsMap.get(inv.Id) : Date.valueOf(inv.DueDate);

                    if (!adjustedIds.contains(inv.Id)){
                        if (dueDate < Date.today()) {
                            Integer random = Integer.valueOf(Math.random() * 100);
                            dueDate = Date.today().addDays(1).addDays(random);
                        }

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
                                    Adjusted__c     = adjustmentsMap.containsKey(inv.Id)));
                        }
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
                                                    Name, Job_Number__c, Opportunity__r.Account.Name
                                                FROM Invoice_Schedule__c
                                                WHERE Invoice_Sent__c = FALSE
                                                AND Invoice_Paid__c = FALSE
                                                AND Opportunity__r.Event_end__c >= LAST_N_MONTHS:12];

        for (Invoice_Schedule__c schedule : schedules) {

            Date dueDate    = adjustmentsMap.containsKey(schedule.Id) ? adjustmentsMap.get(schedule.Id) : schedule.Send_Date__c.addDays(30);

            if (dueDate < Date.today().addDays(35)){
                Integer random = Integer.valueOf(Math.random() * 100);
                dueDate = Date.today().addDays(35).addDays(random);
            }

            if (!adjustedIds.contains(schedule.Id)){
                if (flowMap.containsKey(dueDate)) {
                    newEntries.add(new CashFlowEntry__c(
                            CashFlow__c     = flowMap.get(dueDate).Id,
                            Source__c       = 'Salesforce',
                            Category__c     = schedule.Opportunity__r.Account.Name,
                            Description__c  = schedule.Opportunity__r.Name + ' ' + schedule.Name,
                            QuickbooksId__c = schedule.Id,
                            Stage__c        = 'Confirmed',
                            Amount__c       = (schedule.Amount__c * 1.2).setScale(2)));
                }
            }

            String budgetKey = String.valueOf(dueDate.month()) + String.valueOf(dueDate.year()) + 'Revenue';
            if (budgetMap.containsKey(budgetKey)){
                budgetMap.get(budgetKey).Actual__c -= (schedule.Amount__c * 1.2).setScale(2);
            }
        }

//        // GET QUICKBOOKS BILL ATTACHMENT MAP
//        Map<String,String> attachmentMap = new Map<String,String>();
//
//        String attachmentQuery = 'query?query=select%20%2a%20from%20attachable%20where%20AttachableRef.EntityRef.type%20' +
//                '%3d%20%27Bill%27%20and%20MetaData.CreateTime%20%3e%20%272019-02-01%27%20and%20ContentType%20%3d%20%27ap' +
//                'plication%2fpdf%27%20maxResults%201000&minorversion=4';
//        // do callout
//        Http attachmentHttp               = new Http();
//        HttpRequest attachmentRequest     = CashFlowUtils.doCallout(attachmentQuery);
//        HttpResponse attachmentResponse   = attachmentHttp.send(attachmentRequest);
//
//        if (attachmentResponse.getStatusCode() == 200){
//            Map<String,Object> queryMap         = (Map<String,Object>)JSON.deserializeUntyped(attachmentResponse.getBody());
//            Map<String,Object> attachmentArray  = (Map<String,Object>)queryMap.get('QueryResponse');
//            List<Object> records                = (List<Object>)attachmentArray.get('Attachable');
//
//            for (Object record : records){
//                Map<String,Object> fieldMap      = (Map<String,Object>)record;
//                List<Object> attachableRef       = (List<Object>)fieldMap.get('AttachableRef');
//                Map<String,Object> attachableRefMap = (Map<String,Object>)attachableRef[0];
//                Map<String,Object> values        = (Map<String,Object>)attachableRefMap.get('EntityRef');
//                String billId                    = (String)values.get('value');
//                String tempDownloadUri           = (String)fieldMap.get('TempDownloadUri');
//                attachmentMap.put(billId,tempDownloadUri);
//
//                system.debug(tempDownloadUri);
//            }
//        }

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

                        Date dueDate = adjustmentsMap.containsKey(bill.Id) ?
                                adjustmentsMap.get(bill.Id) : Date.valueOf(bill.DueDate);

                        if (dueDate <= Date.today()) {
                            dueDate = Date.today().addDays(1);
                        }

                        String details = (Date.valueOf(bill.DueDate) < Date.today()) ?
                                'Aged: due ' + Date.valueOf(bill.DueDate).daysBetween(Date.today()) + ' days ago' :
                                (Date.valueOf(bill.DueDate) == Date.today()) ?
                                        'Officially due today' :
                                        'Officially due in ' + Date.today().daysBetween(Date.valueOf(bill.DueDate)) + ' days';

                        String category = freelancerIds.contains(bill.VendorRef.value) ?
                                        'Freelancers' : bill.VendorRef.name == 'Barclaycard' ?
                                        'Credit Card' : 'Payment run';

                        newEntries.add(new CashFlowEntry__c(
                                CashFlow__c         = flowMap.get(dueDate).Id,
                                Out__c              = true,
                                Source__c           = 'Quickbooks',
                                Stage__c            = 'Confirmed',
                                Category__c         = category,
                                Description__c      = bill.VendorRef.name,
                                Details__c          = details,
                                Amount__c           = bill.Balance,
                                QuickbooksId__c     = bill.Id,
                                VendorRef__c        = bill.VendorRef.value,
//                                TempDownloadUri__c  = attachmentMap.containsKey(bill.Id) ? attachmentMap.get(bill.Id) : '',
                                Adjusted__c         = (adjustmentsMap.containsKey(bill.Id)) ? true : false));

                        for (JSONParserQBOBillFlow.cls_Line line : bill.Line){
                            String account = line.AccountBasedExpenseLineDetail.AccountRef.name.split(' ',2)[1].split(':',2)[0];
                            String budgetKey = String.valueOf(dueDate.month()) + String.valueOf(dueDate.year()) + account;
                            if (budgetMap.containsKey(budgetKey)){
                                budgetMap.get(budgetKey).Actual__c -= line.Amount;
                            }
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
                Integer random              = Integer.valueOf(Math.random() * 100);
                Date paymentDate            = (opp.Event_end__c < Date.today().addDays(35)) ?
                                                Date.today().addDays(35).addDays(random).toStartOfWeek().addDays(3) :
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
                if (!adjustedIds.contains(opp.Id + 'Invoice')){
                    newEntries.add(new CashFlowEntry__c(
                            CashFlow__c     = flowMap.get(inDate).Id,
                            Source__c       = 'SalesforceP',
                            Category__c     = opp.Account.Name,
                            Description__c  = 'Prob. ' + opp.Probability + '% : ' + opp.Name,
                            Details__c      = 'System generated payment date using weighted amount \n' +
                                    'Last activity by ' + opp.LastModifiedBy.Name + ' ' +
                                    Date.valueOf(opp.LastModifiedDate).daysBetween(Date.today()) + ' days ago',
                            Stage__c        = 'Pipeline',
                            QuickbooksId__c = opp.Id + 'Invoice',
                            Amount__c       = inAmount));
                }

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
                            Amount__c       = outAmount));
                }

                String budgetKey = String.valueOf(ouDate.month()) + String.valueOf(ouDate.year()) + 'Cost of Sales';
                if (budgetMap.containsKey(budgetKey)){
                    budgetMap.get(budgetKey).Actual__c -= inAmount;
                }
            }
        }

        newEntries.addAll(pipelineCosEntries.values());


        // STEP 7: PLOT SUPPLIER PROFILES
        // DIRECT DEBIT

//        List<QBSupplierProfile__c> directDebits = [SELECT Id, Amount__c, EndDate__c, Day__c,
//                                                        Frequency__c, SupplierId__c
//                                                    FROM QBSupplierProfile__c];



        // VAT
        Map<String,CashFlowEntry__c> vatEntryMap = new Map<String,CashFlowEntry__c>();

        for (AggregateResult ar : [SELECT SUM(Actual__c)actual, FISCAL_QUARTER(Month__c)quarter,
                                        FISCAL_YEAR(Month__c)year, Category__c
                                    FROM QBProfitAndLoss__c
                                    WHERE (Category__c = 'Revenue' OR Category__c = 'Cost of sales' OR Category__c = 'Expense')
                                    AND Month__c <= NEXT_FISCAL_YEAR
                                    AND Month__c >= LAST_N_MONTHS:3
                                    GROUP BY Category__c,FISCAL_YEAR(Month__c), FISCAL_QUARTER(Month__c)]) {

            String vatKey   = String.valueOf((Integer) ar.get('quarter')) + String.valueOf((Integer) ar.get('year'));
            Integer year    = (Integer) ar.get('year');
            Integer quarter = (Integer) ar.get('quarter');
            Date vatYear    = Date.newInstance(year, 01, 15);
            Date vatDate    = vatYear.addMonths((quarter * 3) + 4);
            Decimal sum     = ar.get('actual') != null ? (Decimal) ar.get('actual') : 0;
            Decimal vatAmt  = (String) ar.get('Category__c') == 'Revenue' ? sum * 0.2 : (sum * -1) * 0.15;

            if (flowMap.containsKey(vatDate)) {
                if (!vatEntryMap.containsKey(vatKey)) {

                    system.debug('plotting vat entry with vat date of ' + vatDate);

                    CashFlowEntry__c vatEntry   = new CashFlowEntry__c();
                    vatEntry.CashFlow__c        = flowMap.get(vatDate).Id;
                    vatEntry.Description__c     = 'VAT';
                    vatEntry.Stage__c           = 'Confirmed';
                    vatEntry.Category__c        = 'VAT';
                    vatEntry.Out__c             = true;
                    vatEntry.Amount__c          = 0;
                    vatEntry.QuickbooksId__c    = vatKey;
                    vatEntry.Source__c          = 'Budget';
                    vatEntryMap.put(vatKey, vatEntry);
                }

                vatEntryMap.get(vatKey).Amount__c += vatAmt;
            }
        }

        System.debug('vat entries ' + vatEntryMap);

        newEntries.addAll(vatEntryMap.values());



        // STEP 6: PLOT REMAINING BUDGET ENTRIES
        for (QBProfitAndLoss__c budgetEntry : budgetMap.values()){

            if (budgetEntry.Actual__c > 0 ){
                Date entryDate = budgetEntry.Month__c.addMonths(1).addDays(-1);

                if (flowMap.containsKey(entryDate)){
                    CashFlowEntry__c flowEntry   = new CashFlowEntry__c();
                    flowEntry.CashFlow__c        = flowMap.get(entryDate).Id;
                    flowEntry.Description__c     = 'Budgeted ' + budgetEntry.Nominal__c;
                    flowEntry.Stage__c           = budgetEntry.Category__c == 'Revenue' ? 'Confirmed' : 'Budget';
                    flowEntry.Category__c        = budgetEntry.Category__c;
                    flowEntry.Out__c             = budgetEntry.Category__c != 'Revenue';
                    flowEntry.Amount__c          = budgetEntry.Actual__c;
                    flowEntry.QuickbooksId__c    = budgetEntry.Parent__c;
                    flowEntry.Source__c          = 'Budget';
                    newEntries.add(flowEntry);
                }
            }
        }

        delete oldEntries;
        upsert newEntries;

        // CREDIT CARD


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

            if (flow.Number__c == 0){

//                system.debug('setting initial balance value of ' + startingBalance);

                confirmed           += startingBalance;

                flow.InDescription__c = String.valueOf(startingBalance);

                flow.Balance__c     = startingBalance;
                flow.BalancePlus__c = startingBalance;
                flow.BalancePredict__c = startingBalance;
            } else {
                confirmed           += (flow.InConfirmed__c - flow.OutConfirmed__c);
                pipeline            += (flow.InPipeline__c - flow.OutPipeline__c);
                budget              += (flow.InBudget__c - flow.OutBudget__c);
                flow.Balance__c     = confirmed;
                flow.BalancePlus__c = confirmed + pipeline;
                flow.BalancePredict__c = confirmed + pipeline + budget;
            }
        }

        update flows;
    }

}