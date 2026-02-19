import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ProgressComponent } from './progress.component';
import { ProgressService } from '../../core/services/progress.service';
import { GoalsService } from '../../core/services/goals.service';
import { MatDialog } from '@angular/material/dialog';
import { of } from 'rxjs';

describe('ProgressComponent', () => {
  let component: ProgressComponent;
  let fixture: ComponentFixture<ProgressComponent>;
  let progressService: jasmine.SpyObj<ProgressService>;
  let goalsService: jasmine.SpyObj<GoalsService>;
  let matDialog: jasmine.SpyObj<MatDialog>;

  beforeEach(async () => {
    const progressServiceSpy = jasmine.createSpyObj('ProgressService', [
      'getProgress',
      'loadProgress',
      'deleteEntry'
    ]);
    const goalsServiceSpy = jasmine.createSpyObj('GoalsService', ['getGoals']);
    const dialogSpy = jasmine.createSpyObj('MatDialog', ['open']);

    progressServiceSpy.getProgress.and.returnValue(of([]));
    goalsServiceSpy.getGoals.and.returnValue(of([]));

    await TestBed.configureTestingModule({
      imports: [ProgressComponent],
      providers: [
        { provide: ProgressService, useValue: progressServiceSpy },
        { provide: GoalsService, useValue: goalsServiceSpy },
        { provide: MatDialog, useValue: dialogSpy }
      ]
    }).compileComponents();

    progressService = TestBed.inject(ProgressService) as jasmine.SpyObj<ProgressService>;
    goalsService = TestBed.inject(GoalsService) as jasmine.SpyObj<GoalsService>;
    matDialog = TestBed.inject(MatDialog) as jasmine.SpyObj<MatDialog>;

    fixture = TestBed.createComponent(ProgressComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load progress entries on init', () => {
    expect(progressService.getProgress).toHaveBeenCalled();
  });

  it('should load goals on init', () => {
    expect(goalsService.getGoals).toHaveBeenCalled();
  });

  it('should group entries by date', () => {
    const today = new Date().toISOString().split('T')[0];
    component.progressEntries = [
      {
        id: '1',
        goalId: 'goal-1',
        value: 10,
        date: today,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isDeleted: false
      },
      {
        id: '2',
        goalId: 'goal-2',
        value: 20,
        date: today,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isDeleted: false
      }
    ];

    const grouped = component.groupByDate();
    expect(grouped.size).toBeGreaterThan(0);
  });
});
