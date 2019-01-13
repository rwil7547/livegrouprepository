/**
 * Created by Ronan Williams on 02/10/2018.
 */

public class JSONParserQBOProfitAndLoss {

    public cls_Header Header;
    public cls_Columns Columns;
    public cls_Rows Rows;

    public class cls_Header {
        public cls_ColData[] ColData;
    }
    public class cls_Option {
        public String Name;	//AccountingStandard
        public String Value;	//UK
    }
    public class cls_Columns {
        public cls_Column[] Column;
    }
    public class cls_Column {
        public String ColTitle;	//
        public String ColType;	//Account
        public cls_MetaData[] MetaData;
    }
    public class cls_MetaData {
        public String Name;	//ColKey
        public String Value;	//account
    }
    public class cls_Rows {
        public cls_Row[] Row;
    }
    public class cls_Row {
        public cls_Rows Rows;
        public cls_ColData[] ColData;
        public String type;	//Data
        public cls_Summary Summary;
        public String typeZ;	//Section
        public cls_Summary Summary2;
        public String groupZ;	//Income
    }
    public class cls_ColData {
        public String value;	//Total Income
    }
    public class cls_Summary {
        public cls_ColData[] ColData;
    }
    public static JSONParserQBOProfitAndLoss parse(String json){
        return (JSONParserQBOProfitAndLoss) System.JSON.deserialize(json, JSONParserQBOProfitAndLoss.class);
    }
}