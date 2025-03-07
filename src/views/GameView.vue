<template>
  <div class="game-container">
    <div class="game-screen">
      <!-- Progress Tracker -->
      <ProgressTracker />
      
      <!-- Divider line -->
      <div class="divider-line"></div>
      
      <!-- Landmark Info (centered in middle) -->
      <div class="landmark-content">
        <h2 class="landmark-name">
          {{ game.countries[game.currentCountryIndex].landmarks[game.currentLandmarkIndex] }}
        </h2>
        <p class="country-name">
          {{ game.countries[game.currentCountryIndex].name }}
        </p>
      </div>
      
      <!-- Math Question Component -->
      <MathQuestion 
        :difficulty="game.difficulty" 
        @correct="onCorrectAnswer" 
        @incorrect="onIncorrectAnswer"
      />
      
      <!-- Reset Button -->
      <v-btn 
        class="reset-btn" 
        variant="outlined" 
        @click="resetWelcomeScreen"
      >
        RESET WELCOME SCREEN
      </v-btn>
      
      <!-- Welcome Modal -->
      <WelcomeModal v-model="showWelcome" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useGameStore } from '../stores/gameStore';
import ProgressTracker from '../components/ProgressTracker.vue';
import MathQuestion from '../components/MathQuestion.vue';
import WelcomeModal from '../components/WelcomeModal.vue';

const game = useGameStore();
const showWelcome = ref(false);

// Ensure the game state is loaded on component mount
onMounted(() => {
  game.loadGameState();
  
  // Check if we need to show the welcome screen
  if (!localStorage.getItem('hasSeenWelcome')) {
    showWelcome.value = true;
  }
});

function onCorrectAnswer() {
  // Handle correct answer (already handled in MathQuestion component)
  console.log('Correct answer received in parent');
}

function onIncorrectAnswer() {
  // Handle incorrect answer (already handled in MathQuestion component)
  console.log('Incorrect answer received in parent');
}

function resetWelcomeScreen() {
  localStorage.removeItem('hasSeenWelcome');
  showWelcome.value = true;
}

function resetWelcomeScreen() {
  localStorage.removeItem('hasSeenWelcome');
  showWelcome.value = true;
}
</script>

<style scoped>
/* Game container */
.game-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 0;
  margin: 0;
  background-color: #f5f5f5;
}

/* Main game screen with gradient background */
.game-screen {
  width: 100%;
  max-width: 400px;
  height: 100vh;
  max-height: 800px;
  margin: 0 auto;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
  position: relative;
  background: linear-gradient(to bottom, #7DCEA0, #85C1E9);
  padding: 16px;
}

/* Horizontal divider */
.divider-line {
  height: 1px;
  background-color: rgba(255, 255, 255, 0.6);
  width: 100%;
  margin: 12px 0;
}

/* Landmark content styling */
.landmark-content {
  text-align: center;
  padding: 24px 0 16px 0;
}

.landmark-name {
  color: white;
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 4px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

.country-name {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1.2rem;
  margin-top: 0;
}

/* Reset button */
.reset-btn {
  margin: 12px auto;
  width: 90%;
  border-radius: 8px !important;
  background-color: white !important;
  color: #333 !important;
  font-size: 0.9rem !important;
}

/* Math question styling */
.math-question {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.math-question-box {
  background: white;
  padding: 16px 36px;
  border-radius: 40px;
  margin: 0 auto 24px auto;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  display: inline-block;
}

.math-expression {
  font-size: 1.6rem;
  margin: 0;
  font-weight: 600;
}

/* Answer input styling */
.answer-box-container {
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
  width: 100%;
}

.answer-input {
  width: 100%;
  height: 60px;
  border-radius: 12px;
  border: none;
  text-align: center;
  font-size: 1.5rem;
  background: white;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  color: #333;
  margin: 0 16px;
}

/* Keyboard styling */
.keyboard-layout {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 20px;
  width: 100%;
}

.keyboard-row {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  width: 100%;
}

.keyboard-btn {
  flex: 1;
  aspect-ratio: 1/1;
  font-size: 1.5rem !important;
  border-radius: 12px !important;
}

.number-btn {
  background-color: #4A69BD !important;
}

.minus-btn {
  background-color: #5DADE2 !important;
}

.delete-btn {
  background-color: #CB4335 !important;
}

/* Submit button */
.submit-btn {
  margin: 8px auto;
  padding: 8px 32px !important;
  font-size: 1.1rem !important;
  letter-spacing: 1px;
  border-radius: 30px !important;
  background-color: #ABEBC6 !important;
  color: #333 !important;
  width: 60%;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

/* Responsive media queries */
@media (max-width: 500px) {
  .game-screen {
    max-width: 100%;
    border-radius: 0;
    height: 100vh;
    max-height: none;
  }
  
  .keyboard-btn {
    height: auto !important;
  }
}

@media (min-width: 501px) and (max-width: 1024px) {
  .game-screen {
    max-width: 450px;
    height: auto;
    min-height: 700px;
  }
}

@media (min-width: 1025px) {
  .game-screen {
    max-width: 450px;
    height: auto;
    min-height: 700px;
  }
}
</style>