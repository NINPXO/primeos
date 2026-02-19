import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { Goal } from '../../../core/models';
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

  form!: FormGroup;
  goals: Goal[] = [];
  isSubmitting: boolean = false;

  ngOnInit(): void {
    this.initializeForm();
    this.loadGoals();
  }

  private initializeForm(): void {
    const today = new Date().toISOString().split('T')[0];
    this.form = this.fb.group({
      goalId: ['', Validators.required],
      value: ['', [Validators.required, Validators.min(0), Validators.pattern(/^\d+(\.\d+)?$/)]],
      date: [today, Validators.required],
      note: ['', Validators.maxLength(200)]
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
      await this.progressService.addEntry({
        goalId: formValue.goalId,
        value: parseFloat(formValue.value),
        date: new Date(formValue.date).toISOString().split('T')[0],
        note: formValue.note || undefined
      });

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
    const control = this.form.get(fieldName);
    if (control?.hasError('required')) {
      return `${fieldName} is required`;
    }
    if (control?.hasError('min')) {
      return `${fieldName} must be 0 or greater`;
    }
    if (control?.hasError('pattern')) {
      return `${fieldName} must be a valid number`;
    }
    if (control?.hasError('maxlength')) {
      return `${fieldName} cannot exceed ${control.errors?.['maxlength'].requiredLength} characters`;
    }
    return '';
  }
}
