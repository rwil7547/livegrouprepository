/**
 * Created by Ronan Williams on 24/07/2018.
 */

public class CashFlowReviewController {

    public CashFlowEntry__c newEntry {get; set;}
    public Date newEntryDate {get; set;}
    public String newEntryType {get; set;}
    public String deleteEntryType {get; set;}
    public String adjustedDate {get; set;}
    public Map<Date,CashFlow__c> flowMap {get;set;}
    public String entryId {get; set;}
    public transient Date lastApproval {get; set;}
    public transient Boolean approved {get; set;}
    public transient List<flowEntry> flowEntries {get; set;}
    public transient Decimal currentBalance {get; set;}
    public transient Map<Date,Decimal> inChanges {get;set;}
    public transient Map<Date,Decimal> outChanges {get;set;}
    public transient List<component> inComponents {get; set;}
    public transient List<component> outComponents {get; set;}
    public transient Set<String> inCategory {get; set;}
    public transient Set<String> outCategory {get; set;}
    public transient List<Date> closingDates {get; set;}
    public transient List<Date> openingDates {get; set;}
    public transient List<Date> dateValuesDisplay {get;set;}
    public transient List<List<Object>> revenueAnalysis {get; set;}
    public transient List<Decimal> revenueFigures {get; set;}
    public transient List<List<Object>> cosAnalysis {get; set;}
    public transient List<Decimal> cosFigures {get; set;}
    public transient List<CashFlow__c> overheads {get; set;}
    public transient List<QBSupplierProfile__c> directDebits {get; set;}
    public transient List<QBSupplierProfile__c> freelancers {get; set;}
    public transient List<QBSupplierProfile__c> otherSuppliers {get; set;}
    public transient List<CashFlowEntry__c> firstPaymentRun {get;set;}
    public transient List<CashFlowEntry__c> secondPaymentRun {get;set;}
    public transient List<CashFlowEntry__c> thirdPaymentRun {get;set;}
    public transient List<CashFlowEntry__c> fourthPaymentRun {get;set;}
    public transient List<CashFlowEntry__c> allOtherPayments {get;set;}
    public transient Decimal firstPaymentRunValue {get;set;}
    public transient Decimal secondPaymentRunValue {get;set;}
    public transient Decimal thirdPaymentRunValue {get;set;}
    public transient Decimal fourthPaymentRunValue {get;set;}
    public transient Decimal allOtherPaymentsValue {get;set;}
    public transient Map<String,String> cssStyleMap {get;set;}


    /////////// INNER CLASSES
    public class flowEntry {

        public CashFlow__c flow {get; set;}
        public String dateValue {get; set;}
        public String dayValue {get; set;}

        public flowEntry(CashFlow__c flow){
            this.flow = flow;
            this.dateValue =  flow.Date__c.day() + ' ' +
                    dateTime.newInstance(flow.Date__c.year(), flow.Date__c.month(), flow.Date__c.day()).format('MMM') + ' ' +
                    dateTime.newInstance(flow.Date__c.year(), flow.Date__c.month(), flow.Date__c.day()).format('YY');
            this.dayValue =  dateTime.newInstance(flow.Date__c.year(), flow.Date__c.month(), flow.Date__c.day()).format('EEEE') +
                    ' ' + dateValue;
        }
    }

    public class component {
        public String name {get; set;}
        public Map<Date, Decimal> valueMap {get; set;}
        public Map<Date, String> cssStyles {get; set;}
        // public String cssStyles {get; set;}
        public Map<Date, List<CashFlowEntry__c>> descriptionMap2 {get; set;}

