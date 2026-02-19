import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatAutocompleteModule } from '@angular/material/autocomplete';
import { QuillModule } from 'ngx-quill';
import { NoteWithTags, Tag, QuillDelta } from '../../../shared/models';

interface EditorForm {
  title: string;
  richContent: QuillDelta;
  tags: string[];
}

/**
 * Note Editor Component
 * Rich text editor for creating/editing notes with tag support
 */
@Component({
  selector: 'app-note-editor',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatChipsModule,
    MatIconModule,
    MatAutocompleteModule,
    QuillModule,
  ],
  templateUrl: './note-editor.component.html',
  styleUrl: './note-editor.component.scss',
})
export class NoteEditorComponent implements OnInit {
  @Input() note: NoteWithTags | null = null;
  @Input() allTags: Tag[] = [];

  @Output() save = new EventEmitter<EditorForm>();
  @Output() cancel = new EventEmitter<void>();

  form: EditorForm = {
    title: '',
    richContent: { ops: [{ insert: '\n' }] },
    tags: [],
  };

  selectedTags: Tag[] = [];
  tagInput: string = '';
  isEdit = false;
  errors: string[] = [];

  // Quill modules configuration
  editorModules = {
    toolbar: [
      ['bold', 'italic', 'underline', 'strike'],
      ['blockquote', 'code-block'],
      [{ header: 1 }, { header: 2 }],
      [{ list: 'ordered' }, { list: 'bullet' }],
      ['link', 'image'],
    ],
  };

  ngOnInit(): void {
    if (this.note) {
      this.isEdit = true;
      this.form.title = this.note.title;
      this.form.richContent = this.note.richContent;
      this.selectedTags = this.note.tags || [];
      this.form.tags = this.selectedTags.map((t) => t.id);
    }
  }

  /**
   * Validate form
   */
  validate(): boolean {
    this.errors = [];

    if (!this.form.title.trim()) {
      this.errors.push('Title is required');
    }

    if (!this.form.richContent || !this.hasContent()) {
      this.errors.push('Content is required');
    }

    return this.errors.length === 0;
  }

  /**
   * Check if rich content has any text
   */
  private hasContent(): boolean {
    if (!this.form.richContent || !this.form.richContent.ops) {
      return false;
    }

    return this.form.richContent.ops.some(
      (op: any) =>
        typeof op.insert === 'string' && op.insert.trim().length > 0
    );
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
   * Handle editor content change
   */
  onEditorChange(event: any): void {
    if (event && event.delta) {
      this.form.richContent = event.delta;
    }
  }

  /**
   * Get available tags for autocomplete
   */
  getAvailableTags(): Tag[] {
    if (!this.tagInput.trim()) {
      return this.allTags.filter(
        (t) => !this.selectedTags.some((st) => st.id === t.id)
      );
    }

    const term = this.tagInput.toLowerCase();
    return this.allTags.filter(
      (t) =>
        t.name.toLowerCase().includes(term) &&
        !this.selectedTags.some((st) => st.id === t.id)
    );
  }

  /**
   * Add tag to note
   */
  addTag(event: any): void {
    const value = event.target ? event.target.value : event;

    if (!value || !value.trim()) {
      return;
    }

    // Check if tag already exists
    const existing = this.allTags.find(
      (t) => t.name.toLowerCase() === value.toLowerCase()
    );

    if (existing) {
      this.selectTag(existing);
    } else {
      // Create new tag (will be created on save)
      const newTag: Tag = {
        id: `temp-${Date.now()}`,
        name: value.trim(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      this.selectedTags.push(newTag);
      this.form.tags.push(value.trim());
    }

    this.tagInput = '';

    if (event.target) {
      event.target.value = '';
    }
  }

  /**
   * Select tag from autocomplete
   */
  selectTag(tag: Tag): void {
    if (!this.selectedTags.some((t) => t.id === tag.id)) {
      this.selectedTags.push(tag);
      this.form.tags.push(tag.id);
    }
    this.tagInput = '';
  }

  /**
   * Remove tag from note
   */
  removeTag(tag: Tag): void {
    const index = this.selectedTags.findIndex((t) => t.id === tag.id);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
      this.form.tags.splice(index, 1);
    }
  }

  /**
   * Get tag name for display
   */
  getTagDisplayName(tag: Tag): string {
    return tag.name;
  }
}
