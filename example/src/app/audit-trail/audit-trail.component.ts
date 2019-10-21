import { Component, OnInit } from '@angular/core';
import { NavParams } from '@ionic/angular';

@Component({
  selector: 'app-audit-trail',
  templateUrl: './audit-trail.component.html',
  styleUrls: ['./audit-trail.component.scss'],
})
export class AuditTrailComponent implements OnInit {
  images=[];
  constructor(private navParams: NavParams) {
    var data = this.navParams.data;
    console.log(data);
    if(data["0"]){
      this.images.push("data:image/jpeg;base64," +data["0"]);
    }
    if(data["1"]){
      this.images.push("data:image/jpeg;base64," +data["1"]);
    }
    if(data["2"]){
      this.images.push("data:image/jpeg;base64," +data["2"]);
    }
    if(data["3"]){
      this.images.push("data:image/jpeg;base64," +data["3"]);
    }
    if(data["4"]){
      this.images.push("data:image/jpeg;base64," +data["4"]);
    }
    if(data["5"]){
      this.images.push("data:image/jpeg;base64," +data["5"]);
    }
   }

  ngOnInit() {}

}