        public void setStyles(String type, Date entryDate){
            if (type == 'Quickbooks' || type == 'Overheads' || type == 'Payroll'){
                cssStyles.put(entryDate,cssStyles.get(entryDate).replace('Q','1'));
            } else if (type == 'Custom'){
                cssStyles.put(entryDate,cssStyles.get(entryDate).replace('C','1'));
            } else if (type == 'Salesforce'){
                cssStyles.put(entryDate,cssStyles.get(entryDate).replace('S','1'));
            } else if (type == 'Salesforce (P)'){
                cssStyles.put(entryDate,cssStyles.get(entryDate).replace('P','1'));
            }
        }

        public component(String name){
            this.name               = name;
            this.valueMap           = new Map<Date, Decimal>();
            this.descriptionMap2    = new Map<Date, List<CashFlowEntry__c>>();
            this.cssStyles          = new Map<Date, String>();
        }
    }


    ///////// CONTROLLER METHODS
    public PageReference insertEntry() {

        newEntry.Category__c = 'Custom';
        newEntry.Source__c = 'Custom';

        if (newEntryType == 'In'){
            newEntry.InFlow__c = flowMap.get(newEntryDate).Id;
            flowMap.get(newEntryDate).In__c += newEntry.Amount__c;
        } else if (newEntryType == 'Out'){
            newEntry.OutFlow__c = flowMap.get(newEntryDate).Id;
            flowMap.get(newEntryDate).Out__c += newEntry.Amount__c;
        }

        insert newEntry;

        updateFlowValues();
        doInit();

        return null;
    }

    public PageReference deleteEntry() {

        CashFlowEntry__c entry;

        if (deleteEntryType == 'Out') {
            entry = [SELECT Amount__c, OutFlow__r.Date__c FROM CashFlowEntry__c WHERE Id = :entryId];
            flowMap.get(entry.OutFlow__r.Date__c).Out__c -= entry.Amount__c;
        } else if (deleteEntryType == 'In'){
            entry = [SELECT Amount__c, InFlow__r.Date__c FROM CashFlowEntry__c WHERE Id = :entryId];
            flowMap.get(entry.InFlow__r.Date__c).In__c -= entry.Amount__c;
        }

        if (entry != null){
            delete entry;
        }

        updateFlowValues();
        doInit();

        return null;
    }

    public PageReference adjustEntry() {

        Date newDate = Date.valueOf(adjustedDate);

        CashFlowEntry__c entry = [SELECT Amount__c, InFlow__c, InFlow__r.Date__c, OutFlow__c, OutFlow__r.Date__c
                                    FROM CashFlowEntry__c WHERE Id = :entryId];

        if (entry.InFlow__c != null){
            entry.Adjusted__c =  true;
            entry.Inflow__c = flowMap.get(newDate).Id;
            flowMap.get(entry.InFlow__r.Date__c).In__c -= entry.Amount__c;
            flowMap.get(newDate).In__c += entry.Amount__c;
        } else if (entry.OutFlow__c != null){
            entry.Adjusted__c =  true;
            entry.OutFlow__c = flowMap.get(newDate).Id;
            flowMap.get(entry.OutFlow__r.Date__c).Out__c -= entry.Amount__c;
            flowMap.get(newDate).Out__c += entry.Amount__c;
        }

        update entry;

        updateFlowValues();
        doInit();

        return null;
    }

    public PageReference approveFlow() {

        // establish whether the current cashflow is still in an approved state
        List<FlowApproval__c> approvals = [SELECT Id, ApprovalDate__c FROM FlowApproval__c WHERE Name = 'Finance'];

        if (!approvals.isEmpty()){
            approvals[0].ApprovalDate__c = Date.today();
            update approvals[0];
        } else {
            FlowApproval__c finance = new FlowApproval__c(Name = 'Finance', ApprovalDate__c = Date.today());
            insert finance;
        }

        doInit();

        return null;
    }

