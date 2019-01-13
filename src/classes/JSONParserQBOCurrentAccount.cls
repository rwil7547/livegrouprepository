/**
 * Created by Ronan Williams on 20/06/2018.
 */

public class JSONParserQBOCurrentAccount {
    public cls_QueryResponse QueryResponse;
    public String time_Z;    //2018-06-20T03:27:56.746-07:00
    public class cls_QueryResponse {
        public cls_Account[] Account;
        public Integer startPosition;    //1
        public Integer maxResults;    //1
    }
    public class cls_Account {
        public String Name;    //Bank Current Account
        public boolean SubAccount;
        public String FullyQualifiedName;    //Bank Current Account
        public boolean Active;
        public String Classification;    //Asset
        public String AccountType;    //Bank
        public String AccountSubType;    //CashOnHand
        public String AcctNum;    //1200
        public Decimal CurrentBalance;    //170314.55
        public Double CurrentBalanceWithSubAccounts;    //170314.55
        public cls_CurrencyRef CurrencyRef;
        public String domain;    //QBO
        public boolean sparse;
        public String Id;    //678
        public String SyncToken;    //0
        public cls_MetaData MetaData;
    }
    public class cls_CurrencyRef {
        public String value;    //GBP
        public String name;    //British Pound Sterling
    }
    public class cls_MetaData {
        public String CreateTime;    //2018-04-25T05:06:29-07:00
        public String LastUpdatedTime;    //2018-06-20T02:41:22-07:00
    }
    public static JSONParserQBOCurrentAccount parse(String json) {
        return (JSONParserQBOCurrentAccount) System.JSON.deserialize(json, JSONParserQBOCurrentAccount.class);
    }
}