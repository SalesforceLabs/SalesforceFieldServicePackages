import { LightningElement,track} from 'lwc';
import getStatuses from '@salesforce/apex/FSK_SAStatusCheckboxGroupController.getAppointmentStatus';
import loadFSLSKSettings from '@salesforce/apex/FSK_SettingsPageCtrl.getSK_SettingsCSFromOrg';
import saveSkSettingsData from '@salesforce/apex/FSK_SettingsPageCtrl.saveSkSettings';

import { loadStyle } from 'lightning/platformResourceLoader';
import RewriteLWC from '@salesforce/resourceUrl/FSK_settingsMainExCss';

export default class SettingsMain extends LightningElement {
    @track sk_cs_settings;
    @track sk_cs_settings_2;
    @track scrolled = 0;
    @track showTopButton = false;
    @track startStValues = [];
    @track endStValues = [];
    @track h ;
    
    @track  excludeCategoriesStart = ['Canceled','None' ,'Completed', 'CannotComplete'];
    @track  excludeCategoriesEnd = ['None', 'Scheduled', 'Dispatched', 'InProgress'];
    @track  excludeCategoriesComplete = ['None', 'Scheduled', 'Dispatched', 'InProgress',
                                        'Canceled','None' , 'CannotComplete'];

    @track statusesStart;
    @track statusesEnd;
    @track statusesComplete;

    //Status base args
    @track fl_cb_1;
    @track fl_cb_2;
    @track fl_cb_3;

    //Mobile notification args

    @track fl_cb_mn_1;
    @track fl_cb_mn_2;
    @track fl_cb_mn_3;

    @track num_of_h_mn;
    @track mn_tg_val;
    @track cbx_nm_Dis_1;
    @track cbx_nm_Dis_2;
    @track cbx_nm_Dis_3;

    //General
    @track num_of_h_g;
    @track num_of_d_inp_Dis;

    @track cb_g__1;
    @track cb_g__2;
    @track cb_g__3;
    @track cb_g__4;
    @track cb_g__5;
    @track cb_g__6;
    @track cb_g__7;

    //combobox
    @track g_status_selected;

    @track stEndValues = [];
    @track stStartValues = [];

    onSB1Change(){
        this.fl_cb_1 = !this.fl_cb_1;
        
    }  
    onSB2Change(){
        this.fl_cb_2 = !this.fl_cb_2;
    }  
    onSB3Change(){
        this.fl_cb_3 = !this.fl_cb_3;
    }  

     async connectedCallback(){
        
        try {
            await loadStyle(this, RewriteLWC);
            this.setPage();    
            //todo set the values 
            //Status base 
            this.fl_cb_1 = false;
            this.fl_cb_2 = false;
            this.fl_cb_3= false;
    

            //Mobile notifictaion
            this.fl_cb_mn_1 = false;
            this.fl_cb_mn_2 = false;
            this.fl_cb_mn_3 = false;
            this.num_of_h_mn = 0;
            this.mn_tg_val = false;
            this.cbx_nm_Dis_1 = true;
            this.cbx_nm_Dis_2 = true;
            this.cbx_nm_Dis_3 = true;

            //General 
            this.num_of_days_g = 0;
            this.num_of_d_inp_Dis = true;
            this.cb_g__1 = false;
            this.cb_g__2 = false;
            this.cb_g__3 = false;
            this.cb_g__4 = false;
            this.cb_g__5 = false;
            this.cb_g__6 = false;

          } catch (error) {
            console.log(error);
          }

        

    }
    async setPage(){
        await this.getStatusesExc(this.excludeCategoriesStart,'START'); 
        await this.getStatusesExc(this.excludeCategoriesEnd,'END');
        await this.getStatusesExc(this.excludeCategoriesComplete,'COMPLETE'); 
        await this.getCS();
    }
    async getCS(){
        await this.getCustomSettingsSk(); 
        console.log('customSettingsSK == > ' + this.sk_cs_settings);
        try {
            if(this.statusesStart != null && this.statusesEnd != null ){
               await this.setSK_CSTOPage();
            }
        } catch (error) {
            console.log(Error);
        } 
    }
    
