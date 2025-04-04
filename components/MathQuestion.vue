<template>
  <div class="text-center math-question">
    <!-- Math Question Display -->
    <div class="problem">
      {{ question.num1 }} {{ question.operator }} {{ question.num2 }} =
    </div>

    <!-- Answer Input Field -->
    <div class="answer-box-container">
      <input
        v-model="userAnswer"
        class="answer-input"
        :class="{ 'shake-animation': isIncorrect }"
        type="text"
        @keydown.enter="checkAnswer"
        @keyup="handleKeyboardInput"
        @focus="isMobileDevice() && $event.target.blur()"
        @click="isMobileDevice() && $event.target.blur()"
        ref="answerInput"
        autocomplete="off"
        :readonly="isMobileDevice()"
      />
    </div>
    
    <!-- Feedback Messages and Hints (No extra margins) -->
    <div class="messages-container">
      <!-- Learning Hint -->
      <div v-if="showLearningHint" class="learning-hint-container">
        <v-icon icon="mdi-school" color="info" class="mr-1"></v-icon>
        <span>{{ learningHint }}</span>
      </div>

      <!-- Hint from Power-up -->
      <div v-if="showHint" class="hint-container">
        <v-icon icon="mdi-lightbulb-on" color="amber" class="mr-1"></v-icon>
        <span>{{ hintText }}</span>
      </div>
      
      <!-- Feedback Message -->
      <p v-if="feedbackMessage" :class="feedbackClass" class="feedback-message">
        {{ feedbackMessage }}
      </p>
    </div>
    
    <!-- Keyboard Container - ZERO margin-top when no messages -->
    <div class="keyboard-container" :style="{ marginTop: hasMessages ? '10px' : '0' }">
      <Keyboard @input="handleInput" />
    </div>
    
    <!-- Submit Button -->
    <v-btn class="submit-btn" color="primary" @click="checkAnswer" :disabled="!userAnswer">
      SUBMIT
    </v-btn>
  </div>
</template>

<script setup>
import { ref, watch, computed, onMounted } from 'vue';
import { useGameStore } from '../stores/gameStore';
import Keyboard from './Keyboard.vue';

// Helper function to detect mobile devices
function isMobileDevice() {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) || 
    (window.innerWidth <= 800 && window.innerHeight <= 900);
}

