import { Component, Inject, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatDialogModule, MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { Goal, GoalCategory } from '../../../core/models';
import { GoalsService } from '../../../core/services/goals.service';

@Component({
  selector: 'app-goal-form',
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
  templateUrl: './goal-form.component.html',
  styleUrls: ['./goal-form.component.scss']
})
export class GoalFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private goalsService = inject(GoalsService);
  private dialogRef = inject(MatDialogRef<GoalFormComponent>);
  @Inject(MAT_DIALOG_DATA) data: Goal | undefined;

  form!: FormGroup;
  categories: GoalCategory[] = [];
  isEditMode: boolean = false;
  isSubmitting: boolean = false;

  ngOnInit(): void {
    this.isEditMode = !!this.data;
    this.initializeForm();
    this.loadCategories();
  }

  private initializeForm(): void {
    this.form = this.fb.group({
      title: [
        this.data?.title || '',
        [Validators.required, Validators.minLength(3), Validators.maxLength(100)]
      ],
      description: [this.data?.description || '', Validators.maxLength(500)],
      categoryId: [this.data?.categoryId || '', Validators.required],
      targetDate: [
        this.data?.targetDate ? new Date(this.data.targetDate) : '',
        Validators.required
      ],
      status: [this.data?.status || 'active', Validators.required]
    });
  }

  private loadCategories(): void {
    this.goalsService.getCategories().subscribe(categories => {
      this.categories = categories;
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
      const goalData = {
        title: formValue.title,
        description: formValue.description,
        categoryId: formValue.categoryId,
        targetDate: new Date(formValue.targetDate).toISOString().split('T')[0],
        status: formValue.status
      };

      if (this.isEditMode && this.data) {
        await this.goalsService.updateGoal(this.data.id, goalData);
      } else {
        await this.goalsService.addGoal(goalData as any);
      }

      this.dialogRef.close(true);
    } catch (error) {
      console.error('Error saving goal:', error);
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
    if (control?.hasError('minlength')) {
      return `${fieldName} must be at least ${control.errors?.['minlength'].requiredLength} characters`;
    }
    if (control?.hasError('maxlength')) {
      return `${fieldName} cannot exceed ${control.errors?.['maxlength'].requiredLength} characters`;
    }
    return '';
  }
}