    async getCustomSettingsSk(){
       await loadFSLSKSettings().then(result => {
            this.sk_cs_settings = result;
            this.error = undefined;
            console.log('statusesSsk_cs_settingstart ==> ' ,
             JSON.parse(JSON.stringify(this.sk_cs_settings))); 
             return result;   
        }).catch(error => {
            this.error = error;
            this.sk_cs_settings = undefined;
        });
    }
    async setSK_CSTOPage(){
        this.fl_cb_1 = this.sk_cs_settings.Mobile_Status_Satiation__c;
        this.fl_cb_2 = this.sk_cs_settings.ActualTimes__c;
        this.fl_cb_3= this.sk_cs_settings.Actual_Times_on_Gantt__c;

        //Statuses wired 2 + wired 1 
        this.setStatusesOnStatusBase(this.sk_cs_settings.StartingStatus__c,'START');
  
        this.setStatusesOnStatusBase(this.sk_cs_settings.EndingStatus__c,'END');

        //Mobile notifictaion
        this.num_of_h_mn = this.sk_cs_settings.Hours_for_Dispatched_Notification__c;
        this.fl_cb_mn_1 = this.sk_cs_settings.Dispatched_Notification__c;
        this.fl_cb_mn_2 = this.sk_cs_settings.Emergency_Dispatched_Notification__c;
        this.fl_cb_mn_3 = this.sk_cs_settings.Cancelation_Notification__c;

        //General 
        this.num_of_days_g = this.sk_cs_settings.Days_Until_First_Maintenance__c;
        this.cb_g__1 = this.sk_cs_settings.Add_Asset_to_Maintenance_Plan__c;
        this.num_of_d_inp_Dis = !this.cb_g__1;
        this.cb_g__2 = this.sk_cs_settings.Create_FSL_Resource_From_User__c;
        this.cb_g__3 = this.sk_cs_settings.Excluded_SR_on_SA_Rejection__c;
        this.cb_g__4 = this.sk_cs_settings.Excluded_SR_on_SA_Rejection__c;
        this.cb_g__5 = this.sk_cs_settings.Populate_Work_Order_Lookup__c;
        this.cb_g__6 = this.sk_cs_settings.Populate_Work_Order_Lookup__c;
        this.cb_g__7 = this.sk_cs_settings.Set_Gantt_Label__c; 
    }
   
    async buildData(){
        //Clone for update
        this.sk_cs_settings_2 = JSON.parse(JSON.stringify(this.sk_cs_settings));

        this.sk_cs_settings_2.Hours_for_Dispatched_Notification__c = this.num_of_h_mn;
        this.sk_cs_settings_2.Mobile_Status_Satiation__c = this.fl_cb_1;
        this.sk_cs_settings_2.ActualTimes__c = this.fl_cb_2;
        this.sk_cs_settings_2.Actual_Times_on_Gantt__c = this.fl_cb_3;

        this.sk_cs_settings_2.Dispatched_Notification__c = this.fl_cb_mn_1;
        this.sk_cs_settings_2.Emergency_Dispatched_Notification__c = this.fl_cb_mn_2;
        this.sk_cs_settings_2.Cancelation_Notification__c = this.fl_cb_mn_3;

        this.sk_cs_settings_2.Days_Until_First_Maintenance__c = this.num_of_days_g;
        this.sk_cs_settings_2.Successful_Asset_Installation_Status__c = this.g_status_selected;

        this.sk_cs_settings_2.Add_Asset_to_Maintenance_Plan__c = this.cb_g__1;
        this.sk_cs_settings_2.Create_FSL_Resource_From_User__c = this.cb_g__2;
        this.sk_cs_settings_2.Excluded_SR_on_SA_Rejection__c = this.cb_g__3;
        this.sk_cs_settings_2.Populate_Work_Order_Lookup__c = this.cb_g__4;
        this.sk_cs_settings_2.Populate_Work_Order_Lookup__c = this.cb_g__5;
        this.sk_cs_settings_2.Set_Gantt_Label__c = this.cb_g__6;
        console.log('data to save == >' +  JSON.stringify(this.sk_cs_settings_2));        
    }
    async saveData(){
        await this.buildData();
        await this.savePageSettings();
    }

    async savePageSettings(){
        await saveSkSettingsData({skToUpsert : this.sk_cs_settings_2});
    }

