/**
 * Created by Ronan Williams on 05/03/2019.
 */

public class InsightsController {

    private static Map<String,List<Decimal>> buildMap(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);
        Map<Integer,String> monthsMap = new Map<Integer,String>{
                1 => 'Jan',2 => 'Feb',3 => 'Mar',4 => 'Apr',5 => 'May',6 => 'Jun',
                7 => 'Jul',8 => 'Aug',9 => 'Sep',10 => 'Oct',11 => 'Nov',12 => 'Dec'
        };


        Map<String,List<Decimal>> objectAggregates = new Map<String,List<Decimal>>();
        Date incrementDate  = startDate;
        List<String> months = new List<String>();

        while (incrementDate < endDate.addMonths(1).toStartOfMonth().addDays(-1)){

            objectAggregates.put(monthsMap.get(incrementDate.month()) + ' ' +
                    incrementDate.year(), new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0,0});
            months.add(monthsMap.get(incrementDate.month()) + ' ' +
                    incrementDate.year());
            incrementDate = incrementDate.addMonths(1);
        }

        return objectAggregates;
    }

    @RemoteAction
    public static Map<Date, List<Object>> getBalances(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);
        Map<Date, List<Object>> balanceMap = new Map<Date, List<Object>>();
        Date iterator = startDate;

        // populate object map with blank values
        while (iterator <= endDate){
            balanceMap.put(iterator, new List<Object>{'',null,null,null,null});
            iterator = iterator.addDays(1);
        }

        // add any historical balances which fit in the date range
        for (QBBalance__c b : [SELECT Date__c, DayMonthYear__c, Confirmed__c, Weighted__c,
                Predictive__c
        FROM QBBalance__c
        WHERE Date__c >= :startDate
        AND Date__c <= :endDate
        ORDER BY Date__c ASC]){

            balanceMap.get(b.Date__c)[0] = b.DayMonthYear__c;
            balanceMap.get(b.Date__c)[1] = b.Confirmed__c;
            balanceMap.get(b.Date__c)[2] = 0;
            balanceMap.get(b.Date__c)[3] = 0;
            balanceMap.get(b.Date__c)[4] = 0;
        }

        // add any forecast balances which fit in the date range
        for (CashFlow__c c : [SELECT Date__c, DayMonthYear__c, Balance__c, BalancePlus__c,
                                        BalancePredict__c
                                FROM CashFlow__c
                                WHERE Date__c >= :startDate
                                AND Date__c <= :endDate]){

            balanceMap.get(c.Date__c)[0] = c.DayMonthYear__c;
            balanceMap.get(c.Date__c)[1] = c.Date__c == Date.today().addDays(-1) ? c.Balance__c : 0;
            balanceMap.get(c.Date__c)[2] = c.Balance__c;
            balanceMap.get(c.Date__c)[3] = c.BalancePlus__c;
            balanceMap.get(c.Date__c)[4] = c.BalancePredict__c;

        }

        return balanceMap;
    }

    @RemoteAction
    public static Map<String,Object> getOppRecords(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,Object> figuresMap                   = new Map<String,Object>();
        Map<String,List<Decimal>> revenueAggregates     = buildMap(start,endD);
        Map<String,List<Decimal>> profitAggregates      = buildMap(start,endD);
        Map<String,List<Decimal>> opexAggregates        = buildMap(start,endD);
        Map<String,List<Decimal>> netProfitAggregates   = buildMap(start,endD);
        Map<String,List<Decimal>> qbRevenueAggregates   = buildMap(start,endD);
        Map<String,List<Decimal>> qbProfitAggregates    = buildMap(start,endD);
        Map<String,Map<String,List<Object>>> reportData = new Map<String,Map<String,List<Object>>>();
        Map<String,Map<String,Decimal>> reportValues    = new Map<String,Map<String,Decimal>>();
        Set<String> nominalStrings                      = new Set<String>();

        Map<String,Decimal> totals                      = new Map<String,Decimal>();
        Decimal totalRevenue    = 0;
        Decimal totalProfit     = 0;
        Decimal totalOpex       = 0;

        // work out if start date and end date are not clean start and end dates
        Decimal numberOfDaysStart   = Date.daysInMonth(startDate.year(), startDate.month());
        Decimal daysMissing         = startDate.day() - 1;
        Decimal startPortion        = (numberOfDaysStart - daysMissing) / numberOfDaysStart;

        Decimal numberOfDaysEnd     = Date.daysInMonth(endDate.year(), endDate.month());
        Decimal dayCountEnd         = endDate.day();
        Decimal endPortion          = (numberOfDaysEnd - (numberOfDaysEnd - dayCountEnd)) / numberOfDaysEnd;

        List<String> months = new List<String>();
        months.addAll(revenueAggregates.keySet());

        for (String month : months){

            Map<String,List<Object>> stageMap = new Map<String,List<Object>>{
                    'Closed Won'        => new List<Object>(),
                    'Costed prospect'   => new List<Object>(),
                    'Pipeline prospect' => new List<Object>(),
                    'Repeat Prospect'   => new List<Object>()
            };
            reportData.put(month, stageMap);

            Map<String,Decimal> stageValueMap = new Map<String,Decimal>{
                    'Closed Won Revenue'        => 0, 'Closed Won COS'         => 0,
                    'Costed prospect Revenue'   => 0, 'Costed prospect COS'    => 0,
                    'Pipeline prospect Revenue' => 0, 'Pipeline prospect COS'  => 0,
                    'Repeat Prospect Revenue'   => 0, 'Repeat Prospect COS'    => 0
            };
            reportValues.put(month, stageValueMap);
        }

        // get all committed opp data
        for (Opportunity opp : [SELECT Amount_Calder__c, Probability, StageName, Name, Account.Name,
                                        Event_start__c, Event_end__c, Filtered_Cost_of_Sale__c,
                                        Gross_Margin__c, Quote_Status__c, Filtered_Job_Number__c,
                                        EventMonthYear__c, Committed__c, CommittedRevenue__c,
                                        CommittedProfit__c, CommittedCOS__c, IsClosed,
                                        Gross_profit_2__c, Event_End_Grouping__c, COSRemaining__c,
                                        EventMonthString__c, Owner.FirstName, Owner.LastName, Project_Manager__c,
                                        Project_Manager__r.FirstName, Project_Manager__r.LastName, RecStatus__c,
                                (SELECT Revenue__c, Profit__c, CostOfSale__c, EventMonthYear__c, Month__c
                                FROM Adjustments__r)
                                FROM Opportunity
                                WHERE StageName != 'Closed Lost'
                                AND Event_start__c != NULL
                                AND Event_end__c != NULL
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]){

            reportData.get(opp.EventMonthYear__c).get(opp.StageName).add(opp);

            if (opp.Committed__c){
                totalRevenue += opp.CommittedRevenue__c;
                totalProfit += opp.CommittedProfit__c;
                revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedRevenue__c;
                profitAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedProfit__c;
                reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' Revenue',
                        reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' Revenue') + opp.CommittedRevenue__c);
                reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' COS',
                        reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' COS') + opp.CommittedCOS__c);
            } else {
                if (opp.StageName == 'Closed Won') {
                    totalRevenue += opp.Amount_Calder__c;
                    totalProfit += (opp.Gross_profit_2__c == null) ? 0 : opp.Gross_profit_2__c;
                    revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.Amount_Calder__c;
                    profitAggregates.get(opp.EventMonthYear__c)[0] += (opp.Gross_profit_2__c == null) ? 0 : opp.Gross_profit_2__c;
                } else {
                    revenueAggregates.get(opp.EventMonthYear__c)[1] += (opp.Amount_Calder__c * opp.Probability) / 100;
                    profitAggregates.get(opp.EventMonthYear__c)[1] += (opp.Gross_profit_2__c * opp.Probability) / 100;
                    revenueAggregates.get(opp.EventMonthYear__c)[2] += opp.Amount_Calder__c - (opp.Amount_Calder__c * opp.Probability) / 100;
                    profitAggregates.get(opp.EventMonthYear__c)[2] += opp.Gross_profit_2__c - (opp.Gross_profit_2__c * opp.Probability) / 100;
                }
                if (opp.Amount_Calder__c != null){
                    reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' Revenue',
                            reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' Revenue') + opp.Amount_Calder__c);
                }
                if (opp.Filtered_Cost_of_Sale__c != null){
                    reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' COS',
                            reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' COS') + opp.Filtered_Cost_of_Sale__c);
                }
            }
        }

        for (Adjustment__c adj : [SELECT Revenue__c, Profit__c, EventMonthYear__c, Opportunity__r.Name
                                    FROM Adjustment__c
                                    WHERE Month__c >= :startDate
                                    AND Month__c <= :endDate]) {

            reportData.get(adj.EventMonthYear__c).get('Closed Won').add(adj);

            totalRevenue += adj.Revenue__c;
            totalProfit += adj.Profit__c;
            revenueAggregates.get(adj.EventMonthYear__c)[0] += adj.Revenue__c;
            profitAggregates.get(adj.EventMonthYear__c)[0] += adj.Profit__c;
        }

        for (QBProfitAndLoss__c target : [SELECT Actual__c, Budget__c, EventMonthYear__c
                                        FROM QBProfitAndLoss__c
                                        WHERE Parent__c = 'Revenue'
                                        AND Month__c >= :startDate
                                        AND Month__c <= :endDate]) {
            revenueAggregates.get(target.EventMonthYear__c)[3] = target.Actual__c;
        }

        List<QBProfitAndLoss__c> results = [SELECT Actual__c, Parent__c, Budget__c, Grouping__c,
                                                    Month__c, EventMonthYear__c, QBUpdated__c, Opex__c
                                            FROM QBProfitAndLoss__c
                                            WHERE Month__c >= :startDate.toStartOfMonth()
                                            AND Month__c <= :endDate
                                            ORDER BY Month__c DESC];

        for (QBProfitAndLoss__c qpl : results) {

            nominalStrings.add(qpl.Parent__c);
            Decimal multiplier = 1;

            if (qpl.Month__c.month() == startDate.month()) {
                multiplier = startPortion;
            } else if (qpl.Month__c.month() == endDate.month()) {
                multiplier = endPortion;
            }

            if (qpl.Opex__c){

                totalOpex += (qpl.Actual__c * multiplier);
                opexAggregates.get(qpl.EventMonthYear__c)[1] += (qpl.Actual__c * multiplier);
                opexAggregates.get(qpl.EventMonthYear__c)[2]   += (qpl.Budget__c * multiplier);
                profitAggregates.get(qpl.EventMonthYear__c)[3] += (qpl.Actual__c * multiplier);

                if (qpl.Grouping__c == 'Payroll'){
                    opexAggregates.get(qpl.EventMonthYear__c)[6] += (qpl.Actual__c * multiplier);
                } else if (qpl.Grouping__c == 'IT'){
                    opexAggregates.get(qpl.EventMonthYear__c)[7] += (qpl.Actual__c * multiplier);
                } else if (qpl.Grouping__c == 'Bus Dev'){
                    opexAggregates.get(qpl.EventMonthYear__c)[8] += (qpl.Actual__c * multiplier);
                } else if (qpl.Grouping__c == 'Office' || qpl.Grouping__c == 'Other'){
                    opexAggregates.get(qpl.EventMonthYear__c)[9] += (qpl.Actual__c * multiplier);
                }
            } else {

            }
        }

        for (Integer x = 0; x < months.size(); x++){
            netProfitAggregates.get(months[x])[0] = (profitAggregates.get(months[x])[0] - opexAggregates.get(months[x])[1]);
            netProfitAggregates.get(months[x])[1] = (profitAggregates.get(months[x])[0] +
                    profitAggregates.get(months[x])[1] - opexAggregates.get(months[x])[1]);
            netProfitAggregates.get(months[x])[2] = (profitAggregates.get(months[x])[0] +
                    profitAggregates.get(months[x])[1] + profitAggregates.get(months[x])[2] - opexAggregates.get(months[x])[1]);
        }

        totals.put('revenue', totalRevenue);
        totals.put('profit', totalProfit);
        totals.put('opex', totalOpex);
        totals.put('netProfit', totalProfit - totalOpex);

        for (String month : reportValues.keySet()){
            reportValues.get(month).put('Closed Won Profit',
                    (reportValues.get(month).get('Closed Won Revenue' ) - reportValues.get(month).get('Closed Won COS')));
            reportValues.get(month).put('Costed prospect Profit',
                    (reportValues.get(month).get('Costed prospect Revenue' ) - reportValues.get(month).get('Costed prospect COS')));
            reportValues.get(month).put('Pipeline prospect Profit',
                    (reportValues.get(month).get('Pipeline prospect Revenue' ) - reportValues.get(month).get('Pipeline prospect COS')));
            reportValues.get(month).put('Repeat Prospect Profit',
                    (reportValues.get(month).get('Repeat Prospect Revenue' ) - reportValues.get(month).get('Repeat Prospect COS')));
        }

        figuresMap.put('revenue',revenueAggregates);
        figuresMap.put('profit',profitAggregates);
        figuresMap.put('opex',opexAggregates);

        figuresMap.put('netProfit',netProfitAggregates);

        figuresMap.put('totals',totals);
        figuresMap.put('REPORTDATA',reportData);
        figuresMap.put('REPORTVALUES',reportValues);
        figuresMap.put('months',months);

        figuresMap.put('qbRevenue',revenueAggregates);
        figuresMap.put('qbProfit',profitAggregates);

        figuresMap.put('qbClose',QBClosedMonth__c.getInstance('QBClosedMonth'));
        figuresMap.put('sfCommit',QBClosedMonth__c.getInstance('SFCommitMonth'));
        figuresMap.put('nominalStrings',nominalStrings);

        List<SalesDashboardSnapshot__c> priorSnaps =
                                        [SELECT TotalRevenue__c, TotalGrossProfit__c, TotalOpex__c,
                                                TotalNetProfit__c
                                        FROM SalesDashboardSnapshot__c
                                        WHERE PeriodEnd__c = :Date.valueOf(endDate)
                                        AND TotalRevenue__c != NULL
                                        ORDER BY CreatedDate DESC LIMIT 6];

        if (priorSnaps.isEmpty()){
            figuresMap.put('priorTotals',JSON.deserializeUntyped(
                    '{"TotalRevenue__c" : 0, ' +
                            '"TotalGrossProfit__c" : 0, ' +
                            '"TotalOpex__c" : 0, ' +
                            '"TotalNetProfit__c" : 0}'));
        } else {
            figuresMap.put('priorTotals',JSON.deserializeUntyped(
                    '{"TotalRevenue__c" : ' + (totalRevenue - priorSnaps[priorSnaps.size()-1].TotalRevenue__c) + ', ' +
                            '"TotalGrossProfit__c" : ' + (totalProfit - priorSnaps[priorSnaps.size()-1].TotalGrossProfit__c) + ', ' +
                            '"TotalOpex__c" : ' + (totalOpex - priorSnaps[priorSnaps.size()-1].TotalOpex__c) + ', ' +
                            '"TotalNetProfit__c" :' + ((totalProfit - totalOpex) - priorSnaps[priorSnaps.size()-1].TotalNetProfit__c) +
                            '}'));
        }

        return figuresMap;
    }

    @RemoteAction
    public static Map<String,Object> changeEntryDate(String entryId, String dateString){

        Date flowDate           = Date.valueOf(dateString);
        CashFlow__c flow        = [SELECT Id, Date__c, Number__c FROM CashFlow__c WHERE Date__c = :flowDate];
        CashFlowEntry__c entry  = [SELECT Id, Description__c, BudgetKey__c, Date__c, Amount__c
                                    FROM CashFlowEntry__c WHERE Id = :entryId];

        // if the record has been moved across months, detect if budget entries need to be updated.
        if (entry.Date__c.month() != flowDate.month()){
            // add the value of the record to the budget in the month it is being removed from
            updateBudgets(entry.Date__c,entry.BudgetKey__c,entry.Amount__c);
            // subtract the value of the record to the budget in the the month it is being removed from
            updateBudgets(flowDate,entry.BudgetKey__c, (entry.Amount__c * -1));
        }

        entry.CashFlow__c       = flow.Id;
        entry.Adjusted__c       = true;
        entry.AdjustedDate__c   = flowDate;

        update entry;

        calculateBalances();

        Map<String,Object> responseData = getCashflowData(true);
//        Map<String,Object> responseData = getCashflowData(false);
//        responseData.put('RECORD',[SELECT Category__c, Amount__c, Out__c, Description__c, Source__c,
//                                            CashFlow__r.DayMonthYear__c
//                                    FROM CashFlowEntry__c WHERE Id = :entryId]);

        return responseData;

    }

    @RemoteAction
    public static Map<String,Object> updateAmount(String entryId, Decimal amount){

        CashFlowEntry__c entry = [SELECT Category__c, Amount__c, Out__c, Description__c, Source__c,
                                        CashFlow__r.DayMonthYear__c, Date__c, BudgetKey__c
                                FROM CashFlowEntry__c WHERE Id = :entryId];

        // if the entry is not a budget record, we need to return all records to the VF as changing it's value
        // will change budget record values
        Boolean returnRecords = entry.Source__c != 'Budget';

        if (returnRecords){
            updateBudgets(entry.Date__c,entry.BudgetKey__c,((amount - entry.Amount__c) * -1));
        }

        entry.Amount__c         = amount;
        entry.Adjusted__c       = true;
        entry.AmountAdjusted__c = true;

        update entry;

        calculateBalances();
        return getCashflowData(returnRecords);
    }

    @RemoteAction
    public static Map<String,Object> markAsPaid(String entryId){

        update new CashFlowEntry__c(
                Id                  = entryId,
                Paid__c             = true);
        calculateBalances();
        return getCashflowData(true);
    }

    @RemoteAction
    public static Map<String,Object> addCustomEntry(String type, String description, String budgetKey,
            Decimal amount, String dateString){

        Date flowDate       = Date.valueOf(dateString);
        CashFlow__c flow    = [SELECT Id FROM CashFlow__c WHERE Date__c = :flowDate];

        if (flow != null){
            CashFlowEntry__c customEntry    = new CashFlowEntry__c();
            customEntry.Source__c           = 'Custom';
            customEntry.Out__c              = (type != 'Revenue');
            customEntry.Category__c         = type;
            customEntry.Description__c      = description + ' (' + budgetKey + ')';
            customEntry.CashFlow__c         = flow.Id;
            customEntry.Amount__c           = amount;
            customEntry.Stage__c            = 'Confirmed';
            customEntry.BudgetKey__c        = budgetKey;
            insert customEntry;

            updateBudgets(flowDate,budgetKey,(amount * -1));

            calculateBalances();
            return getCashflowData(true);

        } else {
            return null;
        }
    }

    @RemoteAction
    public static Map<String,Object> deleteEntry(String entryId){

        CashFlowEntry__c deleteEntry = [SELECT Id, Amount__c, Date__c, BudgetKey__c
                                        FROM CashFlowEntry__c WHERE Id = :entryId];

        updateBudgets(deleteEntry.Date__c, deleteEntry.BudgetKey__c, deleteEntry.Amount__c);
        delete deleteEntry;

        calculateBalances();
        return getCashflowData(false);
    }

    @RemoteAction
    public static Boolean updateComment(String entryId, String comment){
        update new CashFlowEntry__c(
                Id          = entryId,
                Comment__c  = comment);
        return true;
    }

    @RemoteAction
    public static Boolean toggleFreelancer(String entryId){

        CashFlowEntry__c entry = [SELECT Id, Category__c, QuickbooksId__c, VendorRef__c
                                    FROM CashFlowEntry__c
                                    WHERE Id = :entryId];

        if (entry.Category__c == 'Freelancers'){
            delete [SELECT Id FROM QBSupplierProfile__c
                    WHERE SupplierId__c = :entry.VendorRef__c];
        } else {
            insert new QBSupplierProfile__c(
                    SupplierId__c   = entry.VendorRef__c,
                    Category__c     = 'Freelancers',
                    Type__c         = 'Freelancers'
            );
        }

        return true;
    }

    @RemoteAction
    public static QBSupplierProfile__c convertToDirectDebit(String vendorRef, String supplierName, String frequency,
                                                            Integer occurence, Decimal amount,
                                                            String endDate, String nominal){

        // check if there is already a supplier profile and delete if so
        delete [SELECT Id FROM QBSupplierProfile__c WHERE SupplierId__c = :vendorRef];

        // create a new supplier profile which the cashflow can use to implement the direct debits
        QBSupplierProfile__c profile = new QBSupplierProfile__c(
                SupplierId__c   = vendorRef,
                SupplierName__c = supplierName,
                Category__c     = nominal,
                Type__c         = 'DD',
                Amount__c       = amount,
                Terms__c        = frequency,
                Day__c          = occurence,
                EndDate__c      = Date.valueOf(endDate)
        );

        insert profile;
        return profile;
    }

    @RemoteAction
    public static Boolean disableDirectDebit(String supplierId){

        // remove the QB supplier profile used to calculate the direct debits
        delete [SELECT Id FROM QBSupplierProfile__c
                WHERE SupplierId__c = :supplierId
                AND Type__c = 'DD'];

        // remove the existing direct debit entries from the cashflow
        delete [SELECT Id FROM CashFlowEntry__c WHERE QuickbooksId__c = :supplierId];

        return true;
    }

    @RemoteAction
    public static Map<String,Object> rerunFlow(Boolean resetValues,Boolean resetBudgets){
        CashflowGenerator.buildFlow(resetValues, resetBudgets);
        return getCashflowData(true);
    }

    @RemoteAction
    public static Object getAttachmentLink(String billId){

        String attachmentQuery = 'query?query=select%20%2a%20from%20attachable%20where%20AttachableRef.EntityRef.' +
                'value%20%3d%20%27' + billId + '%27&minorversion=4';
        // do callout
        Http attachmentHttp               = new Http();
        HttpRequest attachmentRequest     = CashFlowUtils.doCallout(attachmentQuery);
        HttpResponse attachmentResponse   = attachmentHttp.send(attachmentRequest);

        return attachmentResponse.getStatusCode() == 200 ?
                JSON.deserializeUntyped(attachmentResponse.getBody()) : (Object)'error';
    }

    public static void updateBudgets(Date recordDate, String budgetKey, Decimal amount){

        Date budgetDate = recordDate.addMonths(1).toStartOfMonth().addDays(-1);

        List<CashFlowEntry__c> budgetEntries = [SELECT Id, Amount__c
                                        FROM CashFlowEntry__c
                                        WHERE Source__c = 'Budget'
                                        AND BudgetKey__c = :budgetKey
                                        AND Date__c = :budgetDate
                                        AND AmountAdjusted__c = FALSE];

        if (budgetEntries.size() == 1){
            budgetEntries[0].Amount__c += amount;
            update budgetEntries;
        }
    }

    public static void calculateBalances(){

        Decimal confirmed   = 0;
        Decimal pipeline    = 0;
        Decimal budget      = 0;

        List<CashFlow__c> flows = [SELECT Id, InConfirmed__c, InPipeline__c, InBudget__c,
                                            OutConfirmed__c, OutPipeline__c, OutBudget__c,
                                            Balance__c, BalancePlus__c, BalancePredict__c,
                                            Number__c, InDescription__c
                                    FROM CashFlow__c
                                    ORDER BY Number__c ASC];

        for (CashFlow__c flow : flows) {
            if (flow.Number__c == -1){
                confirmed   += flow.Balance__c;
            } else {
                confirmed   += (flow.InConfirmed__c - flow.OutConfirmed__c);
                pipeline    += (flow.InPipeline__c - flow.OutPipeline__c);
                budget      += (flow.InBudget__c - flow.OutBudget__c);
                flow.Balance__c         = confirmed;
                flow.BalancePlus__c     = confirmed + pipeline;
                flow.BalancePredict__c  = confirmed + pipeline + budget;
            }
        }

        update flows;
    }

    @RemoteAction
    public static Map<String,Object> getCashflowData(Boolean includeRecords){

        Map<String,Object> cashflowDataMap = new  Map<String,Object>();

        /// first - work out dates
        List<Date> dates                = new List<Date>();
        List<Decimal> figures           = new List<Decimal>();
        List<CashFlowEntry__c> records  = new List<CashFlowEntry__c>();
        List<Decimal> openingBalances   = new List<Decimal>();
        List<Decimal> closingBalances   = new List<Decimal>();
        List<Decimal> totalInflows      = new List<Decimal>();
        List<Decimal> totalOutflows     = new List<Decimal>();

        Map<String,List<Decimal>> inEntries     = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> outEntries    = new Map<String,List<Decimal>>();

        // begin payment runs on thursday
        Date entryDate = (Date.today() > Date.today().toStartOfWeek().addDays(3)) ?
                Date.today().toStartOfWeek().addDays(10) : Date.today().toStartOfWeek().addDays(3);

        for (Integer x = 0; x < 12; x++){
            if (x == 0){
                dates.add(Date.today());
            } else if (x == 1 && entryDate == Date.today()) {
                entryDate = entryDate.addDays(7);
                dates.add(entryDate);
                entryDate = entryDate.addDays(7);
            } else {
                dates.add(entryDate);
                entryDate = entryDate.addDays(7);
            }
            figures.add(0);
        }

        List<CashFlow__c> flows = [SELECT Date__c, BalancePlus__c, BalancePredict__c, Number__c
                                    FROM CashFlow__c
                                    WHERE Date__c <= :dates[11].addDays(6)
                                    ORDER BY Date__c ASC];

        Map<Date,CashFlow__c> flowMap = new Map<Date,CashFlow__c>();

        for (CashFlow__c flow : flows){
            flowMap.put(flow.Date__c, flow);
        }

        Date endDate;

        for (Integer x = 0; x < 12; x++){
            Date startDate  = Date.valueOf(dates[x]);

            if (startDate.toStartOfWeek().addDays(3) < startDate){
                endDate = startDate.toStartOfWeek().addDays(9);
            } else if (startDate.toStartOfWeek().addDays(3) > startDate) {
                endDate = startDate.toStartOfWeek().addDays(2);
            } else {
                endDate = startDate.addDays(6);
            }

            openingBalances.add(flowMap.get(startDate.addDays(-1)).BalancePredict__c);
            closingBalances.add(flowMap.get(endDate).BalancePredict__c);

            Decimal totalInflow     = 0;
            Decimal totalOutflow    = 0;

            for (CashFlow__c flow : [SELECT Date__c, InConfirmed__c, InPipeline__c, InBudget__c,
                                            OutConfirmed__c, OutPipeline__c, OutBudget__c,
                                    (SELECT Category__c, Amount__c, Out__c, Description__c, Source__c,
                                            CashFlow__r.DayMonthYear__c, QuickbooksId__c, Comment__c,
                                            TempDownloadUri__c, Details__c, VendorRef__c, BudgetKey__c,
                                            AmountAdjusted__c
                                    FROM CashFlowEntries__r
                                    WHERE Paid__c = FALSE
                                    AND HiddenBudget__c = FALSE
                                    ORDER BY Category__c ASC, Source__c )
                                    FROM CashFlow__c
                                    WHERE Date__c >= : startDate
                                    AND Date__c <= : endDate]){

                totalInflow += flow.InConfirmed__c + flow.InPipeline__c + flow.InBudget__c;
                totalOutflow += flow.OutConfirmed__c + flow.OutPipeline__c + flow.OutBudget__c;

                for (CashFlowEntry__c entry : flow.CashFlowEntries__r){
                    if (entry.Out__c){
                        if (!outEntries.containsKey(entry.Category__c)){
                            outEntries.put(entry.Category__c, figures.clone());
                        }
                        outEntries.get(entry.Category__c)[x] += entry.Amount__c;
                        if (includeRecords){
                            entry.WeekId__c = entry.Category__c + String.valueOf(x);
                            records.add(entry);
                        }
                    } else {
                        if (!inEntries.containsKey(entry.Category__c)){
                            inEntries.put(entry.Category__c, figures.clone());
                        }
                        inEntries.get(entry.Category__c)[x] += entry.Amount__c;
                        if (includeRecords){
                            entry.WeekId__c = 'IN' + String.valueOf(x);
                            records.add(entry);
                        }
                    }
                }
            }

            totalInflows.add(totalInflow);
            totalOutflows.add(totalOutflow);
        }

        Map<String,QBSupplierProfile__c> supplierProfiles = new Map<String,QBSupplierProfile__c>();
        for (QBSupplierProfile__c profile : [SELECT Id,SupplierId__c,Category__c,Amount__c,Terms__c,Day__c,
                                                    EndDate__c,EndDateInput__c
                                             FROM QBSupplierProfile__c WHERE Type__c = 'DD']){
            supplierProfiles.put(profile.SupplierId__c, profile);
        }

        // load data map with opening balances
        cashflowDataMap.put('WEEK COMMENCING', dates);
        cashflowDataMap.put('OPENING BALANCE', openingBalances);
        cashflowDataMap.put('IN ENTRIES', inEntries);
        cashflowDataMap.put('TOTAL INFLOW', totalInflows);
        cashflowDataMap.put('OUT ENTRIES', outEntries);
        cashflowDataMap.put('TOTAL OUTFLOW', totalOutflows);
        cashflowDataMap.put('CLOSING BALANCE', closingBalances);
        cashflowDataMap.put('IN', figures.clone());
        cashflowDataMap.put('CASHFLOW', getBalances(String.valueOf(Date.today().addDays(-7)),String.valueOf(entryDate)));
        cashflowDataMap.put('CASHFLOW FULL', getBalances(String.valueOf(Date.today().addDays(-7)),String.valueOf(entryDate)));
        cashflowDataMap.put('SUPPLIER PROFILES',supplierProfiles);
        if (includeRecords) cashflowDataMap.put('RECORDS', records);

        return cashflowDataMap;

    }

    @RemoteAction
    public static Map<String,Object> getQBBudgets(String year){

        String fiscalYear;

        if (year.equalsIgnoreCase('PREVIOUS FY')){
            fiscalYear = 'LAST_FISCAL_YEAR';
        } else if (year.equalsIgnoreCase('CURRENT FY')){
            fiscalYear = 'THIS_FISCAL_YEAR';
        } else if (year.equalsIgnoreCase('NEXT FY')){
            fiscalYear = 'NEXT_FISCAL_YEAR';
        }

        Map<String,Object> responseMap = new Map<String,Object>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/query?query=select%20name,metadata,BudgetEntryType,StartDate,' +
                'EndDate%2c%20Id%20from%20budget&minorversion=4');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200){
            responseMap.put('budgets', JSON.deserializeUntyped(response.getBody()));
        }

        List<QBProfitAndLoss__c> budgetSourceList =
                Database.query('SELECT BudgetSource__c, LastModifiedDate ' +
                        'FROM QBProfitAndLoss__c ' +
                        'WHERE Month__c = ' + fiscalYear  + ' ' +
                        'ORDER BY Month__c DESC LIMIT 1');

        if (!budgetSourceList.isEmpty()){
            if (budgetSourceList[0].BudgetSource__c != null){
                responseMap.put('budgetSource', budgetSourceList[0].BudgetSource__c);
            } else {
                responseMap.put('budgetSource', 'Unknown Budget');
            }

            responseMap.put('budgetUpdate', budgetSourceList[0].LastModifiedDate);
        }

        List<QBProfitAndLoss__c> forecastSourceList =
                Database.query('SELECT ForecastSource__c, LastModifiedDate ' +
                        'FROM QBProfitAndLoss__c ' +
                        'WHERE Month__c = ' + fiscalYear  + ' ' +
                        'ORDER BY Month__c DESC LIMIT 1');

        if (!forecastSourceList.isEmpty()){
            if (forecastSourceList[0].ForecastSource__c != null){
                responseMap.put('forecastSource', forecastSourceList[0].ForecastSource__c);
            } else {
                responseMap.put('forecastSource', 'Unknown Forecast');
            }
            responseMap.put('forecastUpdate', forecastSourceList[0].LastModifiedDate);
        }

        for (QBClosedMonth__c month : QBClosedMonth__c.getAll().values()){
            if (month.Name == 'QBClosedMonth'){
                responseMap.put('closedMonth', month.Month__c);
            }
        }

        return responseMap;
    }


    @RemoteAction
    public static Boolean updateBudgets(String budgetId, String forecastId, String year, String month){

        Boolean result = QuickbooksDashboardCallout.updateOpexForecast(budgetId, forecastId, year, month);
        return result;
    }


    @RemoteAction
    public static Map<String,List<Object>> getOppProfitChanges(String start, String endD, Integer days, Decimal currentTotal){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Object>> changeMap = new Map<String,List<Object>>();

        Map<String,String> imageMap = new Map<String,String>();

        for (Employee1__c emp : [SELECT FirstName__c, LastName__c, ImageLink__c FROM Employee1__c WHERE ImageLink__c != NULL]){
            imageMap.put(emp.FirstName__c + emp.LastName__c, emp.ImageLink__c);
        }

        if (!imageMap.isEmpty()){
            changeMap.put('Images', new List<Object>{imageMap});
        }

        for (Integer x = 0; x < days; x++){
            changeMap.put(String.valueOf(x), new List<Object>());
        }

        Date fallBack = Date.valueOf(Date.today().addDays(-(days-1)));

        List<SalesDashboardSnapshot__c> snapshots =
                            [SELECT TotalGrossProfit__c, DateCreated__c, CreatedDate,
                                    CreatedBy.FirstName, CreatedBy.LastName
                            FROM SalesDashboardSnapshot__c
                            WHERE DateCreated__c >= :fallBack.addDays(-1)
                            AND PeriodEnd__c <= :endDate
                            ORDER BY CreatedDate DESC];

        List<SalesDashboardSnapshot__c> snapshotsClone = snapshots.deepClone(false);

        for (Integer x = 0; x < snapshots.size() - 1; x++){

            if (x == 0){
                snapshots[x].TotalGrossProfit__c = currentTotal - snapshots[x].TotalGrossProfit__c;
            } else {
                snapshots[x].TotalGrossProfit__c = snapshotsClone[x + 1].TotalGrossProfit__c - snapshots[x].TotalGrossProfit__c;
            }
            changeMap.get(String.valueOf(x)).add(snapshots[x]);
        }

        // track date changes
        List<OpportunityFieldHistory> dateChanges = [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                                        Opportunity.Gross_Profit_Field_History__c,
                                                        Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                                        CreatedBy.FirstName, CreatedBy.LastName
                                                FROM OpportunityFieldHistory
                                                WHERE Opportunity.StageName = 'Closed Won'
                                                AND CreatedDate >= :fallBack
                                                AND Field = 'Event_end__c'
                                                ORDER BY CreatedDate DESC];

        for (OpportunityFieldHistory ofs : dateChanges) {

            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));

            // Revenue which has gone out of the current financial year
            if (((Date)ofs.OldValue >= startDate && (Date)ofs.OldValue <= endDate)
                    && ((Date)ofs.NewValue < startDate || (Date)ofs.NewValue > endDate)) {

                changeMap.get(dayString).add(ofs);

                // Revenue which has entered the current financial year
            } else if (((Date)ofs.OldValue < startDate || (Date)ofs.OldValue > endDate)
                    && ((Date)ofs.NewValue >= startDate && (Date)ofs.NewValue <= endDate)) {

                changeMap.get(dayString).add(ofs);
            }
        }


        // capture amount changes and relevant stage (Closed Won) at time of change
        List<OpportunityFieldHistory> revenueChanges =
                                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                            Opportunity.Amount_Calder__c, Opportunity.Calder_Opportunity__c,
                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                            CreatedBy.FirstName, CreatedBy.LastName, CreatedById
                                    FROM OpportunityFieldHistory
                                    WHERE Opportunity.Event_end__c >= :startDate
                                    AND Opportunity.Event_end__c <= :endDate
                                    AND CreatedDate >= :fallBack
                                    AND Field = 'Gross_Profit_Field_History__c'
                                    ORDER BY CreatedDate DESC];

        Map<Id,List<OpportunityFieldHistory>> stageHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();

        for (OpportunityFieldHistory ofs : revenueChanges) {
            stageHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
        }

        // track stage at time of change
        for (OpportunityFieldHistory ofs :
                                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                            Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                            CreatedBy.FirstName, CreatedBy.LastName
                                    FROM OpportunityFieldHistory
                                    WHERE Field = 'StageName'
                                    AND OpportunityId IN :stageHistoriesByIds.keySet()
                                    ORDER BY CreatedDate ASC]){
            stageHistoriesByIds.get(ofs.OpportunityId).add(ofs);
        }

        // derive possible source of profit change as Quickbooks integration
        Map<String,List<Expense__c>> expenseMap = new Map<String,List<Expense__c>>();

        for (Expense__c expense : [SELECT Id, Amount__c, Description__c, Opportunity__c, CreatedDate
                                    FROM Expense__c
                                    WHERE Opportunity__c IN :stageHistoriesByIds.keySet()]){
            String key = expense.Opportunity__c + String.valueOf(expense.CreatedDate.getTime()).substring(0,8);
            if (!expenseMap.containsKey(key)){
                expenseMap.put(key, new List<Expense__c>());
            }
            expenseMap.get(key).add(expense);
        }


        Map<String,OpportunityFieldHistory> revenueHistoryMap = new Map<String,OpportunityFieldHistory>();

        // derive possible source of profit change as revenue change
        for (OpportunityFieldHistory ofs :
                        [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                CreatedBy.FirstName, CreatedBy.LastName
                        FROM OpportunityFieldHistory
                        WHERE Field = 'Amount'
                        AND OpportunityId IN :stageHistoriesByIds.keySet()
                        ORDER BY CreatedDate ASC]){
            String key = ofs.OpportunityId + String.valueOf(ofs.CreatedDate.getTime()).substring(0,8);
            revenueHistoryMap.put(key, ofs);
        }


        // detect duplicate entries caused by quote change
        Map<String,List<Object>> changeTimeMap = new Map<String,List<Object>>();

        for (OpportunityFieldHistory ofs : revenueChanges) {
            if (changeTimeMap.containsKey(ofs.Opportunity.Filtered_Job_Number__c)) {

                Boolean isDuplicate = false;
                List<Object> siblings = changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c);

                for (Integer x = 0; x < siblings.size(); x++){

                    Map<String,Object> fieldMap = (Map<String, Object>)siblings[x];
                    String dateString           = (String)fieldMap.get('CreatedDate');
                    dateString                  = dateString.replace('T',' ');
                    Datetime siblingCreatedTime = Datetime.valueOf(dateString.substring(0,19));

                    if (siblingCreatedTime <= ofs.CreatedDate.addMinutes(2) && siblingCreatedTime >= ofs.CreatedDate.addMinutes(-2)) {

                        isDuplicate = true;
                        fieldMap.put('OldValue', ofs.OldValue);
                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).remove(x);
                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add((Object)fieldMap);
                    }
                }

                if (!isDuplicate){

                    String ofsString = JSON.serialize(ofs);
                    Object ofsObject = JSON.deserializeUntyped(ofsString);
                    changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add(ofsObject);
                }
            } else {

                String ofsString = JSON.serialize(ofs);
                Object ofsObject = JSON.deserializeUntyped(ofsString);
                changeTimeMap.put(ofs.Opportunity.Filtered_Job_Number__c, new List<Object>{ofsObject});
            }
        }

        for (String jobNo : changeTimeMap.keySet()) {

            for (Object ofsObject : changeTimeMap.get(jobNo)) {

                Map<String,Object> fieldMap = (Map<String, Object>)ofsObject;
                Map<String,Object> oppMap = (Map<String,Object>)fieldMap.get('Opportunity');

                String createdString    = (String)fieldMap.get('CreatedDate');
                createdString           = createdString.replace('T',' ');
                Date createdDate        = Date.valueOf(createdString);
                createdDate             = Date.newInstance(createdDate.year(), createdDate.month(), createdDate.day());
                Datetime createdTime    = Datetime.valueOf(createdString);

                if (stageHistoriesByIds.containsKey((String)fieldMap.get('OpportunityId'))){

                    for (OpportunityFieldHistory stageHistory : stageHistoriesByIds.get((String)fieldMap.get('OpportunityId'))){
                        if (stageHistory.CreatedDate.getTime() <= createdTime.getTime()){
                            oppMap.put('StageName', stageHistory.NewValue );
                        }
                    }
                }

                if (oppMap.get('StageName') == (String)'Closed Won'){

                    // get key
                    String key  = (String)fieldMap.get('OpportunityId') +
                            String.valueOf(createdTime.getTime()).substring(0,8);

                    // check both maps
                    if (expenseMap.containsKey(key)){

                        system.debug('found matching expenses');
                        fieldMap.put('Expenses', expenseMap.get(key));
                    }

                    if (revenueHistoryMap.containsKey(key)){
                        system.debug('found revenue changes');
                        fieldMap.put('Revenue', revenueHistoryMap.get(key));
                    }
                    // add values to obj if found in maps

                    fieldMap.put('Opportunity', oppMap);
                    String newOfsString = JSON.serialize(fieldMap);
                    Object newOfsObject = JSON.deserializeUntyped(newOfsString);
                    String dayString    = String.valueOf(createdDate.daysBetween(Date.today()));
                    changeMap.get(dayString).add(newOfsObject);
                }
            }
        }

        // capture stage changes and relevant amounts at time of change
        List<OpportunityFieldHistory> stageChanges = [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                    Opportunity.Gross_Profit_Field_History__c, Opportunity.Calder_Opportunity__c,
                                    Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                    CreatedBy.FirstName, CreatedBy.LastName, Opportunity.Gross_profit_2__c
                            FROM OpportunityFieldHistory
                            WHERE Opportunity.Event_end__c >= :startDate
                            AND Opportunity.Event_end__c <= :endDate
                            AND CreatedDate >= :fallBack
                            AND Field = 'StageName'
                            ORDER BY CreatedDate DESC];

        Map<Id,List<OpportunityFieldHistory>> revenueHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();

        for (OpportunityFieldHistory ofs : stageChanges) {
            // Revenue which has gone out of the current financial year
            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
                revenueHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
            }
        }

        for (OpportunityFieldHistory ofs :
                            [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                    Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                    Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                    CreatedBy.FirstName, CreatedBy.LastName
                            FROM OpportunityFieldHistory
                            WHERE Field = 'Gross_Profit_Field_History__c'
                            AND OpportunityId IN :revenueHistoriesByIds.keySet()
                            ORDER BY CreatedDate ASC]){
            revenueHistoriesByIds.get(ofs.OpportunityId).add(ofs);
        }

        for (OpportunityFieldHistory ofs : stageChanges){

            if (revenueHistoriesByIds.containsKey(ofs.OpportunityId)){
                for (OpportunityFieldHistory revenueHistory : revenueHistoriesByIds.get(ofs.OpportunityId)){
                    if (revenueHistory.CreatedDate.getTime() <= ofs.CreatedDate.getTime()){
                        ofs.Opportunity.Gross_Profit_Field_History__c = Decimal.valueOf((String)revenueHistory.NewValue);
                    }
                }
            }

            if (ofs.Opportunity.Gross_Profit_Field_History__c == null){
                ofs.Opportunity.Gross_Profit_Field_History__c = ofs.Opportunity.Gross_profit_2__c;
            }

            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today().addDays(0)));

            // Revenue which has gone out of the current financial year
            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
                String ofsString = JSON.serialize(ofs);
                Object ofsObject = JSON.deserializeUntyped(ofsString);
                changeMap.get(dayString).add(ofsObject);
            }
        }


        List<Adjustment__c> newCommissions =
                                [SELECT Profit__c, CreatedDate, Month__c, CreatedBy.FirstName,
                                        CreatedBy.LastName, EventMonthYear__c
                                FROM Adjustment__c WHERE Calder__c = TRUE
                                AND CreatedDate >= :fallBack
                                AND Month__c >= :startDate
                                AND Month__c <= :endDate];

        for (Adjustment__c adj : newCommissions){
            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
            changeMap.get(dayString).add(adj);
        }

        List<Adjustment__History> changedCommissions =
                                [SELECT Field, OldValue, NewValue, CreatedDate, CreatedBy.FirstName,
                                        CreatedBy.LastName, Parent.Calder__c,
                                        Parent.Month__c, Parent.EventMonthYear__c
                                FROM Adjustment__History
                                WHERE CreatedDate >= :fallBack
                                AND Parent.Calder__c = TRUE
                                AND Parent.Month__c >= :startDate
                                AND Parent.Month__c <= :endDate];

        for (Adjustment__History adj : changedCommissions){
            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
            changeMap.get(dayString).add(adj);
        }


        return changeMap;
    }


}