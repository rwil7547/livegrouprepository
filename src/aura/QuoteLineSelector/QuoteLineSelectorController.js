({
    doInit : function(component,event,helper){
    	var action = component.get('c.getFamilies');
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                component.set('v.families', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    filterFamily : function(component, event, helper) {
        
        // var products = document.getElementsByClassName('product');
        var family = component.find('families').get("v.value");
        
        // for (var x = 0; x < products.length; x++){
        //     if (!family || products[x].dataset.family === family){
        //         products[x].style.display = 'flex';
        //     } else {
        //         products[x].style.display = 'none';
        //     }
        // }
        //
        var familyBlocks = document.getElementsByClassName('familyBlock');

        for (var x = 0; x < familyBlocks.length; x++){
            if (family === 'All' || familyBlocks[x].id === family){
                familyBlocks[x].style.display = 'block';
            } else{
                familyBlocks[x].style.display = 'none';
            }
        }

    },
    handleKeyUp : function(component,event,helper){
        var input   = component.find('enter-search').get('v.value').toUpperCase();
        var products = document.getElementsByClassName('product');
        
        for (var x = 0; x < products.length; x++){
            var name = products[x].dataset.name.toUpperCase();
            if (name.search(input) === -1) {
                products[x].style.display = 'none';
            } else {
                products[x].style.display = 'flex';
            }            
        }
    },
    handleSelect : function(component,event,helper){
        var selected 	= event.getParam('selected');
        var id 			= event.getParam('productId');
        var selectedIds = component.get('v.selectedIds');   
        if (selected){
            selectedIds.push(id);
            component.set('v.selectedIds',selectedIds);
        } else if (selectedIds.includes(id)){
            selectedIds.splice(selectedIds.indexOf(id),1);
            component.set('v.selectedIds',selectedIds);
        }
    },
    close : function(component,event,helper){
        var closeModal = component.getEvent('closeModal');
        closeModal.fire();
        if (component.get('v.selectedIds').length > 0){
        	component.set('v.selectedIds',[]);   
            $A.get("e.c:DeselectAllProducts").fire();
        }

    },
    addSelected : function(component, event, helper){
        var addGroupedProducts = component.getEvent('addGroupedProducts');
        var poductIds = component.get('v.selectedIds');
        addGroupedProducts.setParams({
            productIds : poductIds
        });
        addGroupedProducts.fire();
        component.set('v.selectedIds',[]);
        $A.get("e.c:DeselectAllProducts").fire();
    }
})