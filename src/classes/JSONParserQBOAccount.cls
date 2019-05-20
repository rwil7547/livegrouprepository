/**
 * Created by Ronan Williams on 19/05/2019.
 */

public class JSONParserQBOAccount {

    public cls_QueryResponse QueryResponse;
    public String time_Z;	//2019-05-19T14:41:34.858-07:00
    class cls_QueryResponse {
        public cls_Account[] Account;
        public Integer startPosition;	//1
        public Integer maxResults;	//100
    }
    class cls_Account {
        public String Name;	//Accrued Income
        public boolean SubAccount;
        public String FullyQualifiedName;	//Accrued Income
        public boolean Active;
        public String Classification;	//Asset
        public String AccountType;	//Other Current Asset
        public String AccountSubType;	//AllowanceForBadDebts
        public String AcctNum;	//2110
        public Double CurrentBalance;	//48075.48
        public Double CurrentBalanceWithSubAccounts;	//48075.48
        public cls_CurrencyRef CurrencyRef;
        public String domain;	//QBO
        public boolean sparse;
        public String Id;	//687
        public String SyncToken;	//1
        public cls_MetaData MetaData;
    }
    class cls_CurrencyRef {
        public String value;	//GBP
        public String name;	//British Pound Sterling
    }
    class cls_MetaData {
        public String CreateTime;	//2018-04-25T05:06:30-07:00
        public String LastUpdatedTime;	//2019-05-14T01:50:15-07:00
    }
    public static JSONParserQBOAccount parse(String json){
        return (JSONParserQBOAccount) System.JSON.deserialize(json, JSONParserQBOAccount.class);
    }

}