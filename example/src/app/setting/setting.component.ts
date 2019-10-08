import { Component, OnInit } from '@angular/core';
import { PopoverController } from '@ionic/angular';

@Component({
  selector: 'app-setting',
  templateUrl: './setting.component.html',
  styleUrls: ['./setting.component.scss'],
})
export class SettingComponent implements OnInit {

  constructor(
    private popoverController: PopoverController) { }

  ngOnInit() {}
  setBrandingLogo(){
    this.popoverController.dismiss("setBrandingLogo");
  }
  setMainForeGroundColors(){
    this.popoverController.dismiss("setMainForeGroundColors");
  }

  setMainBackGroundColors(){
    this.popoverController.dismiss("setMainBackGroundColors");
  }
  setDefaultTheme(){
    this.popoverController.dismiss("setDefaultTheme");
  }
  setDarkTheme(){
    this.popoverController.dismiss("setDarkTheme");
  }
  setMidnightTheme(){
    this.popoverController.dismiss("setMidnightTheme");
  }
  setSunsetTheme(){
    this.popoverController.dismiss("setSunsetTheme");
  }

}
