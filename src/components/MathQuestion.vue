<template>
  <div class="text-center">
    <!-- Math Question Display -->
    <h2 class="text-h5 font-weight-bold">
      {{ question.num1 }} {{ question.operator }} {{ question.num2 }} =
    </h2>

    <!-- Answer Input Field (Editable) -->
    <v-text-field
      v-model="userAnswer"
      variant="outlined"
      class="mt-3 answer-field"
      hide-details
      density="compact"
      type="text"
      @keydown.enter="checkAnswer"
    ></v-text-field>

    <!-- Custom Keyboard (Above Submit Button) -->
    <Keyboard @input="handleInput" />

    <!-- Submit Button (Now Below Keyboard) -->
    <v-btn class="mt-3" color="primary" @click="checkAnswer">
      SUBMIT
    </v-btn>

    <!-- Feedback Message -->
    <p v-if="feedbackMessage" :class="feedbackClass">
      {{ feedbackMessage }}
    </p>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useGameStore } from '../stores/gameStore';
import Keyboard from '../components/Keyboard.vue'; // Relative import


const game = useGameStore();
const userAnswer = ref('');
const feedbackMessage = ref('');
const feedbackClass = ref('');

const question = ref(generateQuestion());

function generateQuestion() {
  let num1 = Math.floor(Math.random() * 12);
  let num2 = Math.floor(Math.random() * 12);
  const operators = ['+', '-', '×', '÷'];
  const operator = operators[Math.floor(Math.random() * operators.length)];

  // Ensure whole number division
  if (operator === '÷') {
    num1 = num1 * num2 || 1; // Prevent division by zero
  }

  return { num1, num2, operator };
}

function checkAnswer() {
  if (!userAnswer.value) return; // Prevents crashing on empty input

  const correctAnswer = calculateAnswer();
  if (parseInt(userAnswer.value) === correctAnswer) {
    feedbackMessage.value = '✅ Correct!';
    feedbackClass.value = 'text-success font-weight-bold';
    game.addTicket();
  } else {
    feedbackMessage.value = '❌ Incorrect, try again!';
    feedbackClass.value = 'text-error font-weight-bold';
  }
  userAnswer.value = ''; // Clear input
  question.value = generateQuestion(); // Load new question
}

// Handles number input (either from virtual or physical keyboard)
function handleInput(value) {
  if (value === 'delete') {
    userAnswer.value = userAnswer.value.slice(0, -1);
  } else {
    userAnswer.value += value;
  }
}

function calculateAnswer() {
  switch (question.value.operator) {
    case '+': return question.value.num1 + question.value.num2;
    case '-': return question.value.num1 - question.value.num2;
    case '×': return question.value.num1 * question.value.num2;
    case '÷': return Math.floor(question.value.num1 / question.value.num2); // Ensure integer division
  }
}
</script>

<style scoped>
.answer-field {
  font-size: 1.5rem;
  text-align: center;
  max-width: 200px;
  margin: auto;
}
</style>
