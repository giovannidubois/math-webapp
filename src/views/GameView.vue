<template>
  <div class="game-container">
    <div class="game-screen">
      <!-- Background Image Component -->
      <LandmarkImage :src="game.currentLandmarkImagePath" />
      
      <!-- <div style="position: absolute; bottom: 5px; left: 5px; font-size: 10px; color: white; 
            background: rgba(0,0,0,0.5); padding: 2px; z-index: 100;">
        {{ game.currentLandmarkImagePath }}
      </div> -->

      <!-- Progress Tracker -->
      <ProgressTracker />
      
      <!-- Divider line -->
      <div class="divider-line"></div>
      
      <!-- Landmark Info (centered in middle) -->
      <div class="landmark-content">
        <h2 class="landmark-name">
          {{ currentLandmark }}
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
import { ref, onMounted, computed } from 'vue';
import { useGameStore } from '../stores/gameStore';
import ProgressTracker from '../components/ProgressTracker.vue';
import MathQuestion from '../components/MathQuestion.vue';
import WelcomeModal from '../components/WelcomeModal.vue';
import LandmarkImage from '../components/LandmarkImage.vue';

const game = useGameStore();
const showWelcome = ref(false);

// Get current landmark name
const currentLandmark = computed(() => {
  return game.countries[game.currentCountryIndex].landmarks[game.currentLandmarkIndex];
});

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

/* Main game screen */
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
  padding: 16px;
  /* Background will be handled by LandmarkImage component */
}

/* Horizontal divider */
.divider-line {
  height: 1px;
  background-color: rgba(255, 255, 255, 0.6);
  width: 100%;
  margin: 12px 0;
  z-index: 1;
}

/* Landmark content styling */
.landmark-content {
  text-align: center;
  padding: 24px 0 16px 0;
  z-index: 1;
}

.landmark-name {
  color: white;
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 4px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.country-name {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1.2rem;
  margin-top: 0;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

/* Reset button */
.reset-btn {
  margin: 12px auto;
  width: 90%;
  border-radius: 8px !important;
  background-color: white !important;
  color: #333 !important;
  font-size: 0.9rem !important;
  z-index: 1;
}

/* Make sure all components are above the background */
.progress-tracker,
.math-question {
  z-index: 1;
  position: relative;
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