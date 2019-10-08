import { Component, NgZone } from '@angular/core';
import { Platform,PopoverController } from '@ionic/angular';
import { SettingComponent } from '../setting/setting.component';
var ZoomAuthEval: any;

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {
  logMessage = "";
  userId = ""
  constructor(private ngZone: NgZone, private platform: Platform,private popoverController:PopoverController) {
    this.platform.ready().then(() => {
      var lickey = 'Enter your Zoom SDK license key here';
      console.log(window);
      ZoomAuthEval = window['ZoomAuthEval']
      ZoomAuthEval.initialize(lickey, (success) => {
        this.logMessage="";
        this.addLogMessage("initialize - success")
        this.addLogMessage(success)
      }, (error) => {
        this.logMessage="";
        this.addLogMessage("initialize - error")
        this.addLogMessage(error)
      });
    })
  }
  verify() {
    ZoomAuthEval.verify((success) => {
      this.logMessage="";
      this.addLogMessage("verify - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("verify - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  getSdkStatus() {
    ZoomAuthEval.getSdkStatus((success) => {
      this.logMessage="";
      this.addLogMessage("getSdkStatus - success")
      this.addLogMessage(success)
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("getSdkStatus - error")
      this.addLogMessage(error)
    })
  }

  getVersion() {
    ZoomAuthEval.getVersion((success) => {
      this.logMessage="";
      this.addLogMessage("getVersion - success")
      this.addLogMessage(success)
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("getVersion - error")
      this.addLogMessage(error)
    })
  }

  getUserEnrollmentStatus() {
    ZoomAuthEval.getUserEnrollmentStatus(this.userId, (success) => {
      this.logMessage="";
      this.addLogMessage("enrollment status - success")
      this.addLogMessage(success)
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("enrollment status - error")
      this.addLogMessage(error)
    })
  }

  isUserEnrolled() {
    ZoomAuthEval.isUserEnrolled(this.userId, (success) => {
      this.logMessage="";
      this.addLogMessage("isUserEnrolled - success")
      this.addLogMessage(success)
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("isUserEnrolled - error")
      this.addLogMessage(error)
    })
  }

  addLogMessage(msg) {
    this.ngZone.run(() => {
      msg += "\n"
      this.logMessage += msg;
    })
  }

  clearMessage() {
    this.logMessage = "";
  }

  exit() {
    navigator['app'].exitApp();
  }

  enroll() {
    this.addLogMessage(this.userId);
    ZoomAuthEval.enroll(this.userId, (success) => {
      this.logMessage="";
      this.addLogMessage("enroll - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("enroll - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  authenticate() {
    this.addLogMessage(this.userId);
    ZoomAuthEval.authenticate(this.userId, (success) => {
      this.logMessage="";
      this.addLogMessage("authenticate - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("authenticate - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  setBrandingLogo(enable){
    ZoomAuthEval.setBrandingLogo(enable, (success) => {
      this.logMessage="";
      this.addLogMessage("branding logo - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("branding logo - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  setMainForeGroundColors(){
    ZoomAuthEval.setMainForeGroundColor("#0000FF", (success) => {
      this.logMessage="";
      this.addLogMessage("Foreground color - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("Foreground color - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }
  setMainBackGroundColors(){
    ZoomAuthEval.setMainBackGroundColor("#FF0000", (success) => {
      this.logMessage="";
      this.addLogMessage("Background color - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("Background color - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  idCheck(){
    ZoomAuthEval.idCheck((success) => {
      this.logMessage="";
      this.addLogMessage("idCheck - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("idCheck - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  deleteEnrollment(){
    this.addLogMessage(this.userId);
    ZoomAuthEval.deleteEnrollment(this.userId, (success) => {
      this.logMessage="";
      this.addLogMessage("deleteEnrollment - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("deleteEnrollment - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  auditTrail(){
    ZoomAuthEval.auditTrail((success) => {
      this.logMessage="";
      this.addLogMessage("auditTrail - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("auditTrail - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  setDefaultTheme(){
    ZoomAuthEval.setDefaultTheme((success) => {
      this.logMessage="";
      this.addLogMessage("setDefaultTheme - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("setDefaultTheme - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  setDarkTheme(){
    ZoomAuthEval.setDarkTheme((success) => {
      this.logMessage="";
      this.addLogMessage("setDarkTheme - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("setDarkTheme - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  setMidnightTheme(){
    ZoomAuthEval.setMidnightTheme((success) => {
      this.logMessage="";
      this.addLogMessage("setMidnightTheme - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("setMidnightTheme - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  setSunsetTheme(){
    ZoomAuthEval.setSunsetTheme((success) => {
      this.logMessage="";
      this.addLogMessage("setSunsetTheme - success")
      this.addLogMessage(JSON.stringify(success))
    }, (error) => {
      this.logMessage="";
      this.addLogMessage("setSunsetTheme - error")
      this.addLogMessage(JSON.stringify(error))
    })
  }

  async settings(ev: any) {
    const popover = await this.popoverController.create({
      component: SettingComponent,
      event: ev,

    });
    popover.onDidDismiss().then((data)=>{
      if(data.data==="setBrandingLogo"){
        this.setBrandingLogo('true');
      }else if(data.data==="setMainForeGroundColors"){
        this.setMainForeGroundColors();
      }else if(data.data==="setMainBackGroundColors"){
        this.setMainBackGroundColors();
      }else if(data.data==="setDefaultTheme"){
        this.setDefaultTheme();
      }else if(data.data==="setDarkTheme"){
        this.setDarkTheme();
      }else if(data.data==="setMidnightTheme"){
        this.setMidnightTheme();
      }else if(data.data==="setSunsetTheme"){
        this.setSunsetTheme();
      }
    })

    return await popover.present();
  }
}
