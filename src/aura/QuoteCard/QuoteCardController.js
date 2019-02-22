({
	doInit : function(component, event, helper) {
        if (component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r")){
            component.set('v.editable',false);
            var quoteDocs = component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r");
            for (var x = 0; x < quoteDocs.length; x++){
                if (quoteDocs[x].SBQQ__OutputFormat__c === 'PDF'){
                    component.set("v.pdf", quoteDocs[x].SBQQ__DocumentId__c);
                } else {
                    component.set("v.word", quoteDocs[x].Id);
                }    
            }
        }
	},
    showDocument : function(component, event, helper) {
        event.stopPropagation();
	    component.find('document').getElement().style.display = 'block';
    },
    handleShowDocument : function(component, event, helper){
	   if (event.getParam('quoteId') === component.get('v.quote.Id')){
           component.find('document').getElement().style.display = 'block';
       }
    },
    closeDocument : function(component, event, helper){
        component.find('document').getElement().style.display = 'none';
    },
    deleteDocument : function(component, event, helper){

    },
    selectQuote : function(component, event, helper){
        var selectEvent = $A.get("e.c:SelectQuoteEvent");
        selectEvent.setParams({
            quoteId : component.get('v.quote.Id')
        });
        selectEvent.fire();
    },
    deselect : function(component, event, helper){
        var quote = component.get('v.quote');
        if (event.getParam('quoteId') !== quote.Id){
            quote.selected = false;
            component.set('v.quote',quote);
        } else {
            quote.selected = true;
            component.set('v.quote',quote);
        }
    }
})