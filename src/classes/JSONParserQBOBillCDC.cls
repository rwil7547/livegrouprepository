public class JSONParserQBOBillCDC{
	public cls_CDCResponse[] CDCResponse;
	public String time_Z;	//2018-03-15T08:45:57.463-07:00
	public class cls_CDCResponse {
		public cls_QueryResponse[] QueryResponse;
	}
	public class cls_QueryResponse {
		public cls_Bill[] Bill;
		public Integer startPosition;	//1
		public Integer maxResults;	//21
		public Integer totalCount;	//21
	}
	public class cls_Bill {
		public cls_SalesTermRef SalesTermRef;
		public String DueDate;	//2018-05-12
		public Decimal Balance;	//5143.2
		public String domain;	//QBO
		public boolean sparse;
		public String status;
		public String Id;	//18985
		public String SyncToken;	//0
		public cls_MetaData MetaData;
		public String DocNumber;	//gkj
		public String TxnDate;	//2018-03-13
		public cls_CurrencyRef CurrencyRef;
		public String PrivateNote;	//TER100 Crew & Equipment
		public cls_Line[] Line;
		public cls_TxnTaxDetail TxnTaxDetail;
		public cls_VendorRef VendorRef;
		public cls_APAccountRef APAccountRef;
		public Decimal TotalAmt;	//5143.2
		public String GlobalTaxCalculation;	//TaxExcluded
	}
	public class cls_SalesTermRef {
		public String value;	//6
	}
	public class cls_MetaData {
		public String CreateTime;	//2018-03-13T03:58:23-07:00
		public String LastUpdatedTime;	//2018-03-13T03:58:23-07:00
	}
	public class cls_CurrencyRef {
		public String value;	//GBP
		public String name;	//British Pound Sterling
	}
	public class cls_Line {
		public String Id;	//1
		public String Description;	//TER100 Crew & Equipment
		public Decimal Amount;	//4286
		public String DetailType;	//AccountBasedExpenseLineDetail
		public cls_AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
	}
	public class cls_AccountBasedExpenseLineDetail {
		public cls_CustomerRef CustomerRef;		
		public cls_AccountRef AccountRef;
		public String BillableStatus;	//NotBillable
		public cls_TaxCodeRef TaxCodeRef;
        public cls_ClassRef ClassRef;
	}
	public class cls_CustomerRef {
		public String value;	//1214
		public String name;	//2nd Sage 50 UK Test:thisthis-1
	}
	public class cls_ClassRef {
		public String value;	//100089811214
		public String name;	//17051 innovation realised
	}
	public class cls_AccountRef {
		public String value;	//528
		public String name;	//1002 Work in Progress
	}
	public class cls_TaxCodeRef {
		public String value;	//26
	}
	public class cls_TxnTaxDetail {
		public Decimal TotalTax;	//857.2
		public cls_TaxLine[] TaxLine;
	}
	public class cls_TaxLine {
		public Decimal Amount;	//857.2
		public String DetailType;	//TaxLineDetail
		public cls_TaxLineDetail TaxLineDetail;
	}
	public class cls_TaxLineDetail {
		public cls_TaxRateRef TaxRateRef;
		public boolean PercentBased;
		public Integer TaxPercent;	//20
		public Decimal NetAmountTaxable;	//4286
	}
	public class cls_TaxRateRef {
		public String value;	//47
	}
	public class cls_VendorRef {
		public String value;	//1143
		public String name;	//Terry Tew Sound and Light Ltd
	}
	public class cls_APAccountRef {
		public String value;	//383
		public String name;	//2100 Creditors Control Account
	}
	public static JSONParserQBOBillCDC parse(String json){
		return (JSONParserQBOBillCDC) System.JSON.deserialize(json, JSONParserQBOBillCDC.class);
	}
}