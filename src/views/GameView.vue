<template>
  <v-container class="fill-height d-flex flex-column justify-center">
    <v-row justify="center">
      <v-col cols="12" md="8" lg="6">
        <!-- Game UI -->
        <div class="game-screen">
          <!-- Progress Tracker -->
          <ProgressTracker />
          <!-- Difficulty Selector -->
          <DifficultySelector @difficulty-changed="difficultyChanged" />
          <!-- Landmark Info -->
          <div class="landmark-info-container">
            <div class="landmark-image-container">
              <img
                :src="landmarkImagePlaceholder"
                alt="Landmark"
                class="landmark-image"
              />
            </div>
            <h3 class="landmark-name">
              {{ game.countries[game.currentCountryIndex].landmarks[game.currentLandmarkIndex] }}
            </h3>
            <p class="country-name">
              <v-icon icon="mdi-earth" size="small" class="mr-1"></v-icon>
              {{ game.countries[game.currentCountryIndex].name }}
            </p>
          </div>

          <!-- ONLY ONE PowerUps Component Here
          <PowerUps @use-hint="activateHint" @use-time-freeze="activateTimeFreeze" /> -->

          <!-- Math Question Component WITHOUT PowerUps -->
          <div class="text-center math-question">
            <!-- Math Question Display -->
            <h2 class="text-h5 font-weight-bold problem">
              {{ question.num1 }} {{ question.operator }} {{ question.num2 }} =
            </h2>

            <!-- Answer Input Field -->
            <v-text-field
              v-model="userAnswer"
              variant="outlined"
              class="mt-3 answer-field"
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
          </div>
          
          <!-- Debug button to reset welcome screen (you can remove this later) -->
          <v-btn small text color="white" class="mt-4" @click="resetWelcomeScreen">
            Reset Welcome Screen
          </v-btn>
        </div>
      </v-col>
    </v-row>
    
    <!-- Welcome Modal -->
    <WelcomeModal v-model="showWelcome" />
  </v-container>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useGameStore } from '../stores/gameStore';
import Keyboard from '../components/Keyboard.vue';
import ProgressTracker from '../components/ProgressTracker.vue';
import PowerUps from '../components/PowerUps.vue';
import DifficultySelector from '../components/DifficultySelector.vue';
import WelcomeModal from '../components/WelcomeModal.vue';

const game = useGameStore();
const userAnswer = ref('');
const question = ref({ num1: 9, num2: 2, operator: '-' });
const showWelcome = ref(false);

// Ensure the game state is loaded on component mount
onMounted(() => {
  game.loadGameState();
  
  // Check if we need to show the welcome screen
  if (!localStorage.getItem('hasSeenWelcome')) {
    showWelcome.value = true;
  }
});

// Placeholder for landmark images
const landmarkImagePlaceholder = computed(() => {
  const country = game.countries[game.currentCountryIndex].name.toLowerCase();
  const landmark = game.countries[game.currentCountryIndex].landmarks[game.currentLandmarkIndex]
    .toLowerCase()
    .replace(/\s+/g, '-');
  
  return `https://placehold.co/150x100/3498db/ffffff?text=${country}+${landmark}`;
});

function difficultyChanged(difficulty) {
  // Handle difficulty change
  console.log('Difficulty changed to:', difficulty);
}

function activateHint() {
  // Handle hint activation
  console.log('Hint activated');
}

function activateTimeFreeze() {
  // Handle time freeze activation
  console.log('Time freeze activated');
}

function handleInput(value) {
  if (value === 'delete') {
    userAnswer.value = userAnswer.value.slice(0, -1);
  } else if (value === '-') {
    // Handle negative sign - only add at the beginning
    if (userAnswer.value === '') {
      userAnswer.value = '-';
    }
  } else {
    userAnswer.value += value;
  }
}

function checkAnswer() {
  // Simple answer checking
  const correctAnswer = 7; // 9 - 2 = 7
  const userInput = parseInt(userAnswer.value);
  
  if (userInput === correctAnswer) {
    alert('Correct!');
    userAnswer.value = '';
  } else {
    alert('Incorrect, try again!');
  }
}

function resetWelcomeScreen() {
  localStorage.removeItem('hasSeenWelcome');
  showWelcome.value = true;
}
</script>

<style scoped>
/* Background */
.game-screen {
  background: linear-gradient(135deg, #1abc9c, #3498db);
  width: 100%;
  max-width: 450px;
  border-radius: 20px;
  text-align: center;
  padding: 20px;
  box-shadow: 0px 8px 20px rgba(0, 0, 0, 0.2);
  margin: 0 auto;
  position: relative;
  overflow: hidden;
}

/* Landmark Section */
.landmark-info-container {
  margin-bottom: 20px;
  text-align: center;
}

.landmark-image-container {
  width: 150px;
  height: 100px;
  margin: 0 auto 10px;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.landmark-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.landmark-name {
  color: white;
  font-size: 1.2rem;
  font-weight: bold;
  margin-bottom: 5px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.country-name {
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
  margin-top: 0;
}

/* Math question styling */
.problem {
  background: white;
  padding: 10px 20px;
  border-radius: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: inline-block;
}

.answer-field {
  font-size: 1.5rem;
  text-align: center;
  max-width: 200px;
  margin: auto;
}

.submit-btn {
  min-width: 120px;
  margin-top: 16px;
}
</style>