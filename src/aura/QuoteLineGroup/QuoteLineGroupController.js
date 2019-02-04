({
    doInit : function(component, event, helper){
        if (component.get('v.group.SBQQ__LineItems__r')){
            component.set('v.lines', component.get('v.group.SBQQ__LineItems__r'));
        } else {
            component.set('v.lines', new Array());
        }
        helper.getTotals(component);
    },
    showProducts : function(component, event, helper) {
        
    },
    editGroupName : function(component, event, helper){
        if (component.get('v.editable') && component.get('v.customGroup')){
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
        console.log('child delete event fired');
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
        
        console.log('oringal id is ' + event.getParam('originalId'));
        console.log('new line is ' + event.getParam('line'));
        
        for (var x = 0; x < lines.length; x++){
            newLines.push(lines[x]);
            console.log('line id ' + lines[x].Id + ' original id ' + event.getParam('originalId'));
            if (lines[x].Id === event.getParam('originalId')){
                console.log('should be adding in the line');
                newLines.push(event.getParam('line'));
            }
        }
        component.set('v.lines', newLines);
    },
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
    }
})