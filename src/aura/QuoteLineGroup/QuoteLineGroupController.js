({
    doInit : function(component, event, helper){
        // if (component.get('v.group.SBQQ__LineItems__r')){
        //     component.set('v.lines', component.get('v.group.SBQQ__LineItems__r'));
        // } else {
        //     component.set('v.lines', new Array());
        // }
        //     //helper.getTotals(component);

        if (component.get('v.lines')){
            helper.getTotals(component);
        } else {
            component.set('v.lines', new Array());
            var group = component.get('v.group');
            group.revTotal = 0;
            group.cosTotal = 0;
            component.set('v.group',group);
        }
    },
    dragOver : function(component, event, helper){
        if (component.get('v.customGroup') && !component.get('v.reconciling') &&
            !component.get('v.lines').length > 0){
            event.preventDefault();
            document.getElementById(component.get('v.group.Id')).classList.add('dragOver');
        }
    },
    dragLeave : function(component, event, helper){
        document.getElementById(component.get('v.group.Id')).classList.remove('dragOver');
    },
    drop : function(component, event, helper){
        document.getElementById(component.get('v.group.Id')).classList.remove('dragOver');
        if (component.get('v.customGroup') && !component.get('v.reconciling') &&
            !component.get('v.lines').length > 0){

            var data = JSON.parse(event.dataTransfer.getData("text"));

            if (data.type === 'Line'){

                var lineOrderChange = component.getEvent('lineOrderChange');
                lineOrderChange.setParams({
                    id : data.id,
                    oldPosition : data.origin,
                    newPosition : component.get('v.line.SBQQ__Number__c'),
                    targetGroupId : component.get('v.group.Id')
                });

                lineOrderChange.fire();

            }
        }
    },
    editGroupName : function(component, event, helper){
        if (component.get('v.editable') && component.get('v.customGroup') && !component.get('v.hasDocument')){
        	document.getElementById(component.get('v.group.Id') + 'name').style.display = 'none';
        	document.getElementById(component.get('v.group.Id') + 'nameEdit').style.display = 'block';    
        }
	},
    saveGroupName : function(component, event, helper){
        if (event.keyCode === 13) {
            document.getElementById(component.get('v.group.Id') + 'name').style.display = 'flex';
            document.getElementById(component.get('v.group.Id') + 'nameEdit').style.display = 'none';
            
            var nameChange = component.getEvent('groupNameChangeUp');
            nameChange.setParams({
                id : component.get('v.group.Id'),
                name : component.get('v.group.Name')
            });
            nameChange.fire();
  		}
    },
    showProducts : function(component, event, helper){
        var groupEvent = component.getEvent('addGroupProducts');
        groupEvent.setParams({
            'groupId' : component.get('v.group.Id')
        });
        groupEvent.fire()
    },
    deleteGroup : function(component, event, helper){
        var deleteEvent = component.getEvent('deleteGroup');
        deleteEvent.setParams({groupId : component.get('v.group.Id')});
        deleteEvent.fire();
        component.set('v.responsePending',true);
    },
    handleDeleteResponse : function(component, event, helper){
        if (event.getParam('groupId') === component.get('v.group.Id')){
            component.set('v.responsePending',false);
            if (event.getParam('result') === 'success'){
                component.destroy();
            }
        }
    },
    handleAddLinesResponse : function(component, event, helper){
        if (event.getParam('groupId') === component.get('v.group.Id')){
            component.set('v.responsePending',false);           
            var lines = component.get('v.lines');
            for (var x = 0; x < event.getParam('lines').length; x++){
            	lines.push(event.getParam('lines')[x]);    
            }            
            component.set('v.lines',lines);
        }        
    },
    handleLineCloned : function(component, event, helper){
    	var lines = component.get('v.lines');
        var newLines = [];

        for (var x = 0; x < lines.length; x++){
            newLines.push(lines[x]);
            if (lines[x].Id === event.getParam('originalId')){
                newLines.push(event.getParam('line'));
            }
        }
        component.set('v.lines', newLines);
    },
    handleLineChange : function(component, event, helper){
        if (event.getParam('operation') === 'update'){
            var lines = component.get('v.lines');
            var lineUpdate = event.getParam('line');
            lines.forEach(function(element){
               if (element.Id === lineUpdate.Id){
                   element = lineUpdate;
               }
            });
            component.set('v.lines',lines);

        } else if (event.getParam('operation') === 'delete'){
            if (!component.get('v.customGroup')){
                if (component.get('v.lines').length === 0){
                    component.destroy();
                }
            }
        }
    },
    checkGroupSize : function(component, event, helper){
        helper.getTotals(component);

        if (!component.get('v.customGroup')){
            if (event.getParam('operation') === 'delete' && component.get('v.lines').length === 1){
                if (component.get('v.lines')[0].Id = event.getParam('originalId')){
                    component.destroy();
                }
            }
        }
    },
    // dragOver : function(component, event, helper){
    //
    //     if (!component.get('v.lines') || component.get('v.lines').length === 0){
    //         event.preventDefault();
    //         document.getElementById('group').classList.add('dragOver');
    //         // component.find('group').classList.add('dragOver');
    //     }
    // },
    responsePending : function(component, event, helper){
        if (event.getParam('groupId') === component.get('v.group.Id')){
            component.set('v.responsePending',true);
        }
    },
    cloneGroup : function(component, event, helper){
        var cloneGroup = component.getEvent('cloneGroup');
        cloneGroup.setParams({ groupId : component.get('v.group.Id')});
        cloneGroup.fire();
    },
    calculateTotals : function(component, event, helper){
        console.log('calculating totals');
        helper.getTotals(component);
    },
    orderLines : function(component, event, helper){

        var lines = component.get('v.lines');
        var oldPosition = event.getParam('oldPosition');
        var newPosition = event.getParam('newPosition');
        var changeId = event.getParam('id');

        if (oldPosition > newPosition) {
            lines.forEach(function(element){
                if (element.Id === changeId){
                    element.SBQQ__Number__c = newPosition;
                } else if (element.SBQQ__Number__c <= oldPosition && element.SBQQ__Number__c >= newPosition){
                    element.SBQQ__Number__c = element.SBQQ__Number__c +1;
                }
            });
        } else {
            lines.forEach(function(element){
                if (element.Id === changeId){
                    element.SBQQ__Number__c = newPosition;
                } else if (element.SBQQ__Number__c <= newPosition && element.SBQQ__Number__c >= oldPosition){
                    element.SBQQ__Number__c = element.SBQQ__Number__c -1;
                }
            });
        }

        lines.sort(function (a, b) {
            return a.SBQQ__Number__c - b.SBQQ__Number__c;
        });

        component.set('v.lines', lines);

    }
})