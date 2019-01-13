/**
 * Created by Ronan Williams on 18/06/2018.
 */

public class JSONParserQBOBudget {

        public cls_QueryResponse QueryResponse;
        public String time_Z;	//2018-06-18T05:48:59.034-07:00
        public class cls_QueryResponse {
            public cls_Budget[] Budget;
            public Integer startPosition;	//1
            public Integer maxResults;	//1
            public Integer totalCount;	//1
        }
        public class cls_Budget {
            public String Name;	//FY18/19 Control Budget
            public String StartDate;	//2018-04-01
            public String EndDate;	//2019-03-31
            public String BudgetType;	//ProfitAndLoss
            public String BudgetEntryType;	//Monthly
            public boolean Active;
            public cls_BudgetDetail[] BudgetDetail;
            public String domain;	//QBO
            public boolean sparse;
            public String Id;	//7
            public String SyncToken;	//434
            public cls_MetaData MetaData;
        }
        public class cls_BudgetDetail {
            public String BudgetDate;	//2018-04-01
            public Double Amount;	//468520.44
            public cls_AccountRef AccountRef;
        }
        public class cls_AccountRef {
            public String value;	//645
            public String name;	//Events Revenue
        }
        public class cls_MetaData {
            public String CreateTime;	//2018-06-13T03:55:40-07:00
            public String LastUpdatedTime;	//2018-06-13T06:25:51-07:00
        }
        public static JSONParserQBOBudget parse(String json){
            return (JSONParserQBOBudget) System.JSON.deserialize(json, JSONParserQBOBudget.class);
        }


    }