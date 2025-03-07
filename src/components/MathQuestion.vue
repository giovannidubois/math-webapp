<template>
  <div class="text-center math-question">
    <!-- Math Question Display -->
    <h2 class="text-h5 font-weight-bold problem">
      {{ question.num1 }} {{ question.operator }} {{ question.num2 }} =
    </h2>

    <v-expand-transition>
      <div v-if="showHint" class="hint-container mb-2">
        <v-icon icon="mdi-lightbulb-on" color="amber" class="mr-1"></v-icon>
        <span>{{ hintText }}</span>
      </div>
    </v-expand-transition>

    <!-- Answer Input Field -->
    <v-text-field
      v-model="userAnswer"
      variant="outlined"
      class="mt-3 answer-field"
      :class="{ 'shake-animation': isIncorrect }"
      hide-details
      density="compact"
      type="text"
      @keydown.enter="checkAnswer"
      readonly
      autocomplete="off"
    ></v-text-field>

    <!-- Custom Keyboard -->
    <Keyboard @input="handleInput" />

    <!-- Submit Button -->
    <v-btn class="mt-3 submit-btn" color="primary" @click="checkAnswer" :disabled="!userAnswer">
      SUBMIT
    </v-btn>

    <!-- Feedback Message -->
    <v-fade-transition>
      <p v-if="feedbackMessage" :class="feedbackClass" class="feedback-message">
        {{ feedbackMessage }}
      </p>
    </v-fade-transition>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import { useGameStore } from '../stores/gameStore';
import Keyboard from './Keyboard.vue';

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

const question = ref(generateQuestion(props.difficulty));

// Regenerate question when difficulty changes
watch(() => props.difficulty, (newDifficulty) => {
  question.value = generateQuestion(newDifficulty);
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

function generateQuestion(difficulty) {
  let num1, num2, operators;
  
  switch (difficulty) {
    case 'easy':
      num1 = Math.floor(Math.random() * 10); // 0-9
      num2 = Math.floor(Math.random() * 10); // 0-9
      operators = ['+', '-'];
      break;
    case 'medium':
      num1 = Math.floor(Math.random() * 12); // 0-11
      num2 = Math.floor(Math.random() * 12); // 0-11
      operators = ['+', '-', '×'];
      break;
    case 'hard':
      num1 = Math.floor(Math.random() * 20); // 0-19
      num2 = Math.floor(Math.random() * 12); // 0-11
      operators = ['+', '-', '×', '÷'];
      break;
    default:
      num1 = Math.floor(Math.random() * 12);
      num2 = Math.floor(Math.random() * 12);
      operators = ['+', '-', '×', '÷'];
  }
  
  const operator = operators[Math.floor(Math.random() * operators.length)];
  
  // For subtraction, ensure positive results for easy and medium
  if (operator === '-' && (difficulty === 'easy' || difficulty === 'medium')) {
    if (num1 < num2) {
      [num1, num2] = [num2, num1]; // Swap numbers
    }
  }
  
  // Ensure whole number division
  if (operator === '÷') {
    // For non-zero division
    if (num2 === 0) num2 = 1;
    
    // Make divisible for easy/medium
    if (difficulty !== 'hard') {
      num1 = num2 * Math.floor(Math.random() * 10 + 1);
    }
  }
  
  return { num1, num2, operator };
}

function checkAnswer() {
  if (!userAnswer.value) return; // Prevents crashing on empty input
  
  const correctAnswer = calculateAnswer();
  const userInput = parseInt(userAnswer.value);
  
  if (userInput === correctAnswer) {
    feedbackMessage.value = '✅ Correct!';
    feedbackClass.value = 'text-success';
    
    // Emit the correct event and pass to game store
    emit('correct');
    game.addTicket(true);
    
    userAnswer.value = '';
    question.value = generateQuestion(props.difficulty);
    showHint.value = false;
    
    // Clear feedback after a delay
    setTimeout(() => {
      feedbackMessage.value = '';
    }, 1500);
  } else {
    feedbackMessage.value = '❌ Incorrect, try again!';
    feedbackClass.value = 'text-error';
    isIncorrect.value = true;
    
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
}

.problem {
  background: white;
  padding: 10px 20px;
  border-radius: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.answer-field {
  font-size: 1.5rem;
  text-align: center;
  max-width: 200px;
  margin: auto;
}

.feedback-message {
  margin-top: 10px;
  font-weight: bold;
  font-size: 1.1rem;
}

.hint-container {
  background: rgba(255, 255, 255, 0.9);
  padding: 8px 16px;
  border-radius: 20px;
  margin-top: 10px;
  color: #FF9800;
  font-weight: medium;
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
}

.text-success {
  color: #4CAF50;
}

.text-error {
  color: #F44336;
}
</style>