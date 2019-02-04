({
	doInit : function(component, event, helper) {

        if (component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r")){
            component.set('v.editable',false);
            var quoteDocs = component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r");
            for (var x = 0; x < quoteDocs.length; x++){
                if (quoteDocs[x].SBQQ__OutputFormat__c === 'PDF'){
                    component.set("v.pdf", quoteDocs[x].Id);
                } else {
                    component.set("v.word", quoteDocs[x].Id);
                }    
            }
        }
        if (component.get('v.primary')){
            console.log('quote id is ' + component.get('v.quote.Id') + 'card');

        }
	},
    showDoc : function(component, event, helper) {
        document.getElementById(event.target.id).style.zIndex = '1000';
    },
    resetZ : function(component, event, helper) {
        if (event.target.dataset.type === 'pdf'){
            document.getElementById(event.target.id).style.zIndex = '2'; 
        } else {
            document.getElementById(event.target.id).style.zIndex = '1';           
        }
    },
    selectQuote : function(component, event, helper){
        var selectEvent = $A.get("e.c:SelectQuoteEvent");
        selectEvent.setParams({
            quoteId : component.get('v.quote.Id')
        });
        selectEvent.fire();
    },
    deselect : function(component, event, helper){
        if (event.getParam('quoteId') !== component.get('v.quote.Id')){
            component.set('v.selected',false);
        } else {
            component.set('v.selected',true);
        }
    }
})