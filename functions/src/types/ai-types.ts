/**
 * AI Service Type Definitions
 */

export interface OptimizeGoalRequest {
  goalTitle: string;
  category: string;
  motivation?: string;
}

export interface SubGoal {
  id: string;
  title: string;
  isCompleted: boolean;
  dueDate?: string;
}

export interface OptimizeGoalResponse {
  optimizedTitle: string;
  subGoals: SubGoal[];
  explanation: string;
}

export interface GenerateSuggestionsRequest {
  userId: string;
  goals: Goal[];
  checkIns: CheckIn[];
}

export interface GenerateSuggestionsResponse {
  suggestions: string;
}

export interface GenerateYearlyReportRequest {
  userId: string;
  year: number;
  goals: Goal[];
  checkIns: CheckIn[];
}

export interface GenerateYearlyReportResponse {
  content: string;
}

// Firestore data models (simplified for AI functions)
export interface Goal {
  id: string;
  userId: string;
  title: string;
  category: string;
  createdAt: string;
  targetDate?: string;
  motivation?: string;
  progress: number;
  isArchived: boolean;
}

export interface CheckIn {
  id: string;
  goalId: string;
  userId: string;
  createdAt: string;
  score: number;
  progressDelta: number;
  note?: string;
}