    public PageReference updatePaymentRuns() {

        List<String> paymentMapKeys    = (List<String>)JSON.deserialize(Apexpages.currentPage().getParameters().get('paymentRunKeys'),List<String>.class);
        List<String> paymentMapValues  = (List<String>)JSON.deserialize(Apexpages.currentPage().getParameters().get('paymentRunValues'),List<String>.class);

        Set<Date> paymentRunDates = new Set<Date>();
        for (String dateString : paymentMapValues){
            paymentRunDates.add(Date.valueOf(dateString));
        }

        Map<String,Date> paymentMap = new Map<String,Date>();
        for (Integer x = 0; x < paymentMapKeys.size(); x++){
            paymentMap.put(paymentMapKeys[x],Date.valueOf(paymentMapValues[x]));
        }

        List<CashFlowEntry__c> entriesToUpdate = [SELECT Id, Amount__c, OutFlow__r.Date__c
                                                    FROM CashFlowEntry__c
                                                    WHERE Id IN: paymentMapKeys];

        for (CashFlowEntry__c entry: entriesToUpdate){
            entry.OutFlow__c = flowMap.get(paymentMap.get(entry.Id)).Id;
            entry.Adjusted__c =  true;
            flowMap.get(entry.OutFlow__r.Date__c).Out__c -= entry.Amount__c;
            flowMap.get(paymentMap.get(entry.Id)).Out__c += entry.Amount__c;
        }

        update entriesToUpdate;

        updateFlowValues();
        doInit();

        return null;
    }

    private void updateFlowValues(){

        Decimal balance         = 0;
        Decimal balancePlus     = 0;
        Decimal balancePredict  = 0;

        for (CashFlow__c flow : flowMap.values()){

            balance += (flow.In__c - flow.Out__c);
            balancePlus += (flow.In__c + flow.InPlus__c - flow.Out__c - flow.OutPlus__c);
            balancePredict += (flow.In__c + flow.InPlus__c + flow.InPredict__c - flow.Out__c - flow.OutPlus__c - flow.OutPredict__c);
            flow.Balance__c = balance;
            flow.BalancePlus__c = balancePlus;
            flow.BalancePredict__c = balancePredict;
        }

        update flowMap.values();
    }

