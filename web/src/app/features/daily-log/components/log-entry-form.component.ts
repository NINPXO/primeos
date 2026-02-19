import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatInputModule } from '@angular/material/input';
import { MatDialogModule } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { LogCategory, LogEntryWithCategory } from '../../../shared/models';

interface FormData {
  categoryId: string;
  note: string;
}

/**
 * Log Entry Form Component
 * Modal form to add/edit log entries
 */
@Component({
  selector: 'app-log-entry-form',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatSelectModule,
    MatInputModule,
    MatDialogModule,
    MatIconModule,
  ],
  templateUrl: './log-entry-form.component.html',
  styleUrl: './log-entry-form.component.scss',
})
export class LogEntryFormComponent implements OnInit {
  @Input() categories: LogCategory[] = [];
  @Input() entry: LogEntryWithCategory | null = null;
  @Input() currentDate: string = '';

  @Output() save = new EventEmitter<FormData>();
  @Output() cancel = new EventEmitter<void>();

  form: FormData = {
    categoryId: '',
    note: '',
  };

  isEdit = false;
  errors: string[] = [];

  ngOnInit(): void {
    if (this.entry) {
      this.isEdit = true;
      this.form = {
        categoryId: this.entry.categoryId,
        note: this.entry.note,
      };
    } else {
      this.isEdit = false;
      // Set first category as default if available
      if (this.categories.length > 0) {
        this.form.categoryId = this.categories[0].id;
      }
    }
  }

  /**
   * Validate form
   */
  validate(): boolean {
    this.errors = [];

    if (!this.form.categoryId) {
      this.errors.push('Category is required');
    }

    if (!this.form.note.trim()) {
      this.errors.push('Note is required');
    }

    return this.errors.length === 0;
  }

  /**
   * Handle save
   */
  onSave(): void {
    if (this.validate()) {
      this.save.emit(this.form);
    }
  }

  /**
   * Handle cancel
   */
  onCancel(): void {
    this.cancel.emit();
  }

  /**
   * Get category name by id
   */
  getCategoryName(categoryId: string): string {
    return (
      this.categories.find((c) => c.id === categoryId)?.name || 'Unknown'
    );
  }
}
