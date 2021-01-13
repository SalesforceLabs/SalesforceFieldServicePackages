import { LightningElement,track,api} from 'lwc';
import getStatuses from '@salesforce/apex/FSK_SAStatusCheckboxGroupController.getAppointmentStatus';
import loadFSLSKSettings from '@salesforce/apex/FSK_SettingsPageCtrl.getSettings';
import saveSkSettingsData from '@salesforce/apex/FSK_SettingsPageCtrl.saveSettings';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import { loadStyle } from 'lightning/platformResourceLoader';
import RewriteLWC from '@salesforce/resourceUrl/FSK_settingsMainExCss';

//TODO:change name g_.
export default class SettingsMain extends LightningElement {
    @track isLoading = false;

    @track sk_cs_settings;
    @track sk_cs_settings_2;
    @track scrolled = 0;
    @track showTopButton = false;
    @track startStValues = [];
    @track endStValues = [];
    @track h ;
    
    @track  excludeCategoriesStart = ['None', 'Canceled', 'Completed', 'CannotComplete'];
    @track  excludeCategoriesEnd = ['None', 'Canceled', 'Scheduled', 'Dispatched', 'InProgress'];
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
    @track g_status_selected = 'Completed';

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
        console.log('this.statusesStart == > ' + this.statusesStart);
        console.log('this.statusesEnd == > ' + this.statusesEnd);

        try {
            if(this.statusesStart != null && this.statusesEnd != null ){
               await this.setSK_CSTOPage();
            }
        } catch (error) {
            console.log('in error == > ' + JSON.parse(JSON.stringify(error.getMessage())));

            console.log(Error);
        } 
    }
    
    async getCustomSettingsSk(){
        this.isLoading = true;
        await loadFSLSKSettings().then(result => {
            this.isLoading = false;
            this.sk_cs_settings = result;
            this.error = undefined;
            console.log('statusesSsk_cs_settings ==> ' ,
             JSON.parse(JSON.stringify(this.sk_cs_settings))); 
             return result;   
        }).catch(error => {
            this.isLoading = false;
            this.error = error;
            this.sk_cs_settings = undefined;
        });
    }
    async setSK_CSTOPage(){
        console.log('setSK_CSTOPage == > ' + JSON.stringify(this.sk_cs_settings) );

        this.fl_cb_1 = this.sk_cs_settings.mobileStatusSatiation;
        this.fl_cb_2 = this.sk_cs_settings.actualTimes;
        this.fl_cb_3= this.sk_cs_settings.actualTimesOnGantt;

        //Statuses wired 2 + wired 1 
        if(this.sk_cs_settings.startingStatus != null ) {
            this.setStatusesOnStatusBase(this.sk_cs_settings.startingStatus,'START');
            }
        if(this.sk_cs_settings.endingStatus != null){
            this.setStatusesOnStatusBase(this.sk_cs_settings.endingStatus,'END');
        }

        //Mobile notifictaion
        this.mobileCannedCustomNotification = this.sk_cs_settings.mobileCannedCustomNotification;
        this.cbx_nm_Dis_1 = !this.mobileCannedCustomNotification;
        this.num_of_h_mn = this.sk_cs_settings.hoursforDispNotif;

        this.fl_cb_mn_1 = this.sk_cs_settings.dispatchedNotification;
        this.fl_cb_mn_2 = this.sk_cs_settings.emerDispatchedNotification;
        this.fl_cb_mn_3 = this.sk_cs_settings.cancelationNotification;

        //General 
        this.num_of_days_g = this.sk_cs_settings.daysUntilFirstMain;
        this.cb_g__1 = this.sk_cs_settings.addAssetToMaintenancePlan;
        this.cb_g__2 = this.sk_cs_settings.createFSLResourceFromUser;
        this.cb_g__3 = this.sk_cs_settings.excludedSROnSARejection;
        this.cb_g__4 = this.sk_cs_settings.assignResourceOnServiceAppointment;
        this.cb_g__5 = this.sk_cs_settings.populateWorkOrderLookup;
        this.cb_g__6 = this.sk_cs_settings.setGanttLabel;
        this.cb_g__7 = this.sk_cs_settings.removeLicensesOnDeactivation; 
        this.num_of_d_inp_Dis = !this.cb_g__1;
    }
   
    async buildData(){
        //Clone for update
        this.sk_cs_settings_2 = JSON.parse(JSON.stringify(this.sk_cs_settings));

        this.sk_cs_settings_2.hoursforDispNotif = this.num_of_h_mn;

        this.sk_cs_settings_2.mobileStatusSatiation = this.fl_cb_1;
        this.sk_cs_settings_2.actualTimes = this.fl_cb_2;
        this.sk_cs_settings_2.actualTimesOnGantt = this.fl_cb_3;

        console.log('start st == > ' + this.startStValues.toString());
        console.log('end st == > ' + this.endStValues.toString());

        this.sk_cs_settings_2.startingStatus = this.startStValues.toString();
        this.sk_cs_settings_2.endingStatus = this.endStValues.toString();

        this.sk_cs_settings.mobileCannedCustomNotification = this.mobileCannedCustomNotification;
        this.sk_cs_settings_2.dispatchedNotification = this.fl_cb_mn_1;
        this.sk_cs_settings_2.emerDispatchedNotification = this.fl_cb_mn_2;
        this.sk_cs_settings_2.cancelationNotification = this.fl_cb_mn_3;

        this.sk_cs_settings_2.daysUntilFirstMain = this.num_of_days_g;
        this.sk_cs_settings_2.successfulAssetInstallation = this.g_status_selected;

        this.sk_cs_settings_2.addAssetToMaintenancePlan = this.cb_g__1;
        this.sk_cs_settings_2.createFSLResourceFromUser = this.cb_g__2;
        this.sk_cs_settings_2.excludedSROnSARejection = this.cb_g__3;
        this.sk_cs_settings_2.assignResourceOnServiceAppointment = this.cb_g__4;
        this.sk_cs_settings_2.populateWorkOrderLookup = this.cb_g__5;
        this.sk_cs_settings_2.setGanttLabel = this.cb_g__6;
        this.sk_cs_settings_2.removeLicensesOnDeactivation = this.cb_g__7;

        console.log('data to save == >1' +  JSON.stringify(this.sk_cs_settings_2));        
    }
    async saveData(){
        await this.buildData();
        await this.savePageSettings();
    }

    async savePageSettings(){
        this.isLoading = true;
        console.log('data to save == >2' +  JSON.stringify(this.sk_cs_settings_2));        

        await saveSkSettingsData({skWrapperObj : this.sk_cs_settings_2})
        .then(result => {
            console.log('result 44 == >' +JSON.stringify(result));
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: result.msg,
                variant: result.isSuccess ? 'success' : 'error'
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            console.log('error 44 == >' +JSON.stringify(error));

            this.error = error;
            this.isLoading = false;
        });
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
    
    handleNumOfHChange(e) {
        this.num_of_h_mn = e.detail.value;
    }
    handleNumOfDaysChange(e) {
        this.num_of_days_g = e.detail.value;
    }
    toggleChange(){
        this.mobileCannedCustomNotification = !this.mobileCannedCustomNotification;
        this.cbx_nm_Dis_1 = !this.cbx_nm_Dis_1; 
        // this.cbx_nm_Dis_2 = !this.cbx_nm_Dis_2;
        // this.cbx_nm_Dis_3 = !this.cbx_nm_Dis_3; 
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
        this.endStValues = e.detail.value;
    }
    handleStartStChange(e) {
        this.startStValues = e.detail.value;
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