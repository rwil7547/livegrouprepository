({
	doInit : function(component, event, helper) {
		
	},
    closeRec : function(component, event, helper){
        component.set('v.reconciling',false);
    },
    dragOver : function(component, event, helper){
        event.preventDefault();
    },
    dragLeave : function(component, event, helper){
        //console.log('dragg leave');
    },
    drop : function(component, event, helper){
        var dropEvent = $A.get("e.c:ExpenseDrop");
        dropEvent.setParams({ lineId : null});
        dropEvent.fire(); 
    },
})