import { ComponentFixture, TestBed } from '@angular/core/testing';
import { GoalsComponent } from './goals.component';
import { GoalsService } from '../../core/services/goals.service';
import { MatDialog } from '@angular/material/dialog';
import { of } from 'rxjs';

describe('GoalsComponent', () => {
  let component: GoalsComponent;
  let fixture: ComponentFixture<GoalsComponent>;
  let goalsService: jasmine.SpyObj<GoalsService>;
  let matDialog: jasmine.SpyObj<MatDialog>;

  beforeEach(async () => {
    const goalsServiceSpy = jasmine.createSpyObj('GoalsService', [
      'getGoals',
      'getCategories',
      'loadGoals',
      'deleteGoal'
    ]);
    const dialogSpy = jasmine.createSpyObj('MatDialog', ['open']);

    goalsServiceSpy.getGoals.and.returnValue(of([]));
    goalsServiceSpy.getCategories.and.returnValue(of([]));

    await TestBed.configureTestingModule({
      imports: [GoalsComponent],
      providers: [
        { provide: GoalsService, useValue: goalsServiceSpy },
        { provide: MatDialog, useValue: dialogSpy }
      ]
    }).compileComponents();

    goalsService = TestBed.inject(GoalsService) as jasmine.SpyObj<GoalsService>;
    matDialog = TestBed.inject(MatDialog) as jasmine.SpyObj<MatDialog>;

    fixture = TestBed.createComponent(GoalsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load goals on init', () => {
    expect(goalsService.getGoals).toHaveBeenCalled();
  });

  it('should load categories on init', () => {
    expect(goalsService.getCategories).toHaveBeenCalled();
  });

  it('should filter goals by status', () => {
    component.goals = [
      {
        id: '1',
        title: 'Active Goal',
        description: '',
        categoryId: 'cat-1',
        targetDate: '2025-12-31',
        status: 'active',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isDeleted: false
      },
      {
        id: '2',
        title: 'Completed Goal',
        description: '',
        categoryId: 'cat-1',
        targetDate: '2025-12-31',
        status: 'completed',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isDeleted: false
      }
    ];

    component.onStatusFilterChange('active');
    expect(component.filteredGoals.length).toBe(1);
    expect(component.filteredGoals[0].status).toBe('active');
  });
});
