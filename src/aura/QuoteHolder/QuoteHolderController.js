({
	doInit : function(component, event, helper) {
        
        // Create the action
        var action = component.get("c.getQuotes"); 
        action.setParams({ 
            Id : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                component.set("v.quotes", response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);   
	}
})