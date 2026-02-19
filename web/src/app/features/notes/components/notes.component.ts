import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatMenuModule } from '@angular/material/menu';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { NotesService } from '../services/notes.service';
import { NoteWithTags, Tag, NoteFilterOptions } from '../../../shared/models';
import { NoteEditorComponent } from './note-editor.component';

/**
 * Notes Component
 * Displays notes in grid or list view with filtering and search
 */
@Component({
  selector: 'app-notes',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatCardModule,
    MatIconModule,
    MatChipsModule,
    MatMenuModule,
    MatInputModule,
    MatFormFieldModule,
    NoteEditorComponent,
  ],
  templateUrl: './notes.component.html',
  styleUrl: './notes.component.scss',
})
export class NotesComponent implements OnInit {
  notes: NoteWithTags[] = [];
  filteredNotes: NoteWithTags[] = [];
  allTags: Tag[] = [];
  selectedTags: string[] = [];
  searchTerm: string = '';
  viewMode: 'grid' | 'list' = 'grid';
  isEditorVisible = false;
  selectedNote: NoteWithTags | null = null;

  constructor(private notesService: NotesService) {}

  ngOnInit(): void {
    this.loadData();

    // Subscribe to changes
    this.notesService.notes$.subscribe((notes) => {
      this.notes = notes;
      this.applyFilters();
    });

    this.notesService.tags$.subscribe((tags) => {
      this.allTags = tags;
    });
  }

  /**
   * Load notes and tags
   */
  async loadData(): Promise<void> {
    await this.notesService.loadNotes();
    await this.notesService.loadTags();
  }

  /**
   * Toggle view mode
   */
  toggleView(mode: 'grid' | 'list'): void {
    this.viewMode = mode;
  }

  /**
   * Toggle tag filter
   */
  toggleTag(tagId: string): void {
    const index = this.selectedTags.indexOf(tagId);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    } else {
      this.selectedTags.push(tagId);
    }
    this.applyFilters();
  }

  /**
   * Apply filters and search
   */
  async applyFilters(): Promise<void> {
    const options: NoteFilterOptions = {
      searchTerm: this.searchTerm || undefined,
      tagIds: this.selectedTags.length > 0 ? this.selectedTags : undefined,
      excludeArchived: true,
      excludeDeleted: true,
    };

    this.filteredNotes = await this.notesService.loadNotes(options);
  }

  /**
   * Handle search input
   */
  onSearchChange(): void {
    this.applyFilters();
  }

  /**
   * Clear search and filters
   */
  clearFilters(): void {
    this.searchTerm = '';
    this.selectedTags = [];
    this.applyFilters();
  }

  /**
   * Open editor for new note
   */
  newNote(): void {
    this.selectedNote = null;
    this.isEditorVisible = true;
  }

  /**
   * Open editor to edit note
   */
  editNote(note: NoteWithTags): void {
    this.selectedNote = note;
    this.isEditorVisible = true;
  }

  /**
   * Close editor
   */
  closeEditor(): void {
    this.isEditorVisible = false;
    this.selectedNote = null;
  }

  /**
   * Handle editor save
   */
  async onEditorSave(data: any): Promise<void> {
    try {
      if (this.selectedNote) {
        await this.notesService.updateNote(this.selectedNote.id, {
          title: data.title,
          richContent: data.richContent,
          tags: data.tags,
        });
      } else {
        await this.notesService.addNote({
          title: data.title,
          richContent: data.richContent,
          tags: data.tags,
        });
      }
      this.closeEditor();
      await this.loadData();
    } catch (error) {
      console.error('Error saving note:', error);
    }
  }

  /**
   * Archive note
   */
  async archiveNote(note: NoteWithTags): Promise<void> {
    try {
      await this.notesService.archiveNote(note.id);
    } catch (error) {
      console.error('Error archiving note:', error);
    }
  }

  /**
   * Delete note
   */
  async deleteNote(note: NoteWithTags): Promise<void> {
    if (confirm('Are you sure you want to delete this note?')) {
      try {
        await this.notesService.deleteNote(note.id);
      } catch (error) {
        console.error('Error deleting note:', error);
      }
    }
  }

  /**
   * Get note preview
   */
  getPreview(note: NoteWithTags): string {
    return this.notesService.getPreview(note);
  }

  /**
   * Check if tag is selected
   */
  isTagSelected(tagId: string): boolean {
    return this.selectedTags.includes(tagId);
  }

  /**
   * Get tags for note
   */
  getNoteTags(note: NoteWithTags): Tag[] {
    return note.tags || [];
  }
}
