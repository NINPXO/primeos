import { Component, Inject, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatDialogModule, MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { NgChartsModule } from 'ng2-charts';
import { ChartOptions } from 'chart.js';
import { ProgressService } from '../../../core/services/progress.service';
import { GoalsService } from '../../../core/services/goals.service';
import { ProgressEntry, Goal } from '../../../core/models';

@Component({
  selector: 'app-progress-chart',
  standalone: true,
  imports: [CommonModule, MatDialogModule, MatButtonModule, NgChartsModule],
  templateUrl: './progress-chart.component.html',
  styleUrls: ['./progress-chart.component.scss']
})
export class ProgressChartComponent implements OnInit {
  private progressService = inject(ProgressService);
  private goalsService = inject(GoalsService);
  private dialogRef = inject(MatDialogRef<ProgressChartComponent>);
  @Inject(MAT_DIALOG_DATA) goalId!: string;

  goal: Goal | null = null;
  progressEntries: ProgressEntry[] = [];

  chartOptions: ChartOptions<'line'> = {
    responsive: true,
    maintainAspectRatio: true,
    plugins: {
      legend: {
        display: true,
        position: 'top'
      },
      title: {
        display: false
      }
    },
    scales: {
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: 'Value'
        }
      },
      x: {
        title: {
          display: true,
          text: 'Date'
        }
      }
    }
  };

  chartLabels: string[] = [];
  chartData: any = {
    labels: [],
    datasets: [
      {
        label: 'Progress',
        data: [],
        borderColor: '#2196F3',
        backgroundColor: 'rgba(33, 150, 243, 0.1)',
        borderWidth: 2,
        fill: true,
        tension: 0.4,
        pointRadius: 5,
        pointBackgroundColor: '#2196F3',
        pointBorderColor: '#fff',
        pointBorderWidth: 2
      }
    ]
  };

  ngOnInit(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    // Load goal info
    this.goalsService.getGoals().subscribe(goals => {
      this.goal = goals.find(g => g.id === this.goalId) || null;
    });

    // Load progress entries
    this.progressEntries = await this.progressService.getProgressByGoal(this.goalId);

    // Sort by date ascending for chart
    this.progressEntries.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());

    // Prepare chart data
    this.updateChartData();
  }

  private updateChartData(): void {
    if (this.progressEntries.length === 0) {
      this.chartLabels = [];
      this.chartData.labels = [];
      this.chartData.datasets[0].data = [];
      return;
    }

    const labels = this.progressEntries.map(e =>
      new Date(e.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    );

    const data = this.progressEntries.map(e => e.value);

    this.chartLabels = labels;
    this.chartData.labels = labels;
    this.chartData.datasets[0].data = data;

    // Update label with goal title if available
    if (this.goal) {
      this.chartData.datasets[0].label = this.goal.title;
    }
  }

  getStatistics(): { avg: number; min: number; max: number; total: number } {
    if (this.progressEntries.length === 0) {
      return { avg: 0, min: 0, max: 0, total: 0 };
    }

    const values = this.progressEntries.map(e => e.value);
    const sum = values.reduce((a, b) => a + b, 0);
    const avg = sum / values.length;
    const min = Math.min(...values);
    const max = Math.max(...values);

    return {
      avg: Math.round(avg * 100) / 100,
      min,
      max,
      total: Math.round(sum * 100) / 100
    };
  }

  onClose(): void {
    this.dialogRef.close();
  }
}
