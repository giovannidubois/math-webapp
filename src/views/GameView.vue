<template>
    <v-container class="fill-height d-flex flex-column align-center justify-center">
      <!-- Game UI -->
      <div class="game-screen">
        <!-- Landmark Icon -->
        <img
          :src="landmarkImage"
          alt="Landmark"
          class="landmark-icon"
          v-if="landmarkImage"
        />
  
        <p class="landmark-name">
          {{ game.countries[game.currentCountryIndex].landmarks[game.currentLandmarkIndex] }}
        </p>
  
        <!-- Math Problem Box -->
        <div class="math-box">
          <span class="math-num">{{ question.num1 }}</span>
          <span class="math-operator">{{ question.operator }}</span>
          <span class="math-num">{{ question.num2 }}</span>
        </div>
  
        <!-- Question Prompt -->
        <p class="question-text">What is the correct answer?</p>
  
        <!-- Answer Input -->
        <v-text-field
          v-model="userAnswer"
          variant="outlined"
          class="answer-field"
          hide-details
          density="compact"
          type="text"
          @keydown.enter="checkAnswer"
        ></v-text-field>
  
        <!-- Keyboard -->
        <Keyboard @input="handleInput" />
  
        <!-- Submit Button -->
        <v-btn class="submit-btn" color="primary" @click="checkAnswer">
          Submit
        </v-btn>
      </div>
    </v-container>
  </template>
  
  <script setup>
  import { ref, computed } from 'vue';
  import { useGameStore } from '../stores/gameStore';
  import Keyboard from '../components/Keyboard.vue';
  
  const game = useGameStore();
  const userAnswer = ref('');
  
  const question = ref(generateQuestion());
  
  function generateQuestion() {
    let num1 = Math.floor(Math.random() * 10);
    let num2 = Math.floor(Math.random() * 10);
    const operators = ['+', '-', '×', '÷'];
    const operator = operators[Math.floor(Math.random() * operators.length)];
  
    if (operator === '÷') {
      num1 = num1 * num2 || 1;
    }
  
    return { num1, num2, operator };
  }
  
  // Ensure correct landmark image
  const landmarkImage = computed(() => {
    const country = game.countries[game.currentCountryIndex];
    const landmark = country.landmarks[game.currentLandmarkIndex];
  
    return `/landmarks/${landmark.toLowerCase().replace(/\s+/g, '-')}.png`; // Ensure images match landmark names
  });
  
  function checkAnswer() {
    const correctAnswer = calculateAnswer();
    if (parseInt(userAnswer.value) === correctAnswer) {
      game.addTicket();
    }
    userAnswer.value = '';
    question.value = generateQuestion();
  }
  
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
      case '÷': return Math.floor(question.value.num1 / question.value.num2);
    }
  }
  </script>
  
  <style scoped>
  /* Background */
  .game-screen {
    background: linear-gradient(to bottom, #1abc9c, #16a085);
    width: 350px;
    height: 600px;
    border-radius: 20px;
    text-align: center;
    padding: 20px;
    box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.2);
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  /* Landmark Image */
  .landmark-icon {
    width: 80px;
    height: auto;
    margin-bottom: 10px;
  }
  
  /* Landmark Name */
  .landmark-name {
    color: white;
    font-size: 1rem;
    font-weight: bold;
  }
  
  /* Circular Math Box */
  .math-box {
    background: white;
    width: 100px;
    height: 100px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    font-weight: bold;
    margin-bottom: 15px;
  }
  
  .math-num {
    font-size: 1.5rem;
    font-weight: bold;
  }
  
  .math-operator {
    font-size: 2rem;
    margin: 0 5px;
  }
  
  /* Question Text */
  .question-text {
    font-size: 1.2rem;
    color: white;
    margin-bottom: 10px;
  }
  
  /* Answer Field */
  .answer-field {
    width: 200px;
    text-align: center;
    font-size: 1.5rem;
    margin-bottom: 10px;
  }
  
  /* Submit Button */
  .submit-btn {
    background: #0e6251;
    color: white;
    font-size: 1.2rem;
    width: 150px;
    border-radius: 25px;
    margin-top: 10px;
  }
  </style>
  