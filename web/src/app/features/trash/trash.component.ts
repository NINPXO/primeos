import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-trash',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="trash">
      <h1>Trash</h1>
      <p>Deleted items will appear here</p>
    </div>
  `,
  styles: [`
    .trash {
      padding: 20px;
    }
  `]
})
export class TrashComponent {}