     setStatusesOnStatusBase(backendStatuses, token){  
        var backendStatusesArr = backendStatuses.split(",");
       console.log('backendStatusesArr ==> ' + backendStatusesArr);
        backendStatusesArr.forEach((ba_option) => {
            if(token == 'START'){

                //Find if the status start on page is selected 
                this.statusesStart.forEach((element) => { 
                    let value = element["value"];
                    if(value == ba_option ){
                        this.startStValues.push(ba_option);
                    }
                })
            }
            else if(token == 'END'){

                 //Find if the status end on page is selected 
                 this.statusesEnd.forEach((element) => { 
                    let value = element["value"];
                    if(value == ba_option ){
                        console.log('found == > ' + ba_option);
                        this.endStValues.push(ba_option);
                    }
                })
            }
        })
    }
    get getStatusStartList(){
        return this.statusesStart != ''? this.statusesStart : '';
    }
    toggleChange(){
        this.cbx_nm_Dis_1 = !this.cbx_nm_Dis_1; 
        this.cbx_nm_Dis_2 = !this.cbx_nm_Dis_2; 
        this.cbx_nm_Dis_3 = !this.cbx_nm_Dis_3; 
    }

    //Mobile Notification
    onMN1ChecboxChange(){
        this.fl_cb_mn_1 = !this.fl_cb_mn_1;
    }
    onMN2ChecboxChange(){
        this.fl_cb_mn_2 = !this.fl_cb_mn_2;
    }
    onMN3ChecboxChange(){
        this.fl_cb_mn_3 = !this.fl_cb_mn_3;
    }

    //General
    onG1ChecboxChange(){
        this.cb_g__1 = !this.cb_g__1;
        if(this.cb_g__1 == true ){
            this.num_of_d_inp_Dis = false;
        }
        else{
            this.num_of_d_inp_Dis = true;
 
        }
    }
    onG2ChecboxChange(){
        this.cb_g__2 = !this.cb_g__2;
    }
    onG3ChecboxChange(){
        this.cb_g__3 = !this.cb_g__3;
    }
    onG4ChecboxChange(){
        this.cb_g__4 = !this.cb_g__4;
    }
    onG5ChecboxChange(){
        this.cb_g__5 = !this.cb_g__5;
    }
    onG6ChecboxChange(){
        this.cb_g__6 = !this.cb_g__6;
    }
    onG7ChecboxChange(){
        this.cb_g__7 = !this.cb_g__7;
    }

    handleEndStChange(e) {
        this.stEndValues = e.detail.value;
    }
    handleStartStChange(e) {
        this.stStartValues = e.detail.value;
    }

    getStatusStart1(){
        getStatuses({excludeCategories:  '$excludeCategoriesStart'}).then(result => {
            this.statusesStart = result;
            this.error = undefined;
            console.log('statusesStart ==> ' ,
             JSON.parse(JSON.stringify(this.statusesStart)));   
        }).catch(error => {
            this.error = error;
            this.statusesStart = undefined;
        });
    }

    async getStatusesExc(excludeStatuses,token){
        await getStatuses({excludeCategories:  excludeStatuses}).then(result => {
            if(token == 'START'){
                this.statusesStart = result;
                console.log('statuses statusesStart==> ' ,
                JSON.parse(JSON.stringify(this.statusesStart)));   

            }
            else if(token == 'END'){
                this.statusesEnd = result;
                console.log('statuses statusesEnd==> ' ,
                JSON.parse(JSON.stringify(this.statusesEnd)));   

            }
            else if(token == 'COMPLETE'){
                this.statusesComplete = result;
                console.log('statuses statusesComplete==> ' ,
                JSON.parse(JSON.stringify(this.statusesComplete))); 
            }
            this.error = undefined;
        }).catch(error => {
            this.error = error;
            this.statusesEnd = undefined;
        });
    }
    get getStatusEndList(){
        return this.statusesEnd != ''? this.statusesEnd : '';
    }
    get getExclCategories(){
        this.excludeCategories = 'Canceled,None';
        return this.excludeCategories;
    }
    onScroll(event) {
        this.scrolled = event.target.scrollTop;
        h = event.target.scrollTop;
    }  
    get titleHeaderleft(){
        return `width: 100%;`;
    }
    get cardHeaderStyle(){
        return `
            display:flex;
           
            `;
    }
    get rightCLineWTgl(){
        return `
                width:50%;
                display: flex;
                flex-direction: row-reverse;
                 `;
    }
    get rightCLineL(){
        return `
                width:50%;
                display: flex;
                 `;
    }
    handleChangeCmbx(e) {
        this.g_status_selected = e.detail.value;
    }
}