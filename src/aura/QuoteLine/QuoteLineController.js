({
    doInit : function(component, event, helper){
		helper.clone(component);
        helper.calculateTotal(component, event);
    },
    openEdit : function(component, event, helper) {
        if (component.get('v.editable') && !component.get('v.editmode')){            
            if (!document.getElementById(component.get('v.line.Id')).classList.contains('selected')){
                document.getElementById(component.get('v.line.Id')).classList.add('selected');                
                component.set('v.editmode', true);
                helper.fireOpenEdit(component.get('v.line.Id'));
            }
        }
    },
    closeEdit: function(component, event, helper) {        
        if(event.getParam('Id') !== component.get('v.line.Id') &&
            document.getElementById(component.get('v.line.Id')).classList.contains('selected') &&
            !component.get('v.changed')){
            helper.closeEdit(component);
        }
    },
    cancelEdit: function(component, event, helper){
    	helper.closeEdit(component);  	  
    },
    setChanged: function(component, event, helper){
        if (!component.get('v.changed')){
            if (event.getParam("oldValue") !== event.getParam("value") &&
                event.getParam('index')){
                component.set('v.changed',true);
                helper.fireLineChange(component, component.get('v.line'),'uncommitted');
            }
        }
    },
    undoChanges : function(component, event, helper){
        var clone = JSON.parse(JSON.stringify(component.get('v.original')));
        component.set('v.line',clone);
        component.set('v.changed', false);
    },
    save : function(component, event, helper){
        if (event.which === 13){
            // to do - check that input contents are valid
            
            component.set('v.responsePending',true);
            component.set('v.changed', false);
            helper.closeEdit(component);
            var line = component.get('v.line');
        	line.SBQQ__Description__c = helper.formatDescription(line.SBQQ__Description__c);
            console.log(line.SBQQ__Description__c);
            //helper.fireLineChange(component, component.get('v.line'),'save');
        	helper.fireLineChange(component, line,'save');
        }  
    },
    updateLine: function(component, event, helper){
            // to do - check that input contents are valid

        event.stopPropagation();
        component.set('v.responsePending',true);
        component.set('v.changed', false);
        helper.closeEdit(component);
        var line = component.get('v.line');
        line.SBQQ__Description__c = helper.formatDescription(line.SBQQ__Description__c);
        console.log(line.SBQQ__Description__c);
        //helper.fireLineChange(component, component.get('v.line'),'save');
        helper.fireLineChange(component, line,'save');
    },  
    cloneLine: function(component, event, helper){
        event.stopPropagation();
        component.set('v.responsePending',true);
        component.set('v.changed', false);
        helper.closeEdit(component);
        helper.fireLineChange(component, component.get('v.line'),'clone');
    },
    toggleLineOptional: function(component, event, helper){
        event.stopPropagation();
        component.set('v.responsePending',true);
        component.set('v.changed', false);
        helper.closeEdit(component);
        helper.fireLineChange(component, component.get('v.line'),'optional');
    },
    deleteLine: function(component, event, helper){
        event.stopPropagation();
        component.set('v.responsePending',true);
        component.set('v.changed', false);
        helper.closeEdit(component);
        helper.fireLineChange(component, component.get('v.line'),'delete');
    },
    processChangeResponse : function(component, event, helper){
        if (component.get('v.line.Id') === event.getParam('originalId')){
            component.set('v.responsePending',false);
            var operation = event.getParam('operation');
            var response = event.getParam('response');
            if (operation === 'save' && response !== 'error'){   
                var clone = JSON.parse(JSON.stringify(component.get('v.line')));
                component.set('v.original',clone);
                component.set('v.changed', false);           
            } else if (operation === 'clone' && response !== 'error'){
                var line = Object.assign({},component.get('v.line'));
                line.Id = event.getParam('response');
                var clonedLine = component.getEvent('clonedLine');
                clonedLine.setParams({
                    line : line,
                    originalId : component.get('v.line.Id')
                });
                clonedLine.fire();
                console.log('firing cloned line');
            } else if (operation === 'optional' && response !== 'error'){
                var line = component.get('v.line');
                if (line.SBQQ__Optional__c){
                    line.SBQQ__Optional__c = false;
                } else {
                    line.SBQQ__Optional__c = true;
                }
                component.set('v.line',line);
            } else if (operation === 'delete' && response !== 'error'){
                component.destroy();
            }
        }
    },
    handleMultiLineUpdate : function(component, event, helper){
        if (component.get('v.changed')){
            component.set('v.responsePending',true);
            component.set('v.changed', false);
            helper.closeEdit(component); 
        }
    },
    dragOver : function(component, event, helper){
        event.preventDefault();
        component.find('line').getElement().classList.add('dragOver');
    },
    dragLeave : function(component, event, helper){
        //console.log('dragg leave');
        component.find('line').getElement().classList.remove('dragOver');
    },
    drop : function(component, event, helper){

        var data = event.dataTransfer.getData("text");
        console.log('data is ' + data);

        // todo: if the thing dropped is another line, send an event to group parent,
        // and get the parent to call the server to reorder the lines


        component.find('line').getElement().classList.remove('dragOver');
        var dropEvent = $A.get("e.c:ExpenseDrop");
        var line = component.get('v.line');
        dropEvent.setParams({ lineId : line.Id});
        dropEvent.fire(); 
    },
    startLineDrag : function(component, event, helper){
        event.dataTransfer.setData("text/plain", component.get('v.line.Id'));

        // component.find('line').getElement().style.cursor = 'all-scroll';
    },
    calculateTotal : function(component, event, helper){ 
        helper.calculateTotal(component, event);
    },
    calculate : function(component, event, helper){
        var line = component.get('v.line');
        var expensesTotal = component.get('v.expensesTotal');
        
        var unitCost = (!line.SBQQ__SubscriptionTerm__c) ?
            expensesTotal / line.SBQQ__Quantity__c :
        	expensesTotal / line.SBQQ__Quantity__c / line.SBQQ__SubscriptionTerm__c;
        
        line.SBQQ__UnitCost__c = unitCost;
        component.set('v.line',line);
        
        
    }
})