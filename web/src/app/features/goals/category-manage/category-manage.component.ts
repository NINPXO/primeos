import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { GoalCategory } from '../../../core/models';
import { GoalsService } from '../../../core/services/goals.service';

@Component({
  selector: 'app-category-manage',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatListModule,
    MatIconModule,
    MatDialogModule,
    MatTooltipModule
  ],
  templateUrl: './category-manage.component.html',
  styleUrls: ['./category-manage.component.scss']
})
export class CategoryManageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private goalsService = inject(GoalsService);
  private dialogRef = inject(MatDialogRef<CategoryManageComponent>);

  form!: FormGroup;
  categories: GoalCategory[] = [];
  isSubmitting: boolean = false;

  ngOnInit(): void {
    this.initializeForm();
    this.loadCategories();
  }

  private initializeForm(): void {
    this.form = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(50)]],
      color: ['#2196F3', Validators.required]
    });
  }

  private loadCategories(): void {
    this.goalsService.getCategories().subscribe(categories => {
      this.categories = categories;
    });
  }

  async addCategory(): Promise<void> {
    if (this.form.invalid) {
      this.form.get('name')?.markAsTouched();
      this.form.get('color')?.markAsTouched();
      return;
    }

    this.isSubmitting = true;
    try {
      const formValue = this.form.value;
      await this.goalsService.addCategory({
        name: formValue.name,
        color: formValue.color
      });
      this.form.reset({ color: '#2196F3' });
    } catch (error) {
      console.error('Error adding category:', error);
    } finally {
      this.isSubmitting = false;
    }
  }

  async deleteCategory(id: string): Promise<void> {
    const category = this.categories.find(c => c.id === id);
    if (category?.isSystem) {
      alert('Cannot delete system categories');
      return;
    }

    if (confirm(`Are you sure you want to delete "${category?.name}"?`)) {
      try {
        await this.goalsService.deleteCategory(id);
      } catch (error) {
        console.error('Error deleting category:', error);
      }
    }
  }

  onClose(): void {
    this.dialogRef.close(true);
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
