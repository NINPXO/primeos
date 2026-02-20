import { Component, OnInit, inject, Inject, Optional } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { Goal, ProgressEntry } from '../../../core/models';
import { GoalsService } from '../../../core/services/goals.service';
import { ProgressService } from '../../../core/services/progress.service';

@Component({
  selector: 'app-progress-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatDialogModule,
    MatIconModule
  ],
  templateUrl: './progress-form.component.html',
  styleUrls: ['./progress-form.component.scss']
})
export class ProgressFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private goalsService = inject(GoalsService);
  private progressService = inject(ProgressService);
  private dialogRef = inject(MatDialogRef<ProgressFormComponent>);
  private dialogData = inject(MAT_DIALOG_DATA, { optional: true });

  form!: FormGroup;
  goals: Goal[] = [];
  isSubmitting: boolean = false;
  isEditMode: boolean = false;
  editingEntry?: ProgressEntry;

  ngOnInit(): void {
    this.checkEditMode();
    this.initializeForm();
    this.loadGoals();
  }

  private checkEditMode(): void {
    if (this.dialogData?.isEdit && this.dialogData?.entry) {
      this.isEditMode = true;
      this.editingEntry = this.dialogData.entry;
    }
  }

  private initializeForm(): void {
    const today = new Date().toISOString().split('T')[0];
    let initialValues = {
      goalId: '',
      value: '',
      date: today,
      note: ''
    };

    if (this.isEditMode && this.editingEntry) {
      initialValues = {
        goalId: this.editingEntry.goalId,
        value: this.editingEntry.value.toString(),
        date: this.editingEntry.date,
        note: this.editingEntry.note || ''
      };
    }

    this.form = this.fb.group({
      goalId: [initialValues.goalId, Validators.required],
      value: [initialValues.value, [Validators.required, Validators.min(0), Validators.pattern(/^\d+(\.\d+)?$/)]],
      date: [initialValues.date, Validators.required],
      note: [initialValues.note, Validators.maxLength(200)]
    });
  }

  private loadGoals(): void {
    this.goalsService.getGoals().subscribe(goals => {
      this.goals = goals.filter(g => g.status !== 'completed');
    });
  }

  async onSubmit(): Promise<void> {
    if (this.form.invalid) {
      this.markFormGroupTouched(this.form);
      return;
    }

    this.isSubmitting = true;
    try {
      const formValue = this.form.value;
      const entryData = {
        goalId: formValue.goalId,
        value: parseFloat(formValue.value),
        date: new Date(formValue.date).toISOString().split('T')[0],
        note: formValue.note || undefined
      };

      if (this.isEditMode && this.editingEntry) {
        await this.progressService.updateEntry(this.editingEntry.id, entryData);
      } else {
        await this.progressService.addEntry(entryData);
      }

      this.dialogRef.close(true);
    } catch (error) {
      console.error('Error saving progress:', error);
    } finally {
      this.isSubmitting = false;
    }
  }

  onCancel(): void {
    this.dialogRef.close();
  }

  private markFormGroupTouched(formGroup: FormGroup): void {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      control?.markAsTouched();
    });
  }

  getErrorMessage(fieldName: string): string {
    // Map display names to control names
    const controlNameMap: { [key: string]: string } = {
      'Goal': 'goalId',
      'Value': 'value',
      'Progress Value': 'value',
      'Date': 'date',
      'Note': 'note',
      'Notes': 'note'
    };

    const controlName = controlNameMap[fieldName] || fieldName;
    const control = this.form.get(controlName);

    if (!control) {
      return '';
    }

    if (control.hasError('required')) {
      return `${fieldName} is required`;
    }
    if (control.hasError('min')) {
      return `${fieldName} must be 0 or greater`;
    }
    if (control.hasError('pattern')) {
      return `${fieldName} must be a valid number`;
    }
    if (control.hasError('maxlength')) {
      const maxLength = control.errors?.['maxlength'].requiredLength;
      return `${fieldName} cannot exceed ${maxLength} characters`;
    }
    return '';
  }
}
