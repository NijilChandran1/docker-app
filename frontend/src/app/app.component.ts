import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';

interface DataItem {
  id: number;
  name: string;
  description: string;
  created_at: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <h1 class="header">Angular Frontend - Docker Compose Demo</h1>
      
      <div class="data-section">
        <button (click)="loadData()" [disabled]="loading">
          {{ loading ? 'Loading...' : 'Load Data from Backend' }}
        </button>
        
        <div *ngIf="error" class="error">
          {{ error }}
        </div>
        
        <div *ngIf="loading" class="loading">
          Fetching data from backend...
        </div>
        
        <div *ngIf="data.length > 0">
          <h3>Data from PostgreSQL Database:</h3>
          <div *ngFor="let item of data" class="data-item">
            <strong>ID:</strong> {{ item.id }}<br>
            <strong>Name:</strong> {{ item.name }}<br>
            <strong>Description:</strong> {{ item.description }}<br>
            <strong>Created:</strong> {{ item.created_at | date:'medium' }}
          </div>
        </div>
        
        <div *ngIf="!loading && data.length === 0 && !error">
          <p>No data loaded yet. Click the button above to fetch data.</p>
        </div>
      </div>
    </div>
  `
})
export class AppComponent implements OnInit {
  title = 'angular-frontend';
  data: DataItem[] = [];
  loading = false;
  error: string | null = null;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    // Optionally load data on component initialization
  }

  loadData() {
    this.loading = true;
    this.error = null;
    
    // Call the FastAPI backend
    this.http.get<DataItem[]>('http://localhost:8000/api/data')
      .subscribe({
        next: (response) => {
          this.data = response;
          this.loading = false;
        },
        error: (err) => {
          this.error = 'Failed to load data from backend: ' + err.message;
          this.loading = false;
          console.error('Error loading data:', err);
        }
      });
  }
}

