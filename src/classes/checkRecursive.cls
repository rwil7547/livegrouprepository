public class checkRecursive {

	private static boolean beforeInsert = true;
	private static boolean beforeUpdate = true;
	private static boolean beforeDelete = true;
	private static boolean afterInsert = true;
	private static boolean afterUpdate = true;
	private static boolean afterDelete = true;
	private static boolean afterUndelete = true;
    
    public static boolean beforeInsert(){
	    if(beforeInsert){
		    beforeInsert=false;
		    return true;
	    }else{
	        return beforeInsert;
	    }
    }

	public static boolean beforeUpdate(){
	    if(beforeUpdate){
		    beforeUpdate=false;
		    return true;
	    }else{
	        return beforeUpdate;
	    }
    }

    public static boolean beforeDelete(){
	    if(beforeDelete){
		    beforeDelete=false;
		    return true;
	    }else{
	        return beforeDelete;
	    }
    }

    public static boolean afterInsert(){
	    if(afterInsert){
		    afterInsert=false;
		    return true;
	    }else{
	        return afterInsert;
	    }
    }

    public static boolean afterUpdate(){
	    if(afterUpdate){
		    afterUpdate=false;
		    return true;
	    }else{
	        return afterUpdate;
	    }
    }

    public static boolean afterDelete(){
	    if(afterDelete){
		    afterDelete=false;
		    return true;
	    }else{
	        return afterDelete;
	    }
    }

    public static boolean afterUndelete(){
	    if(afterUndelete){
		    afterUndelete=false;
		    return true;
	    }else{
	        return afterUndelete;
	    }
    }

    public static void resetAll(){
    	if(Test.isRunningTest()){
			beforeInsert = true;
			beforeUpdate = true;
			beforeDelete = true;
			afterInsert = true;
			afterUpdate = true;
			afterDelete = true;
			afterUndelete = true;      		
    	}
 	
    }
}