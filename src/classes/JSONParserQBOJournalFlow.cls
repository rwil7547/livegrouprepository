/**
 * Created by Ronan Williams on 26/06/2018.
 */

public class JSONParserQBOJournalFlow {
    public cls_QueryResponse QueryResponse;
    public String time_z;    //2018-06-26T03:51:06.275-07:00
    public class cls_QueryResponse {
        public cls_JournalEntry[] JournalEntry;
        public Integer startPosition;    //1
        public Integer maxResults;    //2
        public Integer totalCount;    //2
    }
    public class cls_JournalEntry {
        public boolean Adjustment;
        public Double TotalAmt;    //158978.2
        public String domain;    //QBO
        public boolean sparse;
        public String Id;    //20276
        public String SyncToken;    //1
        public cls_MetaData MetaData;
        public String DocNumber;    //Salary June 18
        public String TxnDate;    //2018-06-22
        public cls_CurrencyRef CurrencyRef;
        public cls_Line[] Line;
        public cls_TxnTaxDetail TxnTaxDetail;
    }
    public class cls_MetaData {
        public String CreateTime;    //2018-06-22T07:28:53-07:00
        public String LastUpdatedTime;    //2018-06-22T07:32:44-07:00
    }
    public class cls_CurrencyRef {
        public String value;    //GBP
        public String name;    //British Pound Sterling
    }
    public class cls_Line {
        public String Id;    //0
        public String Description;    //Salary June 18
        public Double Amount;    //54095.73
        public String DetailType;    //JournalEntryLineDetail
        public cls_JournalEntryLineDetail JournalEntryLineDetail;
    }
    public class cls_JournalEntryLineDetail {
        public String PostingType;    //Credit
        public cls_AccountRef AccountRef;
        public cls_ClassRef ClassRef;
    }
    public class cls_AccountRef {
        public String value;    //694
        public String name;    //2220 Net Wages
    }
    public class cls_ClassRef {
        public String value;    //694
        public String name;    //2220 Net Wages
    }
    public class cls_TxnTaxDetail {
    }
    public static JSONParserQBOJournalFlow parse(String json) {
        return (JSONParserQBOJournalFlow) System.JSON.deserialize(json, JSONParserQBOJournalFlow.class);
    }

}