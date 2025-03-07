<template>
  <div class="text-center math-question">
    <!-- Math Question Display -->
    <div class="problem">
      {{ question.num1 }} {{ question.operator }} {{ question.num2 }} =
    </div>

    <v-expand-transition>
      <div v-if="showHint" class="hint-container mb-2">
        <v-icon icon="mdi-lightbulb-on" color="amber" class="mr-1"></v-icon>
        <span>{{ hintText }}</span>
      </div>
    </v-expand-transition>

    <!-- Answer Input Field -->
    <div class="answer-box-container">
      <input
        v-model="userAnswer"
        class="answer-input"
        :class="{ 'shake-animation': isIncorrect }"
        type="text"
        @keydown.enter="checkAnswer"
        @keyup="handleKeyboardInput"
        ref="answerInput"
        autocomplete="off"
      />
    </div>
    <!-- Feedback Message -->
    <v-fade-transition>
      <p v-if="feedbackMessage" :class="feedbackClass" class="feedback-message">
        {{ feedbackMessage }}
      </p>
    </v-fade-transition>
    
    <!-- Custom Keyboard -->
    <Keyboard @input="handleInput" />

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
const answerInput = ref(null);

const question = ref(generateQuestion(props.difficulty));

// Focus input field when component is mounted
onMounted(() => {
  if (answerInput.value) {
    answerInput.value.focus();
  }
});

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

// Handle physical keyboard input
function handleKeyboardInput(event) {
  // Make sure the input only accepts numbers and minus sign
  if (!/^[0-9-]$/.test(event.key) && event.key !== 'Backspace') {
    // Not a number or minus or backspace - prevent by clearing invalid chars
    userAnswer.value = userAnswer.value.replace(/[^0-9-]/g, '');
  }
  
  // Re-focus input field
  if (answerInput.value) {
    answerInput.value.focus();
  }
}

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
    // Ensure non-zero divisor
    if (num2 === 0) {
      num2 = Math.floor(Math.random() * 12) + 1; // Random number 1-9
    }
    
    // Create a dividend that is divisible by the divisor
    // This guarantees an integer result
    const multiplier = Math.floor(Math.random() * 10) + 1; // Random number 1-10
    num1 = num2 * multiplier;
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
    
    // Focus input again
    if (answerInput.value) {
      answerInput.value.focus();
    }
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
  
  // Focus the input element to allow for keyboard input right after clicking buttons
  if (answerInput.value) {
    answerInput.value.focus();
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
}

.problem {
  background: rgba(0, 0, 0, 0.7);
  padding: 14px 30px;
  border-radius: 40px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  font-size: 1.6rem;
  font-weight: bold;
  margin-bottom: 20px;
  display: inline-block;
  color: white;
  backdrop-filter: blur(3px);
}

.answer-box-container {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
  width: 100%;
}

.answer-input {
  width: 40%;
  height: 45px;
  border-radius: 12px;
  border: none;
  text-align: center;
  font-size: 1.5rem;
  font-weight: bold;
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  color: #333;
  margin: 0 16px;
  padding: 0 8px;
}

.feedback-message {
  margin-top: 8px;
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
  margin: 8px auto;
  padding: 8px 32px !important;
  font-size: 1.1rem !important;
  letter-spacing: 1px;
  border-radius: 30px !important;
  background-color: rgba(255, 255, 255, 1) !important;
  color: #333 !important;
  width: 50%;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.text-success {
  color: #4CAF50;
}

.text-error {
  color: #F44336;
}
</style>