    private void doInit(){

        // INITIALISE NEW ENTRY FORM CONTENT
        newEntry = new CashFlowEntry__c();

        // INITIALISE EXCEL VIEW ROW HEADERS
        inChanges           = new Map<Date,Decimal>();
        outChanges          = new Map<Date,Decimal>();
        inCategory          = new Set<String>();
        outCategory         = new Set<String>();

        inComponents        = new List<component>();
        outComponents       = new List<component>();
        flowMap             = new Map<Date,CashFlow__c>();
        overheads           = new List<CashFlow__c>();

        firstPaymentRun     = new List<CashFlowEntry__c>();
        secondPaymentRun    = new List<CashFlowEntry__c>();
        thirdPaymentRun     = new List<CashFlowEntry__c>();
        fourthPaymentRun    = new List<CashFlowEntry__c>();
        allOtherPayments    = new List<CashFlowEntry__c>();

        firstPaymentRunValue    = 0;
        secondPaymentRunValue   = 0;
        thirdPaymentRunValue    = 0;
        fourthPaymentRunValue   = 0;
        allOtherPaymentsValue   = 0;


        Map<String,component> inComponentMap    = new Map<String,component>();
        Map<String,component> outComponentMap   = new Map<String,component>();


        cssStyleMap = new Map<String,String>();
        cssStyleMap.put('QCSP','background: linear-gradient(to right, #ffffff 25%, #ffffff 25%, #ffffff 50%, #ffffff 50%, #ffffff 75%, #ffffff 75%);');
        cssStyleMap.put('1CSP','background: linear-gradient(to right, #008b00 25%, #008b00 25%, #008b00 50%, #008b00 50%, #008b00 75%, #008b00 75%);');
        cssStyleMap.put('Q1SP','background: linear-gradient(to right, #ffff00 25%, #ffff00 25%, #ffff00 50%, #ffff00 50%, #ffff00 75%, #ffff00 75%);');
        cssStyleMap.put('QC1P','background: linear-gradient(to right, #0099ff 25%, #0099ff 25%, #0099ff 50%, #0099ff 50%, #0099ff 75%, #0099ff 75%);');
        cssStyleMap.put('QCS1','background: linear-gradient(to right, #d3d3d3 25%, #d3d3d3 25%, #d3d3d3 50%, #d3d3d3 50%, #d3d3d3 75%, #d3d3d3 75%);');
        cssStyleMap.put('11SP','background: linear-gradient(to right, #008b00 25%, #008b00 25%, #008b00 50%, #ffff00 50%, #ffff00 75%, #ffff00 75%);');
        cssStyleMap.put('111P','background: linear-gradient(to right, #008b00 33%, #0099ff 33%, #0099ff 66%, #ffff00 66%);');
        cssStyleMap.put('1111','background: linear-gradient(to right, #008b00 25%, #ffff00 25%, #ffff00 50%, #0099ff 50%, #0099ff 75%, #d3d3d3 75%);');
        cssStyleMap.put('Q111','background: linear-gradient(to right, #ffff00 33%, #0099ff 33%, #0099ff 66%, #d3d3d3 66%);');
        cssStyleMap.put('QC11','background: linear-gradient(to right, #0099ff 25%, #0099ff 25%, #0099ff 50%, #d3d3d3 50%, #d3d3d3 75%, #d3d3d3 75%);');
        cssStyleMap.put('1CS1','background: linear-gradient(to right, #008b00 25%, #008b00 25%, #008b00 50%, #d3d3d3 50%, #d3d3d3 75%, #d3d3d3 75%);');
        cssStyleMap.put('Q11P','background: linear-gradient(to right, #ffff00 25%, #ffff00 25%, #ffff00 50%, #0099ff 50%, #0099ff 75%, #0099ff 75%);');
        cssStyleMap.put('1C1P','background: linear-gradient(to right, #008b00 25%, #008b00 25%, #008b00 50%, #0099ff 50%, #0099ff 75%, #0099ff 75%);');
        cssStyleMap.put('Q1S1','background: linear-gradient(to right, #ffff00 25%, #ffff00 25%, #ffff00 50%, #d3d3d3 50%, #d3d3d3 75%, #d3d3d3 75%);');
        cssStyleMap.put('11S1','background: linear-gradient(to right, #008b00 33%, #ffff00 33%, #ffff00 66%, #d3d3d3 66%);');
        cssStyleMap.put('1C11','background: linear-gradient(to right, #008b00 33%, #0099ff 33%, #0099ff 66%, #d3d3d3 66%);');


        ///////////////////
        // OPENING DATES
        openingDates = new List<Date>();
        Date entryDate = (Date.today() > Date.today().toStartOfWeek().addDays(2)) ?
                Date.today().toStartOfWeek().addDays(9) : Date.today().toStartOfWeek().addDays(2);
        Date lastEntryDate;

        for (Integer x = 0; x < 11; x++){
            openingDates.add(entryDate);
            entryDate = entryDate.addDays(7);
        }


        // CLOSING DATES
        closingDates = new List<Date>();
        Date closingDate = (Date.today() > Date.today().toStartOfWeek().addDays(2)) ?
                Date.today().toStartOfWeek().addDays(9) : Date.today().toStartOfWeek().addDays(2);

        for (Integer x = 0; x < 12; x++){
            closingDates.add(closingDate);
            inChanges.put(closingDate, 0);
            outChanges.put(closingDate, 0);
            if (x == 11) {
                lastEntryDate = closingDate;
            }
            closingDate = closingDate.addDays(7);
        }

        dateValuesDisplay = new List<Date>();
        Date displayDate = Date.today().toStartOfWeek().addDays(2);

        if (displayDate >= Date.today()) {
            displayDate = displayDate.addDays(-7);
        }

        for (Integer x = 0; x < 12; x++){
            dateValuesDisplay.add(displayDate);
            displayDate = displayDate.addDays(7);
        }

        flowEntries = new List<flowEntry>();

        List<CashFlow__c> flows = [SELECT Id, Date__c, In__c, Out__c, InPlus__c, OutPlus__c,
                                            InPredict__c, OutPredict__c, Balance__c, BalancePlus__c,
                                            BalancePredict__c, Number__c, Overhead__c,
                                            (SELECT Id, Description__c, Details__c, Source__c, Category__c,
                                                    Amount__c, Adjusted__c, QuickbooksId__c
                                            FROM InEntries__r ORDER BY Source__c ),
                                            (SELECT Id, Description__c, Details__c, Source__c, Category__c,
                                                    Amount__c, Adjusted__c, QuickbooksId__c
                                            FROM OutEntries__r ORDER BY Source__c)
                                    FROM CashFlow__c
                                    ORDER BY Date__c ASC];

        for (CashFlow__c flow : flows) {
            flowMap.put(flow.Date__c, flow);
            flowEntries.add(new flowEntry(flow));

            if (flow.Date__c <= lastEntryDate) {
                for (CashFlowEntry__c entry : flow.InEntries__r) {
                    if (entry.Category__c != 'Current Balance') {
                        inCategory.add(entry.Category__c);
                    } else {
                        currentBalance = entry.Amount__c;
                    }
                }
                for (CashFlowEntry__c entry : flow.OutEntries__r) {
                    outCategory.add(entry.Category__c);
                }
            }

            if (flow.Date__c.day() == Date.daysInMonth(flow.Date__c.year(),flow.Date__c.month())){
                overheads.add(flow);
            }

            for (CashFlowEntry__c entry : flow.OutEntries__r){
                if ((entry.Category__c == 'Payment run' || entry.Category__c == 'Direct debit' || entry.Category__c == 'Custom')
                        && (entry.Source__c == 'Custom' || entry.Source__c == 'Quickbooks')){
                    if (flow.Date__c <= openingDates[0].addDays(1)){
                        firstPaymentRun.add(entry);
                        firstPaymentRunValue += entry.Amount__c;
                    } else if (flow.Date__c <= openingDates[1].addDays(1)){
                        secondPaymentRun.add(entry);
                        secondPaymentRunValue += entry.Amount__c;
                    } else if (flow.Date__c <= openingDates[2].addDays(1)){
                        thirdPaymentRun.add(entry);
                        thirdPaymentRunValue += entry.Amount__c;
                    } else if (flow.Date__c <= openingDates[3].addDays(1)){
                        fourthPaymentRun.add(entry);
                        fourthPaymentRunValue += entry.Amount__c;
                    } else {
                        allOtherPayments.add(entry);
                        allOtherPaymentsValue += entry.Amount__c;
                    }
                }
            }
        }

        for (String category : inCategory){
            component con = new component(category);

            for (Date dateVal : closingDates){
                con.valueMap.put(dateVal, 0);
                con.descriptionMap2.put(dateVal, new List<CashFlowEntry__c>());
                con.cssStyles.put(dateVal, 'QCSP');
            }
            inComponentMap.put(con.name,con);
        }

        for (String category : outCategory){
            component con = new component(category);

            for (Date dateVal : closingDates){
                con.valueMap.put(dateVal, 0);
                con.descriptionMap2.put(dateVal, new List<CashFlowEntry__c>());
                con.cssStyles.put(dateVal, 'QCSP');
            }
            outComponentMap.put(con.name, con);
        }

        for (CashFlow__c flow : flows) {
            if (flow.Date__c <= lastEntryDate) {
                //////////////////////////
                Date flowDate;
                if (flow.Date__c == Date.today()) {
                    //flowDate = flow.Date__c;
                    flowDate = closingDates[0];
                } else if (flow.Date__c.toStartOfWeek().addDays(2) <= Date.today()) {
                    flowDate = flow.Date__c.toStartOfWeek().addDays(9);
                } else if (flow.Date__c.toStartOfWeek().addDays(2) < flow.Date__c) {
                    flowDate = flow.Date__c.toStartOfWeek().addDays(9);
                }else {
                    flowDate = flow.Date__c.toStartOfWeek().addDays(2);
                }
                //////////////////////////

                for (CashFlowEntry__c entry : flow.InEntries__r) {
                    if (entry.Category__c != 'Current Balance' && inComponentMap.get(entry.Category__c).valueMap.containsKey(flowDate)) {
                        inComponentMap.get(entry.Category__c).valueMap.put(flowDate, inComponentMap.get(entry.Category__c).valueMap.get(flowDate) + entry.Amount__c);
                        inComponentMap.get(entry.Category__c).descriptionMap2.get(flowDate).add(entry);
                        inComponentMap.get(entry.Category__c).setStyles(entry.Source__c,flowDate);
                        if (inChanges.containsKey(flowDate)) {
                            inChanges.put(flowDate, inChanges.get(flowDate) + entry.Amount__c);
                        }
                    }
                }
                for (CashFlowEntry__c entry : flow.OutEntries__r) {
                    if (outComponentMap.get(entry.Category__c).valueMap.containsKey(flowDate)) {
                        outComponentMap.get(entry.Category__c).valueMap.put(flowDate,
                                outComponentMap.get(entry.Category__c).valueMap.get(flowDate) + entry.Amount__c);
                        outComponentMap.get(entry.Category__c).descriptionMap2.get(flowDate).add(entry);
                        outComponentMap.get(entry.Category__c).setStyles(entry.Source__c,flowDate);
                        if (outChanges.containsKey(flowDate)) {
                            outChanges.put(flowDate, outChanges.get(flowDate) + entry.Amount__c);
                        }
                    }
                }
            }
        }

        inComponents    = inComponentMap.values();
        outComponents   = outComponentMap.values();

        revenueAnalysis = new List<List<Object>>();
        revenueFigures  = new List<Decimal>{0,0,0,0,0,0};
        cosAnalysis     = new List<List<Object>>();
        cosFigures      = new List<Decimal>{0,0,0,0,0,0};

        Date startDate  = Date.today().addMonths(-6).toStartOfMonth();
        Date endDate    = Date.today().addMonths(13).toStartOfMonth();

        List<AggregateResult> revenueAggregates = [SELECT Event_End_Grouping__c Month,
                                                        SUM(Amount_Invoiced2__c) Invoiced,
                                                        SUM(Amount_Paid__c) Paid,
                                                        SUM(Amount_Calder__c) Amount,
                                                        SUM(Filtered_Cost_of_Sale__c) Cos,
                                                        SUM(Quickbooks_COS__c) QBOCos,
                                                        SUM(Quickbooks_COS_Paid__c) QBOCosPaid
                                                FROM Opportunity
                                                WHERE StageName = 'Closed Won'
                                                AND Event_end__c >= :startDate
                                                AND Event_end__c < :endDate
                                                GROUP BY Event_End_Grouping__c
                                                ORDER BY Event_End_Grouping__c ASC];

        Integer resultsAdded = 0;

        for (AggregateResult ar : revenueAggregates){
            if ((Decimal)ar.get('Amount') > 0) {
                resultsAdded += 1;
                System.debug((Date) ar.get('Month'));

                Date arDate = (Date) ar.get('Month');
                String monthString = dateTime.newInstance(arDate.year(), arDate.month(), arDate.day()).format('MMM') + ' ' +
                        dateTime.newInstance(arDate.year(), arDate.month(), arDate.day()).format('YY');

                List<Object> revResults = new List<Object>();
                revResults.add(monthString);
                revResults.add((Decimal) ar.get('Paid'));
                revResults.add((Decimal) ar.get('Invoiced') - (Decimal) ar.get('Paid'));
                revResults.add((Decimal) ar.get('Amount') - (Decimal) ar.get('Invoiced'));
                revResults.add(',');
                revenueAnalysis.add(revResults);

                List<Object> cosResults = new List<Object>();
                cosResults.add(monthString);
                cosResults.add((Decimal) ar.get('QBOCosPaid'));
                cosResults.add((Decimal) ar.get('QBOCos') - (Decimal) ar.get('QBOCosPaid'));
                cosResults.add((Decimal) ar.get('Cos') - (Decimal) ar.get('QBOCos'));
                cosResults.add(',');
                cosAnalysis.add(cosResults);

                if (arDate < Date.today().toStartOfMonth()){
                    revenueFigures[0] += ((Decimal) ar.get('Amount') - (Decimal) ar.get('Invoiced'));
                    revenueFigures[1] += ((Decimal) ar.get('Amount') - (Decimal) ar.get('Paid'));
                    cosFigures[0] += ((Decimal) ar.get('Cos') - (Decimal) ar.get('QBOCos'));
                    cosFigures[1] += ((Decimal) ar.get('Cos') - (Decimal) ar.get('QBOCosPaid'));
                } else {
                    revenueFigures[2] += ((Decimal) ar.get('Amount') - (Decimal) ar.get('Invoiced'));
                    revenueFigures[3] += ((Decimal) ar.get('Amount') - (Decimal) ar.get('Paid'));
                    cosFigures[2] += ((Decimal) ar.get('Cos') - (Decimal) ar.get('QBOCos'));
                    cosFigures[3] += ((Decimal) ar.get('Cos') - (Decimal) ar.get('QBOCosPaid'));
                }
                revenueFigures[4] += ((Decimal) ar.get('Amount') - (Decimal) ar.get('Invoiced'));
                revenueFigures[5] += ((Decimal) ar.get('Amount') - (Decimal) ar.get('Paid'));
                cosFigures[4] += ((Decimal) ar.get('Cos') - (Decimal) ar.get('QBOCos'));
                cosFigures[5] += ((Decimal) ar.get('Cos') - (Decimal) ar.get('QBOCosPaid'));
            }
        }
        revenueAnalysis[revenueAnalysis.size()-1].remove(4);
        revenueAnalysis[revenueAnalysis.size()-1].add('');
        cosAnalysis[cosAnalysis.size()-1].remove(4);
        cosAnalysis[cosAnalysis.size()-1].add('');

        System.debug('results added total is ' + resultsAdded);

        newEntryType = 'Out';

        // establish whether the current cashflow is still in an approved state
        List<FlowApproval__c> approvals = [SELECT Id, ApprovalDate__c FROM FlowApproval__c WHERE Name = 'Finance'];

        if (!approvals.isEmpty()){
            lastApproval = approvals[0].ApprovalDate__c;
        } else {
            FlowApproval__c finance = new FlowApproval__c(Name = 'Finance');
            insert finance;
        }

        if (lastApproval != null && lastApproval > Date.today().addDays(-7)){
            approved = true;
        }

        System.debug('state of approval is ' + approved);

        directDebits = new List<QBSupplierProfile__c>();
        freelancers = new List<QBSupplierProfile__c>();
        otherSuppliers = new List<QBSupplierProfile__c>();

        for (QBSupplierProfile__c sp : [SELECT Id, Name, Category__c, Frequency__c, FrequencyText__c,
                                               Day__c, Split__c, Terms__c, LastAmount__c,
                                               LastInstance__c, NextInstance__c
                                        FROM QBSupplierProfile__c]){
            if (sp.Terms__c == 'Direct debit'){
                directDebits.add(sp);
            } else if (sp.Category__c == 'Freelancers'){
                freelancers.add(sp);
            } else {
                otherSuppliers.add(sp);
            }
        }
    }


    public CashFlowReviewController() {

        doInit();

    }
}