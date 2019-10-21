import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { RouteReuseStrategy } from '@angular/router';

import { IonicModule, IonicRouteStrategy } from '@ionic/angular';
import { SplashScreen } from '@ionic-native/splash-screen/ngx';
import { StatusBar } from '@ionic-native/status-bar/ngx';

import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import {SettingComponent} from './setting/setting.component';
import {ComponentsModule} from './setting/components.module';
import {AuditTrailComponent} from './audit-trail/audit-trail.component';
import {ComponentsModule2} from './audit-trail/components.module';

@NgModule({
  declarations: [AppComponent],
  entryComponents: [SettingComponent,AuditTrailComponent],
  imports: [BrowserModule, IonicModule.forRoot(), AppRoutingModule,ComponentsModule,ComponentsModule2],
  providers: [
    StatusBar,
    SplashScreen,
    { provide: RouteReuseStrategy, useClass: IonicRouteStrategy }
  ],
  bootstrap: [AppComponent]
})
export class AppModule {}
