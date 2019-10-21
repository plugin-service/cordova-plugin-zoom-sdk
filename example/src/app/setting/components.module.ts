import { NgModule } from '@angular/core';
import { SettingComponent } from './setting.component';
import { IonicModule } from '@ionic/angular';
import {CommonModule} from '@angular/common';

@NgModule({
    declarations: [SettingComponent],
    imports: [IonicModule,CommonModule],
    exports: [SettingComponent]
})

export class ComponentsModule {}
