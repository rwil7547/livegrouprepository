public class DashboardControllerNextFY {

        Confirmed_Revenue_Snapshot__c priorSnapshot  = new Confirmed_Revenue_Snapshot__c();
        List<AggregateResult> currentFigures  = new List<AggregateResult>();
        List<AggregateResult> currentOpex   = new List<AggregateResult>();

        private Decimal priorRevenue  = 0;
        private Decimal priorGrossProfit = 0;
        private Decimal priorNetProfit = 0;

        private Decimal currentRevenue = 0;
        private Decimal currentGrossProfit = 0;
        private Decimal currentNetProfit = 0;

        public Decimal getCurrentRevenue() {
                return currentRevenue;
        }

        public Decimal getCurrentGrossProfit() {
                return currentGrossProfit;
        }

        public Decimal getCurrentNetProfit() {
                return currentNetProfit;
        }

        public Decimal getRevenueChange() {
                decimal revenueChange = currentRevenue - priorRevenue;
                return revenueChange;
        }

        public Decimal getGrossProfitChange() {
                decimal grossProfitChange = currentGrossProfit - priorGrossProfit;
                return grossProfitChange;
        }

        public Decimal getNetProfitChange() {
                decimal netProfitChange = currentNetProfit - priorNetProfit;
                return netProfitChange;
        }

        public DashboardControllerNextFY() {

                currentFigures =  [SELECT SUM(Amount_Calder__c) Revenue, 
                                        SUM(Gross_profit_2__c) GrossProfit
                                FROM Opportunity 
                                WHERE StageName = 'Closed Won'
                                AND Event_End__c = NEXT_FISCAL_YEAR];

                currentOpex =  [SELECT SUM(Operating_Cost__c) OperatingCost 
                                FROM Revenue_Summary__c
                                WHERE Month__c = NEXT_FISCAL_YEAR];

                currentRevenue     = (Decimal)currentFigures[0].get('Revenue');
                currentGrossProfit = (Decimal)currentFigures[0].get('GrossProfit');
                currentNetProfit   = (Decimal)currentFigures[0].get('GrossProfit') - (Decimal)currentOpex[0].get('OperatingCost');

                if (Date.today().month() == 4 && Date.today().day() < 7) {
                        priorRevenue     = currentRevenue;
                        priorGrossProfit = currentGrossProfit;
                        priorNetProfit   = currentNetProfit;
                } else {
                        priorSnapshot = [SELECT Id, Net_Amount__c, Gross_Profit__c, Net_Profit__c
                                        FROM Confirmed_Revenue_Snapshot__c
                                        WHERE (Financial_Year__c = 'NextFY' 
                                                AND (CreatedDate = THIS_FISCAL_YEAR
                                                     OR CreatedDate = LAST_N_DAYS:7))
                                        ORDER BY CreatedDate DESC LIMIT 7][6];

                        priorRevenue     = priorSnapshot.Net_Amount__c;
                        priorGrossProfit = priorSnapshot.Gross_Profit__c;
                        priorNetProfit   = priorSnapshot.Net_Profit__c;
                }        
        }
}