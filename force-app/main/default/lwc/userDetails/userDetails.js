import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from "@salesforce/user/Id";
import NAME_FIELD from '@salesforce/schema/User.Name';
//import ROLE_NAME_FIELD from '@salesforce/schema/User.UserRole.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class UserDetails extends LightningElement {
    @api userId = Id;
    userName;
    userRoleName;
    userEmail;

    @wire(getRecord, { recordId: '$userId', fields: [NAME_FIELD, EMAIL_FIELD] })
    userDetails({ error, data }) {
        if (error) {
            console.error('Error fetching user details:', error);
        } else if (data) {
            this.userName = getFieldValue(data, NAME_FIELD);
            this.userEmail = getFieldValue(data, EMAIL_FIELD);
        }
    }

    /*@wire(getRecord, { recordId: '$userId', fields: [ROLE_NAME_FIELD] })
    userRoleDetails({ error, data }) {
        if (error) {
            console.error('Error fetching user role details:', error);
        } else if (data) {
            this.userRoleName = data.fields.UserRole.value.fields.Name.value;
        }
    }*/
}