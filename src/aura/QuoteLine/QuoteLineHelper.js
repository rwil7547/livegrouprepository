({
    clone : function(component) {
        var clone = JSON.parse(JSON.stringify(component.get('v.line')));
        component.set('v.original',clone);
    },
    fireOpenEdit : function(Id) {
        var selectEvt = $A.get("e.c:LineSelected");
        selectEvt.setParams({ "Id" : Id });
        selectEvt.fire();  
    }, 
	fireLineChange : function(component, line, operation) {
		var lineEvent = component.getEvent('lineEdit');
        lineEvent.setParams({
            'line' : line,
            'id' : line.Id,
            'operation' : operation
        });
        lineEvent.fire();
	},
    closeEdit : function(component){
        document.getElementById(component.get('v.line.Id')).classList.remove('selected');
        component.set('v.editmode', false);

        if (component.get('v.editable') && component.get('v.revEditable') && !component.get('v.reconciling')){
             component.find('line').getElement().setAttribute('draggable',true);
        }
    },
    calculateTotal : function(component, event){        
        var id = component.get('v.line.Id');
        var expenses = component.get('v.expenses');
        
        var total = 0;
        for (var x = 0; x < expenses.length; x++){
            if (expenses[x].QuoteLine__c === id){
            	total += expenses[x].Amount__c;                
            }
        }       
        component.set('v.expensesTotal',total);
    },
    formatDescription : function(description){
        if (description.substring(0, 3) === '<p>'){
            description = description.substring(3);
        }
        if (description.substring(description.length - 11, description.length) === '<p><br></p>'){
            description = description.substring(0, description.length - 11);            
        } else if (description.substring(description.length - 4, description.length) === '</p>'){
            description = description.substring(0, description.length - 4);
        }
       
        return description;
    },
    inputValid : function(component){
        var valid = (!isNaN(component.get('v.line.SBQQ__Quantity__c')) &&
                     component.get('v.line.SBQQ__Quantity__c') >  0 &&
                     !isNaN(component.get('v.line.SBQQ__UnitCost__c')) &&
                     // component.get('v.line.SBQQ__UnitCost__c') >= 0 &&
                     !isNaN(component.get('v.line.SBQQ__ListPrice__c'))
            // &&
                     // component.get('v.line.SBQQ__ListPrice__c') >= 0
        );

        console.log('initial valid claim is ' + valid);

        if (component.get('v.original.SBQQ__SubscriptionTerm__c')){

            console.log('finding term of ' + component.get('v.line.SBQQ__Product__r.SBQQ__SubscriptionTerm__c'));

            valid = !isNaN(component.get('v.line.SBQQ__SubscriptionTerm__c')) &&
                component.get('v.line.SBQQ__SubscriptionTerm__c') >  0;
        }

        console.log('later valid claim is ' + valid);

        return valid;
    }
})