/**
 * Created by Ronan Williams on 07/02/2019.
 */
({

    afterRender : function(component, helper) {
        var acctlistInputCmp = component.find("opplistInput");
        var acctlistInput = acctlistInputCmp.getElement();
        acctlistInput.setAttribute("list", "opplist");
        return this.superAfterRender();
    }

})