const props = defineProps({
  difficulty: {
    type: String,
    default: 'medium'
  },
  useHint: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['correct', 'incorrect']);

const game = useGameStore();
const userAnswer = ref('');
const feedbackMessage = ref('');
const feedbackClass = ref('');
const isIncorrect = ref(false);
const showHint = ref(false);
const showLearningHint = ref(false);
const learningHint = ref('');
const answerInput = ref(null);

const question = ref(generateQuestion());

// Computed property to check if we have any messages displayed
const hasMessages = computed(() => {
  return showHint.value || showLearningHint.value || feedbackMessage.value;
});

// Focus input field when component is mounted, but only on non-mobile devices
onMounted(() => {
  if (answerInput.value && !isMobileDevice()) {
    answerInput.value.focus();
  }
});

// Regenerate question when difficulty changes
watch(() => props.difficulty, (newDifficulty) => {
  question.value = generateQuestion();
  userAnswer.value = '';
  feedbackMessage.value = '';
});

// Show hint when the useHint prop changes
watch(() => props.useHint, (newValue) => {
  if (newValue) {
    showHint.value = true;
    // Auto-hide hint after 10 seconds
    setTimeout(() => {
      showHint.value = false;
    }, 10000);
  }
});

// Get hint text based on the current question
const hintText = computed(() => {
  switch (question.value.operator) {
    case '+':
      return `Try adding ${question.value.num1} and ${question.value.num2}`;
    case '-':
      return `Subtract ${question.value.num2} from ${question.value.num1}`;
    case '×':
      return `Multiply ${question.value.num1} times ${question.value.num2}`;
    case '÷':
      return `Divide ${question.value.num1} by ${question.value.num2}`;
    default:
      return 'Think step by step';
  }
});

// Handle physical keyboard input
function handleKeyboardInput(event) {
  // Make sure the input only accepts numbers and minus sign
  if (!/^[0-9-]$/.test(event.key) && event.key !== 'Backspace') {
    // Not a number or minus or backspace - prevent by clearing invalid chars
    userAnswer.value = userAnswer.value.replace(/[^0-9-]/g, '');
  }
  
  // Re-focus input field on non-mobile devices
  if (answerInput.value && !isMobileDevice()) {
    answerInput.value.focus();
  }
}

// Generate a question based on current mastery and game progress
function generateQuestion() {
  // Check if we should show a review question
  if (game.shouldShowReviewQuestion) {
    const reviewQuestion = game.getReviewQuestion();
    if (reviewQuestion) {
      return reviewQuestion;
    }
  }
  
  // Get available operators based on mastery levels
  const operators = game.availableOperators;
  
  // Generate new question
  let attempts = 0;
  let newQuestion;
  
  do {
    attempts++;
    let num1, num2;
    
    // Get number range based on adaptive difficulty
    const range = game.numberRange;
    
    // Pick a random operator from available ones
    const operator = operators[Math.floor(Math.random() * operators.length)];
    
    switch (operator) {
      case '+':
        num1 = Math.floor(Math.random() * (range.max + 1));
        num2 = Math.floor(Math.random() * (range.max + 1));
        break;
      case '-':
        // For subtraction, ensure positive results for easier difficulties
        if (game.adaptiveDifficulty !== 'hard') {
          num1 = Math.floor(Math.random() * (range.max + 1));
          num2 = Math.floor(Math.random() * (num1 + 1)); // Ensure num2 <= num1
        } else {
          // For hard difficulty, allow negative results
          num1 = Math.floor(Math.random() * (range.max + 1));
          num2 = Math.floor(Math.random() * (range.max + 1));
        }
        break;
      case '×':
        // For multiplication, use smaller numbers for easier calculations
        const multiplierRange = game.adaptiveDifficulty === 'hard' ? range.max : Math.min(range.max, 12);
        num1 = Math.floor(Math.random() * (multiplierRange + 1));
        num2 = Math.floor(Math.random() * (multiplierRange + 1));
        break;
      case '÷':
        // Ensure division results in whole numbers
        num2 = Math.floor(Math.random() * (range.max - 1)) + 1; // Divisor between 1 and max-1
        const multiplier = Math.floor(Math.random() * 10) + 1; // Random multiplier
        num1 = num2 * multiplier; // Ensures division results in a whole number
        break;
      default:
        num1 = Math.floor(Math.random() * (range.max + 1));
        num2 = Math.floor(Math.random() * (range.max + 1));
    }
    
    newQuestion = { num1, num2, operator };
    
    // Check if question is in history to avoid repeats
    // But don't loop forever - after 10 attempts, just use the question
    if (attempts >= 10) {
      break;
    }
  } while (game.isQuestionInHistory(newQuestion));
  
  return newQuestion;
}

function checkAnswer() {
  if (!userAnswer.value) return; // Prevents crashing on empty input
  
  // Blur the input to hide mobile keyboard
  if (answerInput.value) {
    answerInput.value.blur();
  }
  
  const correctAnswer = calculateAnswer();
  const userInput = parseInt(userAnswer.value);
  
  if (userInput === correctAnswer) {
    // Hide any learning hint if shown
    showLearningHint.value = false;
    
    feedbackMessage.value = '✅ Correct!';
    feedbackClass.value = 'text-success';
    
    // Track question and update mastery
    game.trackQuestion(question.value, true);
    
    // Emit the correct event and pass to game store
    emit('correct');
    game.addTicket(true);
    
    userAnswer.value = '';
    question.value = generateQuestion();
    showHint.value = false;
    
    // Clear feedback after a delay
    setTimeout(() => {
      feedbackMessage.value = '';
    }, 1500);
    
    // Don't auto-focus on mobile devices
    if (answerInput.value && !isMobileDevice()) {
      answerInput.value.focus();
    }
  } else {
    feedbackMessage.value = '❌ Incorrect, try again!';
    feedbackClass.value = 'text-error';
    isIncorrect.value = true;
    
    // Show learning hint after incorrect answer
    learningHint.value = game.getLearningHint(question.value);
    showLearningHint.value = true;
    
    // Track question and update mastery
    game.trackQuestion(question.value, false);
    
    // Notify of incorrect answer
    emit('incorrect');
    game.addTicket(false);
    
    // Clear shake animation after it completes
    setTimeout(() => {
      isIncorrect.value = false;
    }, 500);
    
    // Clear feedback after a delay
    setTimeout(() => {
      feedbackMessage.value = '';
    }, 1500);
  }
}

function handleInput(value) {
  if (value === 'delete') {
    userAnswer.value = userAnswer.value.slice(0, -1);
  } else if (value === '-') {
    // Handle negative sign - only add at the beginning
    if (userAnswer.value === '' || (userAnswer.value.length === 1 && userAnswer.value !== '-')) {
      userAnswer.value = '-';
    }
  } else {
    userAnswer.value += value;
  }
  
  // Only focus the input on non-mobile devices
  if (answerInput.value && !isMobileDevice()) {
    answerInput.value.focus();
  } else if (answerInput.value) {
    // For mobile, keep the focus off to prevent keyboard from showing
    answerInput.value.blur();
  }
}

function calculateAnswer() {
  switch (question.value.operator) {
    case '+': return question.value.num1 + question.value.num2;
    case '-': return question.value.num1 - question.value.num2;
    case '×': return question.value.num1 * question.value.num2;
    case '÷': return Math.floor(question.value.num1 / question.value.num2);
    default: return 0;
  }
}
</script>

<style scoped>
.math-question {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  height: 100%;
}

.problem {
  background: rgba(0, 0, 0, 0.7);
  padding: 12px 28px;
  border-radius: 40px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  font-size: 1.6rem;
  font-weight: bold;
  margin-bottom: 8px;
  display: inline-block;
  color: white;
  backdrop-filter: blur(3px);
}

.answer-box-container {
  display: flex;
  justify-content: center;
  width: 100%;
  margin-bottom: 5px;
}

.answer-input {
  width: 40%;
  height: 40px;
  border-radius: 12px;
  border: none;
  text-align: center;
  font-size: 1.5rem;
  font-weight: bold;
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  color: #333;
  margin: 0;
  padding: 0 8px;
}

/* Container for messages and hints - minimal height when empty */
.messages-container {
  width: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.feedback-message {
  margin: 5px 0;
  font-weight: bold;
  font-size: 1.1rem;
}

.hint-container {
  background: rgba(255, 255, 255, 0.9);
  padding: 8px 16px;
  border-radius: 20px;
  margin: 5px 0;
  color: #FF9800;
  font-weight: medium;
  max-width: 90%;
}

.learning-hint-container {
  background: rgba(0, 0, 0, 0.7);
  padding: 8px 14px;
  border-radius: 20px;
  margin: 5px 0;
  color: white;
  font-weight: medium;
  max-width: 90%;
  backdrop-filter: blur(3px);
  font-size: 0.95rem;
}

/* No fixed margin to allow dynamic spacing */
.keyboard-container {
  width: 100%;
  transition: margin-top 0.2s ease;
}

.shake-animation {
  animation: shake 0.5s;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
  20%, 40%, 60%, 80% { transform: translateX(5px); }
}

.submit-btn {
  min-width: 120px;
  margin: 10px auto;
  padding: 6px 24px !important;
  font-size: 1rem !important;
  letter-spacing: 1px;
  border-radius: 30px !important;
  background-color: rgba(255, 255, 255, 1) !important;
  color: #333 !important;
  width: 50%;
  max-width: 180px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.text-success {
  color: #4CAF50;
}

.text-error {
  color: #F44336;
}

/* Mobile-specific adjustments */
@media (max-height: 700px) {
  .problem {
    padding: 10px 20px;
    font-size: 1.4rem;
    margin-bottom: 5px;
  }
  
  .answer-input {
    height: 36px;
    font-size: 1.3rem;
  }
  
  .learning-hint-container, .hint-container {
    padding: 6px 12px;
    font-size: 0.9rem;
  }
  
  .submit-btn {
    padding: 4px 16px !important;
    margin: 5px auto;
    font-size: 0.9rem !important;
  }
  
  .feedback-message {
    font-size: 1rem;
  }
}
</style>