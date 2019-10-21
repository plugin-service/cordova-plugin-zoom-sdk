import { NgModule } from '@angular/core';
import { AuditTrailComponent } from './audit-trail.component';
import { IonicModule } from '@ionic/angular';
import {CommonModule} from '@angular/common';

@NgModule({
    declarations: [AuditTrailComponent],
    imports: [IonicModule,CommonModule],
    exports: [AuditTrailComponent]
})

export class ComponentsModule2 {}
