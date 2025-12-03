/**
 * AI Service Type Definitions
 */

export interface OptimizeGoalRequest {
  goalTitle: string;
  category: string;
  motivation?: string;
  targetDate?: string;
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

export interface GenerateWeeklyReportRequest {
  userId: string;
  weekStart: string;
  weekEnd: string;
  goals: Goal[];
  checkIns: CheckIn[];
}

export interface GenerateWeeklyReportResponse {
  content: string;
}

export interface GenerateMonthlyReportRequest {
  userId: string;
  year: number;
  month: number;
  goals: Goal[];
  checkIns: CheckIn[];
}

export interface GenerateMonthlyReportResponse {
  content: string;
}

export interface SuggestSubGoalsRequest {
  goalTitle: string;
  category: string;
  description?: string;
}

export interface SuggestSubGoalsResponse {
  subGoals: {
    title: string;
  }[];
}

// Firestore data models (simplified for AI functions)
export interface Goal {
  id: string;
  userId: string;
  title: string;
  category: string;
  createdAt: string;
  targetDate?: string;
  description?: string;
  motivation?: string;
  progress: number;
  isArchived: boolean;
  isCompleted?: boolean;
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

// Validation helpers
export function validateGoal(goal: Goal): void {
  if (!goal.title || goal.title.trim().length === 0) {
    throw new Error('Goal title is required');
  }
  if (goal.progress < 0 || goal.progress > 100) {
    throw new Error('Goal progress must be between 0 and 100');
  }
  if (!goal.id || goal.id.trim().length === 0) {
    throw new Error('Goal id is required');
  }
  if (!goal.userId || goal.userId.trim().length === 0) {
    throw new Error('Goal userId is required');
  }
}

export function validateCheckIn(checkIn: CheckIn): void {
  if (checkIn.score < 1 || checkIn.score > 10) {
    throw new Error('Check-in score must be between 1 and 10');
  }
  if (checkIn.progressDelta < -100 || checkIn.progressDelta > 100) {
    throw new Error('Check-in progressDelta must be between -100 and 100');
  }
  if (!checkIn.id || checkIn.id.trim().length === 0) {
    throw new Error('Check-in id is required');
  }
  if (!checkIn.goalId || checkIn.goalId.trim().length === 0) {
    throw new Error('Check-in goalId is required');
  }
  if (!checkIn.userId || checkIn.userId.trim().length === 0) {
    throw new Error('Check-in userId is required');
  }
}

